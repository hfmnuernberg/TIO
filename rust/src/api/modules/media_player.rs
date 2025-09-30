use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use lazy_static::__Deref;
use pitch_shift::PitchShifter;
use std::sync::Mutex;
use std::sync::mpsc::{Receiver, Sender, channel};
use std::thread::{self, JoinHandle};
use std::time::Duration;

use crate::api::audio::audio_buffer_interpolated::AudioBufferInterpolated;
use crate::api::audio::global::GLOBAL_AUDIO_LOCK;
use crate::api::util::constants::{
    AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, NUM_CHANNELS, OUTPUT_SAMPLE_RATE,
    PITCH_SHIFT_WINDOW_DUR_MILLIS,
};
use crate::api::util::util_functions::get_platform_default_cpal_output_config;

use crate::api::util::util_functions::load_audio_file; // can be deleted?
use std::collections::HashMap;
use std::collections::hash_map::Entry;

use std::sync::atomic::{AtomicUsize, Ordering};

extern crate queues;

// Heartbeat/throttling counters for callback logging
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
struct ThreadData {
    _audio_out_thread: JoinHandle<()>,
    _pitch_shift_thread: JoinHandle<()>,
    stop_sender: Sender<()>,
    stop_sender_ps: Sender<()>,
}

#[flutter_rust_bridge::frb(ignore)]
struct AudioProcessingData {
    pitch_change_semitones: f32,
    speed_change_factor: f32,
    pitch_shifter: Option<PitchShifter>,
}

lazy_static! {
    static ref THREAD_DATA: std::sync::Mutex<Option<ThreadData>> = std::sync::Mutex::new(None);
    static ref SOURCE_DATA: std::sync::Mutex<AudioBufferInterpolated> =
        std::sync::Mutex::new(AudioBufferInterpolated::new(vec![]));
    static ref PROCESSING_DATA: std::sync::Mutex<AudioProcessingData> =
        std::sync::Mutex::new(AudioProcessingData {
            pitch_change_semitones: 0.0,
            speed_change_factor: 1.0,
            pitch_shifter: None,
        });
}

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

// #[flutter_rust_bridge::frb(ignore)]
// pub fn mp_get_state(id: &str) -> Option<MediaPlayerState> {
//     with_mixer(|m| m.get_state(id))
// }
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

