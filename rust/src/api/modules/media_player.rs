use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};

use crate::api::audio::audio_buffer_interpolated::AudioBufferInterpolated;
use crate::api::util::constants::{NUM_CHANNELS, OUTPUT_SAMPLE_RATE};
use crate::api::util::util_functions::get_platform_default_cpal_output_config;

use crate::api::util::util_functions::load_audio_file;
use std::collections::HashMap;
use std::collections::hash_map::Entry;

use std::sync::atomic::{AtomicUsize, Ordering};

extern crate queues;

static AUDIO_CB_HEARTBEAT: AtomicUsize = AtomicUsize::new(0);
static NO_ACTIVE_HEARTBEAT: AtomicUsize = AtomicUsize::new(0);

#[derive(Debug, Clone)]
pub struct MediaPlayerState {
    pub playing: bool,
    pub playback_position_factor: f32,
    pub total_length_seconds: f32,
}

struct PlayerCore {
    source_data: AudioBufferInterpolated,
    volume: f32,
    playing: bool,
    pitch_semitones: f32,
    speed_factor: f32,
}

impl PlayerCore {
    fn new() -> Self {
        Self {
            source_data: AudioBufferInterpolated::new(vec![]),
            volume: 1.0,
            playing: false,
            pitch_semitones: 0.0,
            speed_factor: 1.0,
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
struct Mixer {
    players: std::collections::HashMap<String, PlayerCore>,
    out_thread: Option<std::thread::JoinHandle<()>>,
}

#[flutter_rust_bridge::frb(ignore)]
impl Mixer {
    fn new() -> Self {
        Self {
            players: HashMap::new(),
            out_thread: None,
        }
    }
}

lazy_static! {
    static ref MIXER: std::sync::Mutex<Mixer> = std::sync::Mutex::new(Mixer::new());
}

fn with_player_mut<R>(id: &str, f: impl FnOnce(&mut PlayerCore) -> R) -> R {
    let mut mix = MIXER.lock().expect("MediaPlayer: lock MIXER");
    let p = mix.get_or_create(id);
    f(p)
}

#[flutter_rust_bridge::frb(ignore)]
fn with_mixer_mut<R>(f: impl FnOnce(&mut Mixer) -> R) -> R {
    let mut mix = MIXER.lock().expect("MediaPlayer: lock MIXER");
    f(&mut mix)
}

#[flutter_rust_bridge::frb(ignore)]
fn with_mixer<R>(f: impl FnOnce(&Mixer) -> R) -> R {
    let mix = MIXER.lock().expect("MediaPlayer: lock MIXER");
    f(&mix)
}

// DATA

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_load(id: &str, path: &str) -> bool {
    let buffer = match load_audio_file(path.to_string()) {
        Ok(buf) => buf,
        Err(e) => {
            log::info!("MediaPlayer: load failed: {}", e);
            return false;
        }
    };

    with_player_mut(id, |p| {
        p.source_data.set_new_file(buffer);
        let out_sr = *OUTPUT_SAMPLE_RATE
            .lock()
            .expect("Could not lock OUTPUT_SAMPLE_RATE");
        p.source_data.set_sample_rate_hz(out_sr);
        p.source_data.set_playing(false);
        p.playing = false;
    });
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_start(id: &str) -> bool {
    log::info!("[MP] mp_start(id={})", id);
    let ok = with_mixer_mut(|m| m.start(id));
    log::info!("[MP] mp_start(id={}) -> {}", id, ok);
    ok
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_stop(id: &str) -> bool {
    with_mixer_mut(|m| m.stop(id))
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_set_volume(id: &str, vol: f32) -> bool {
    with_mixer_mut(|m| m.set_volume(id, vol))
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_set_pitch(id: &str, semitones: f32) -> bool {
    with_mixer_mut(|m| m.set_pitch(id, semitones))
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_set_speed(id: &str, speed: f32) -> bool {
    with_mixer_mut(|m| m.set_speed(id, speed))
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_set_trim_by_factor(id: &str, start: f32, end: f32) -> bool {
    with_mixer_mut(|m| {
        m.set_trim_by_factor(id, start, end);
        true
    })
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_set_pos_factor(id: &str, pos: f32) -> bool {
    with_mixer_mut(|m| m.set_pos_factor(id, pos))
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_set_loop_mode(id: &str, looping: bool) -> bool {
    with_mixer_mut(|m| {
        m.set_loop_value(id, looping);
        true
    })
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_get_state(id: &str) -> Option<MediaPlayerState> {
    // read-only lock; no need to mutate the mixer
    let mix = MIXER.lock().expect("MediaPlayer: lock MIXER");
    mix.get_state(id)
}

#[flutter_rust_bridge::frb(ignore)]
pub fn mp_compute_rms(id: &str, n_bins: usize) -> Vec<f32> {
    with_mixer(|m| m.compute_rms(id, n_bins))
}

// FUNCTIONS

fn apply_headroom_if_many(out: &mut [f32], active_players: usize) {
    if active_players > 1 {
        let gain = 0.5; // -6 dB when >1 player
        for s in out.iter_mut() {
            *s *= gain;
        }
    }
}

impl Mixer {
    fn ensure_output_stream(&mut self) -> bool {
        if self.out_thread.is_some() {
            log::info!("[MP] ensure_output_stream: reuse existing output thread (already running)");
            return true;
        }

        log::info!("[MP] ensure_output_stream: create new output thread");

        let host = cpal::default_host();
        let device = match host.default_output_device() {
            Some(d) => d,
            None => {
                log::info!("[MP] ensure_output_stream: no output device");
                return false;
            }
        };
        let config = match get_platform_default_cpal_output_config(&device) {
            Some(c) => c,
            None => {
                log::info!("[MP] ensure_output_stream: no default output config");
                return false;
            }
        };

        let join = std::thread::spawn(move || {
            let build_res = device.build_output_stream(
                &config,
                move |out: &mut [f32], _| {
                    for s in out.iter_mut() { *s = 0.0; }

                    let mut active_players = 0usize;
                    if let Ok(mut mix) = MIXER.lock() {
                        let mut mixed_ids: Vec<String> = Vec::new();

                        for (id, player) in mix.players.iter_mut() {
                            if player.source_data.get_is_empty() {
                                log::trace!("[MP] skip {} (empty buffer)", id);
                                continue;
                            }
                            if !player.playing {
                                if player.source_data.get_is_playing() {
                                    log::trace!("[MP] skip {} (mixer flag false but buffer says playing=true)", id);
                                } else {
                                    log::trace!("[MP] skip {} (mixer flag false)", id);
                                }
                                continue;
                            }
                            let frames = out.len() / NUM_CHANNELS;

                            let out_sr = *OUTPUT_SAMPLE_RATE.lock().expect("OUTPUT_SAMPLE_RATE");
                            let src_sr = {
                              let s = player.source_data.sample_rate_hz();
                              if s == 0 { out_sr } else { s }
                            } as f32;

                            let base = (src_sr / out_sr as f32).max(0.0001);
                            let mut read_inc = base * player.speed_factor.max(0.01);

                            if player.pitch_semitones.abs() > 1e-6 {
                              let pitch_ratio = (2.0_f32).powf(player.pitch_semitones / 12.0);
                              read_inc *= pitch_ratio;
                            }

                            let mut temp = vec![0.0f32; frames];
                            player.source_data.get_samples(&mut temp[..], read_inc);

                            for i in 0..frames {
                              let v = temp[i] * player.volume;
                              for ch in 0..NUM_CHANNELS {
                                out[i * NUM_CHANNELS + ch] += v;
                              }
                            }
                            active_players += 1;
                            mixed_ids.push(id.clone());
                        }

                        apply_headroom_if_many(out, active_players);

                        if active_players > 0 {
                            let mut energy: f32 = 0.0;
                            for s in out.iter() { energy += s.abs(); }
                            log::trace!("[MP] mixed players: {:?}; energy={:.6}", mixed_ids, energy);
                            NO_ACTIVE_HEARTBEAT.store(0, Ordering::Relaxed);
                        } else {
                            let idle = NO_ACTIVE_HEARTBEAT.fetch_add(1, Ordering::Relaxed) + 1;
                            if idle % 200 == 0 {
                                log::info!("Mixer: no active players");
                            } else {
                                log::trace!("Mixer: no active players");
                            }
                        }
                    }
                },
                |err| {
                    log::error!("[MP] output stream error: {:?}", err);
                },
                None,
            );

            match build_res {
                Ok(stream) => {
                    if let Err(e) = stream.play() {
                        log::error!("[MP] ensure_output_stream: play() failed: {:?}", e);
                        return;
                    }
                    log::info!("[MP] ensure_output_stream: stream.play() ok");

                    loop {
                        std::thread::sleep(std::time::Duration::from_secs(3600));
                    }
                }
                Err(e) => {
                    log::error!(
                        "[MP] ensure_output_stream: build_output_stream failed: {:?}",
                        e
                    );
                }
            }
        });

        self.out_thread = Some(join);
        true
    }

    fn get_or_create(&mut self, id: &str) -> &mut PlayerCore {
        match self.players.entry(id.to_string()) {
            Entry::Occupied(o) => o.into_mut(),
            Entry::Vacant(v) => v.insert(PlayerCore::new()),
        }
    }
}

impl Mixer {
    pub fn start(&mut self, id: &str) -> bool {
        log::info!("[MP] Mixer::start(id={})", id);
        {
            let p = self.get_or_create(id);
            log::info!(
                "[MP] Mixer::start: id={} playing={} is_playing={} trim=({:.3},{:.3}) pos={:.3}",
                id,
                p.playing,
                p.source_data.get_is_playing(),
                p.source_data.get_trim().0,
                p.source_data.get_trim().1,
                p.source_data.get_playback_position_factor(),
            );

            if p.source_data.get_is_empty() {
                log::info!("[MP] Mixer::start -> false (empty buffer)");
                return false;
            }

            let out_sr = *OUTPUT_SAMPLE_RATE.lock().expect("OUTPUT_SAMPLE_RATE");
            p.source_data.set_sample_rate_hz(out_sr);
            p.source_data.reset_playhead_to_start_if_at_end();
            p.source_data.set_playing(true);
            p.playing = true;
        }

        let before = AUDIO_CB_HEARTBEAT.load(Ordering::Relaxed);
        let ok = self.ensure_output_stream();
        if !ok {
            return false;
        }

        std::thread::sleep(std::time::Duration::from_millis(40));
        let after = AUDIO_CB_HEARTBEAT.load(Ordering::Relaxed);
        if after == before {
            log::warn!("[MP] no audio callbacks after start; rebuilding output stream");
            self.rebuild_output_stream();
        }

        let (playing, is_playing) = if let Some(p) = self.players.get(id) {
            (p.playing, p.source_data.get_is_playing())
        } else {
            (false, false)
        };

        log::info!(
            "[MP] Mixer::start ensure_output_stream -> {} (now: playing={} is_playing={})",
            ok,
            playing,
            is_playing
        );

        ok
    }

    pub fn stop(&mut self, id: &str) -> bool {
        if let Some(p) = self.players.get_mut(id) {
            p.source_data.set_playing(false);
            p.playing = false;
            true
        } else {
            log::info!("[MP] Mixer::stop: no player {}", id);
            false
        }
    }

    fn rebuild_output_stream(&mut self) {
        log::warn!("[MP] rebuild_output_stream: tearing down and recreating output thread");
        if self.out_thread.take().is_some() {
            log::warn!("[MP] rebuild_output_stream: dropped previous output thread handle");
        }
        let ok = self.ensure_output_stream();
        log::info!("[MP] rebuild_output_stream: ensure_output_stream -> {}", ok);
    }

    pub fn set_volume(&mut self, id: &str, vol: f32) -> bool {
        let p = self.get_or_create(id);
        p.volume = vol;
        true
    }

    pub fn set_pitch(&mut self, id: &str, semitones: f32) -> bool {
        let p = self.get_or_create(id);
        p.pitch_semitones = semitones; // metadata only for now
        true
    }

    pub fn set_speed(&mut self, id: &str, speed: f32) -> bool {
        let p = self.get_or_create(id);
        p.speed_factor = speed; // metadata only for now
        true
    }

    pub fn set_trim_by_factor(&mut self, id: &str, start: f32, end: f32) {
        let p = self.get_or_create(id);
        p.source_data.set_trim_by_factor(start, end);
    }

    pub(crate) fn set_pos_factor(&mut self, id: &str, pos: f32) -> bool {
        let p = self.get_or_create(id);
        p.source_data.set_playback_position_factor(pos);
        true
    }

    pub fn set_loop_value(&mut self, id: &str, looping: bool) {
        let p = self.get_or_create(id);
        p.source_data.set_loop(looping);
    }

    pub fn get_state(&self, id: &str) -> Option<MediaPlayerState> {
        let p = self.players.get(id)?;
        Some(MediaPlayerState {
            playing: p.playing && p.source_data.get_is_playing(),
            playback_position_factor: p.source_data.get_playback_position_factor(),
            total_length_seconds: p.source_data.get_length_seconds_self_sr(),
        })
    }

    pub fn compute_rms(&self, id: &str, n_bins: usize) -> Vec<f32> {
        match self.players.get(id) {
            Some(p) => p.source_data.compute_rms(n_bins),
            None => vec![0.0; n_bins],
        }
    }
}
