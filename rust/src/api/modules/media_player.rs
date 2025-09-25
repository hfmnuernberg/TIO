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
    AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, OUTPUT_SAMPLE_RATE, PITCH_SHIFT_WINDOW_DUR_MILLIS,
};
use crate::api::util::util_functions::get_platform_default_cpal_output_config;

use crate::api::util::util_functions::load_audio_file;
use std::collections::HashMap;

extern crate queues;

#[flutter_rust_bridge::frb(ignore)]
struct PlayerCore {
    pub source_data: AudioBufferInterpolated,
    pub volume: f32,
    pub playing: bool,
    processing: AudioProcessingData,
}

impl PlayerCore {
    pub fn new(sample_rate: usize) -> Self {
        Self {
            source_data: AudioBufferInterpolated::new(vec![]),
            processing: AudioProcessingData {
                pitch_change_semitones: 0.0,
                speed_change_factor: 1.0,
                pitch_shifter: Some(PitchShifter::new(
                    PITCH_SHIFT_WINDOW_DUR_MILLIS,
                    sample_rate,
                )),
            },
            volume: 1.0,
            playing: false,
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
struct Mixer {
    players: HashMap<String, PlayerCore>,
    out_join: Option<JoinHandle<()>>,
    sample_rate: usize,
}

impl Mixer {
    fn new(sample_rate: usize) -> Self {
        Self {
            players: HashMap::new(),
            out_join: None,
            sample_rate,
        }
    }
    fn get_or_create(&mut self, id: &str) -> &mut PlayerCore {
        self.players
            .entry(id.to_string())
            .or_insert_with(|| PlayerCore::new(self.sample_rate))
    }
}

lazy_static! {
    static ref MIXER: Mutex<Mixer> = {
        let sr = *OUTPUT_SAMPLE_RATE.lock().expect("sample rate");
        Mutex::new(Mixer::new(sr))
    };
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

pub(crate) fn mp_load(id: &str, path: &str) -> bool {
    match load_audio_file(path.to_string()) {
        Ok(buffer) => {
            let mut mx = MIXER.lock().expect("mixer");
            let p = mx.get_or_create(id);
            p.source_data.set_new_file(buffer);
            true
        }
        Err(e) => {
            log::info!("load failed: {}", e);
            false
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_start(id: &str) -> bool {
    let ok = MIXER.lock().expect("mixer").start(id);
    log::info!("Mixer: mp_start(id={}) -> {}", id, ok);
    ok
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_stop(id: &str) -> bool {
    let ok = MIXER.lock().expect("mixer").stop(id);
    log::info!("Mixer: mp_stop(id={}) -> {}", id, ok);
    ok
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_set_pitch(id: &str, semitones: f32) -> bool {
    MIXER.lock().expect("mixer").set_pitch(id, semitones)
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_set_speed(id: &str, speed: f32) -> bool {
    MIXER.lock().expect("mixer").set_speed(id, speed)
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_set_trim_by_factor(id: &str, start: f32, end: f32) {
    MIXER
        .lock()
        .expect("mixer")
        .set_trim_by_factor(id, start, end)
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_compute_rms(id: &str, n_bins: usize) -> Vec<f32> {
    MIXER.lock().expect("mixer").compute_rms(id, n_bins)
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_set_loop_mode(id: &str, looping: bool) {
    MIXER.lock().expect("mixer").set_loop_value(id, looping)
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_get_state(id: &str) -> Option<MediaPlayerState> {
    MIXER.lock().expect("mixer").get_state(id)
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_set_pos_factor(id: &str, pos: f32) -> bool {
    MIXER.lock().expect("mixer").set_pos_factor(id, pos)
}

#[flutter_rust_bridge::frb(ignore)]
pub(crate) fn mp_set_volume(id: &str, vol: f32) -> bool {
    MIXER.lock().expect("mixer").set_volume(id, vol)
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

fn mix_output_callback(out: &mut [f32]) {
    for s in out.iter_mut() {
        *s = 0.0;
    }

    let mut active = 0usize;

    let mut maybe_chunks: Vec<Vec<f32>> = Vec::new();
    {
        let mut mx = MIXER.lock().expect("lock mixer");

        for p in mx.players.values_mut() {
            if !p.playing {
                continue;
            }

            let mut buf = vec![0.0f32; out.len()];
            // TODO: replace 1.0 with the actual read speed from your processing state
            p.source_data.get_samples(&mut buf, 1.0);

            if buf.iter().any(|s| *s != 0.0) {
                for s in buf.iter_mut() {
                    *s *= p.volume;
                }
                active += 1;
                maybe_chunks.push(buf);
            }
        }
    }

    for chunk in maybe_chunks.iter() {
        for (o, s) in out.iter_mut().zip(chunk.iter()) {
            *o += *s;
        }
    }

    apply_headroom_if_many(out, active);
}

impl Mixer {
    fn ensure_output_stream(&mut self) -> bool {
        if self.out_join.is_some() {
            return true;
        }

        let host = cpal::default_host();
        let device = match host.default_output_device() {
            Some(d) => d,
            None => {
                log::info!("Mixer: no output device");
                return false;
            }
        };
        let config = match get_platform_default_cpal_output_config(&device) {
            Some(c) => c,
            None => {
                log::info!("Mixer: no default output config");
                return false;
            }
        };

        let join = thread::spawn(move || {
            match device.build_output_stream(
                &config,
                |data: &mut [f32], _| mix_output_callback(data),
                move |_| log::info!("Mixer: output error"),
                Some(Duration::from_secs(AUDIO_STREAM_CREATE_TIMEOUT_SECONDS)),
            ) {
                Ok(stream) => {
                    if let Err(e) = stream.play() {
                        log::info!("Mixer: could not play stream: {}", e);
                    }
                }
                Err(e) => log::info!("Mixer: build_output_stream failed: {}", e),
            }
        });

        self.out_join = Some(join);
        true
    }
}

impl Mixer {
    pub fn start(&mut self, id: &str) -> bool {
        let p = self.get_or_create(id);
        if p.source_data.get_is_empty() {
            return false;
        }
        p.source_data.set_playing(true);
        p.playing = true;
        self.ensure_output_stream()
    }

    pub fn stop(&mut self, id: &str) -> bool {
        let p = self.get_or_create(id);
        p.source_data.set_playing(false);
        p.playing = false;
        true
    }

    pub fn set_volume(&mut self, id: &str, vol: f32) -> bool {
        let p = self.get_or_create(id);
        p.volume = vol;
        true
    }

    pub fn set_pitch(&mut self, id: &str, semitones: f32) -> bool {
        let p = self.get_or_create(id);
        p.processing.pitch_change_semitones = semitones;
        true
    }

    pub fn set_speed(&mut self, id: &str, speed: f32) -> bool {
        let p = self.get_or_create(id);
        p.processing.speed_change_factor = speed;
        true
    }

    pub fn set_trim_by_factor(&mut self, id: &str, start: f32, end: f32) {
        let p = self.get_or_create(id);
        p.source_data.set_trim(start, end);
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

    pub fn get_state(&self, _id: &str) -> Option<MediaPlayerState> {
        // TODO: implement true per-player state
        media_player_query_state()
    }

    pub fn compute_rms(&self, _id: &str, n_bins: usize) -> Vec<f32> {
        // TODO: implement true per-player RMS over p.source_data without mutating playback state.
        // Temporary shim: reuse existing global RMS so UI keeps working.
        media_player_compute_rms(n_bins)
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

fn on_audio_callback(samples_out: &mut [f32], _: &cpal::OutputCallbackInfo) {
    mix_output_callback(samples_out);
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

#[derive(Debug, Clone)]
pub struct MediaPlayerState {
    pub playing: bool,
    pub playback_position_factor: f32,
    pub total_length_seconds: f32,
    pub looping: bool,
    pub trim_start_factor: f32,
    pub trim_end_factor: f32,
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
    let total_length_seconds = source_data.get_length_seconds(sample_rate as u32);
    let (trim_start_factor, trim_end_factor) = source_data.get_trim();

    Some(MediaPlayerState {
        playing: source_data.get_is_playing(),
        playback_position_factor,
        total_length_seconds,
        looping: source_data.get_is_looping(),
        trim_start_factor,
        trim_end_factor,
    })
}