static VOLUME: Mutex<f32> = Mutex::new(1.0);

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
    //     fn rebuild_output_stream(&mut self) {
    //         log::warn!("[MP] rebuild_output_stream: tearing down and recreating output thread");
    //         if self.out_thread.take().is_some() {
    //             log::warn!("[MP] rebuild_output_stream: dropped previous output thread handle");
    //         }
    //         // Force a fresh stream creation
    //         let ok = self.ensure_output_stream();
    //         log::info!("[MP] rebuild_output_stream: ensure_output_stream -> {}", ok);
    //     }

    fn ensure_output_stream(&mut self) -> bool {
        // Idempotent: if we already have a running thread/stream, reuse it.
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

        // Spawn a thread that owns the CPAL stream so it won't drop.
        let join = std::thread::spawn(move || {
            let build_res = device.build_output_stream(
                &config,
                |out: &mut [f32], _| {
                    // (2) Heartbeat goes here (see below)
                    // Heartbeat at the very top of the audio callback (throttled)
                    let hb = AUDIO_CB_HEARTBEAT.fetch_add(1, Ordering::Relaxed) + 1;
                    if hb % 50 == 0 {
                        // Every ~50 callbacks emit an info-level heartbeat so it shows up in production logs
                        log::info!("[MP] audio callback: tick #{}", hb);
                    } else {
                        // Keep the per-callback trace for deep debugging
                        log::trace!("[MP] audio callback: tick");
                    }

                    // Zero out the buffer first
                    for s in out.iter_mut() { *s = 0.0; }

                    // Mix players (see also (4) clarity tweaks below)
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
                            if !player.source_data.get_is_playing() {
                                log::trace!("[MP] skip {} (buffer not playing)", id);
                                continue;
                            }

                            player.source_data.add_samples_to_buffer(out, player.volume);
                            active_players += 1;
                            mixed_ids.push(id.clone());
                        }

                        apply_headroom_if_many(out, active_players);

                        if active_players > 0 {
                            // quick visibility
                            let mut energy: f32 = 0.0;
                            for s in out.iter() { energy += s.abs(); }
                            log::trace!("[MP] mixed players: {:?}; energy={:.6}", mixed_ids, energy);
                            // reset idle heartbeat
                            NO_ACTIVE_HEARTBEAT.store(0, Ordering::Relaxed);
                        } else {
                            // Throttle idle spam: emit every ~200 callbacks at info-level
                            let idle = NO_ACTIVE_HEARTBEAT.fetch_add(1, Ordering::Relaxed) + 1;
                            if idle % 200 == 0 {
                                log::info!("Mixer: no active players");
                            } else {
                                log::trace!("Mixer: no active players");
                            }
                        }
                    } else {
                        log::trace!("[MP] audio callback: failed to lock MIXER");
                    }
                },
                |err| {
                    log::error!("[MP] output stream error: {:?}", err);
                },
                None, // no create-timeout
            );

            match build_res {
                Ok(stream) => {
                    if let Err(e) = stream.play() {
                        log::error!("[MP] ensure_output_stream: play() failed: {:?}", e);
                        return; // Drop thread; next ensure() will recreate.
                    }
                    log::info!("[MP] ensure_output_stream: stream.play() ok");

                    // Keep this thread alive forever to retain `stream`
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
    //     pub fn start(&mut self, id: &str) -> bool {
    //         log::info!("[MP] Mixer::start(id={})", id);
    //         let p = self.get_or_create(id);
    //         log::info!(
    //             "[MP] Mixer::start: id={} playing={} is_playing={} trim=({:.3},{:.3}) pos={:.3}",
    //             id,
    //             p.playing,
    //             p.source_data.get_is_playing(),
    //             p.source_data.get_trim().0,
    //             p.source_data.get_trim().1,
    //             p.source_data.get_playback_position_factor(),
    //         );
    //
    //         if p.source_data.get_is_empty() {
    //             log::info!("[MP] Mixer::start -> false (empty buffer)");
    //             return false;
    //         }
    //
    //         p.source_data.reset_to_start();
    //         p.source_data.set_playing(true);
    //         p.playing = true;
    //         let ok = self.ensure_output_stream();
    //         log::info!("[MP] Mixer::start ensure_output_stream -> {}", ok);
    //         ok
    //     }
    //     pub fn start(&mut self, id: &str) -> bool {
    //         if let Some(p) = self.players.get_mut(id) {
    //             // allow buffer to generate samples
    //             p.source_data.set_playing(true);
    //             // mark eligible for mixing
    //             p.playing = true;
    //
    //             // optional but recommended when not looping:
    //             p.source_data.reset_playhead_to_start_if_at_end();
    //
    //             self.ensure_output_stream()
    //         } else {
    //             log::info!("[MP] Mixer::start: no player {}", id);
    //             false
    //         }
    //     }
    pub fn start(&mut self, id: &str) -> bool {
        log::info!("[MP] Mixer::start(id={})", id);
        // 1) Set up/flip flags while holding the player mutably, but release before ensure_output_stream()
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

            p.source_data.reset_playhead_to_start_if_at_end();
            p.source_data.set_playing(true);
            p.playing = true;
        } // <-- release mutable borrow of self via `p`

        // 2) Now we can safely call a method that needs &mut self again

        let before = AUDIO_CB_HEARTBEAT.load(Ordering::Relaxed);
        let ok = self.ensure_output_stream();
        if !ok {
            return false;
        }

        std::thread::sleep(std::time::Duration::from_millis(40)); // ~2–3 callbacks at 48k
        let after = AUDIO_CB_HEARTBEAT.load(Ordering::Relaxed);
        if after == before {
            log::warn!("[MP] no audio callbacks after start; rebuilding output stream");
            self.rebuild_output_stream();
        }

        // 3) Take an immutable snapshot for logging (or handle missing player gracefully)
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

    //     pub fn stop(&mut self, id: &str) -> bool {
    //         let p = self.get_or_create(id);
    //         p.source_data.set_playing(false);
    //         p.playing = false;
    //         true
    //     }
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
            // reflect the actual per-player state
            playing: p.playing && p.source_data.get_is_playing(),
            playback_position_factor: p.source_data.get_playback_position_factor(),
            total_length_seconds: p
                .source_data
                .get_length_seconds(*OUTPUT_SAMPLE_RATE.lock().expect("OUTPUT_SAMPLE_RATE")),
        })
    }

    //     pub fn compute_rms(&self, id: &str, n_bins: usize) -> Vec<f32> {
    //         if let Some(p) = self.players.get(id) {
    //             return p.source_data.compute_rms(n_bins);
    //         }
    //         vec![0.0; n_bins]
    //     }
    pub fn compute_rms(&self, id: &str, n_bins: usize) -> Vec<f32> {
        match self.players.get(id) {
            Some(p) => p.source_data.compute_rms(n_bins),
            None => vec![0.0; n_bins],
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_create_stream() -> bool {
    media_player_trigger_destroy_stream();

    log::info!("Starting media player stream");

    let mut source_data = SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA");

    if source_data.get_is_empty() {
        return false;
    } else {
        source_data.set_playing(true);
    }

    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to get sample rate");

    *THREAD_DATA
        .lock()
        .expect("Could not lock mutex to THREAD_DATA") = None;
    PROCESSING_DATA
        .lock()
        .expect("Could not lock mutex to PROCESSING_DATA")
        .pitch_shifter = Some(PitchShifter::new(
        PITCH_SHIFT_WINDOW_DUR_MILLIS,
        sample_rate,
    ));

    let host = cpal::default_host();
    let device = host
        .default_output_device()
        .expect("no output device available");

    let config = get_platform_default_cpal_output_config(&device);
    if config.is_none() {
        log::info!(
            "Could not start media player output stream - Could not get default output config",
        );
        return false;
    }
    let config = config.expect("Could not get default stream output config");

    let (channel_sender, channel_receiver): (Sender<()>, Receiver<()>) = channel();
    let audio_out_thread = thread::spawn(move || {
        match device.build_output_stream(
            &config,
            on_audio_callback,
            move |_| log::info!("something went wrong with the audio stream"),
            Some(Duration::from_secs(AUDIO_STREAM_CREATE_TIMEOUT_SECONDS)),
        ) {
            Ok(stream_out) => {
                stream_out.play().expect("Could not play stream");
                log::info!("Mixer: output stream started");

                while let Ok(command) = channel_receiver.recv() {
                    // this waits until stop is sent
                    thread_handle_command(command);
                }
            }
            Err(e) => log::info!("failed to build audio stream: {}", e),
        }
    });

    let (channel_sender_ps, channel_receiver_ps): (Sender<()>, Receiver<()>) = channel();
    let pitch_shift_thread = thread::spawn(move || {
        loop {
            let _audio_processing_data = PROCESSING_DATA
                .lock()
                .expect("Could not lock mutex to PROCESSING_DATA");

            if let Ok(_command) = channel_receiver_ps.try_recv() {
                return;
            }
        }
    });

    *THREAD_DATA
        .lock()
        .expect("Could not lock mutex to THREAD_DATA") = Some(ThreadData {
        _audio_out_thread: audio_out_thread,
        _pitch_shift_thread: pitch_shift_thread,
        stop_sender: channel_sender,
        stop_sender_ps: channel_sender_ps,
    });

    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_trigger_destroy_stream() -> bool {
    match THREAD_DATA
        .lock()
        .expect("Could not lock mutex to THREAD_DATA")
        .deref()
    {
        Some(thread_data) => {
            let succcess_audio_thread = match thread_data.stop_sender.send(()) {
                Ok(_) => true,
                Err(_) => {
                    log::info!("Could not send stop signal to audio stream");
                    false
                }
            };
            let success_pitch_shift = match thread_data.stop_sender_ps.send(()) {
                Ok(_) => true,
                Err(_) => {
                    log::info!("Could not send stop signal to pitch shift thread");
                    false
                }
            };

            succcess_audio_thread && success_pitch_shift
        }
        None => {
            log::info!(
                "Mediaplayer failed to trigger audio stream to stop. No audio stream running.",
            );
            false
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
fn on_audio_callback(out: &mut [f32], _: &cpal::OutputCallbackInfo) {
    // Clear output
    for s in out.iter_mut() {
        *s = 0.0;
    }

    let mut active_players = 0usize;

    let mut guard = MIXER.lock().expect("MediaPlayer: lock MIXER");
    for (_id, p) in guard.players.iter_mut() {
        if !p.playing {
            continue;
        }
        active_players += 1;

        // Scratch buffer for mono read
        let frames = out.len() / NUM_CHANNELS;
        let mut temp = vec![0.0f32; frames];
        p.source_data.get_samples(&mut temp[..], 1.0); // Option A: speed=1.0, no pitch/time processing

        // Mix into stereo out (or NUM_CHANNELS)
        for i in 0..frames {
            let v = temp[i] * p.volume;
            for ch in 0..NUM_CHANNELS {
                out[i * NUM_CHANNELS + ch] += v;
            }
        }
    }

    apply_headroom_if_many(out, active_players);
}

fn thread_handle_command(_command: ()) {
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    *THREAD_DATA
        .lock()
        .expect("Could not lock mutex to THREAD_DATA to clear") = None;
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to set playing flag")
        .set_playing(false);
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_buffer(new_buffer: Vec<f32>) {
    *SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to set buffer") =
        AudioBufferInterpolated::new(new_buffer);
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_pos_factor(pos_factor: f32) -> bool {
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to compute rms")
        .set_playback_position_factor(pos_factor);
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_pitch(semitones: f32) -> bool {
    PROCESSING_DATA
        .lock()
        .expect("Could not lock mutex to PROCESSING_DATA to set pitch")
        .pitch_change_semitones = semitones;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_speed(speed_factor: f32) -> bool {
    PROCESSING_DATA
        .lock()
        .expect("Could not lock mutex to PROCESSING_DATA to set speed")
        .speed_change_factor = speed_factor;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_compute_rms(n_bins: usize) -> Vec<f32> {
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to compute rms")
        .compute_rms(n_bins)
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_loop_value(loop_on: bool) {
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to set loop flag")
        .set_loop(loop_on);
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_trim_by_factor(start_factor: f32, end_factor: f32) {
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to set loop flag")
        .set_trim(start_factor, end_factor);
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_new_volume(new_volume: f32) -> bool {
    *VOLUME
        .lock()
        .expect("Could not lock mutex to VOLUME to set new value") = new_volume;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_query_state() -> Option<MediaPlayerState> {
    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to get sample rate");

    let source_data = SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to get media player state");

    let playback_position_factor = source_data.get_playback_position_factor();
    let total_length_seconds = source_data.get_length_seconds(sample_rate);

    Some(MediaPlayerState {
        playing: source_data.get_is_playing(),
        playback_position_factor,
        total_length_seconds,
    })
}
