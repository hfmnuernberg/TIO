use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use lazy_static::__Deref;
use pitch_shift::PitchShifter;
use std::mem::MaybeUninit;
use std::ops::DerefMut;
use std::sync::mpsc::{Receiver, Sender, channel};
use std::sync::{Arc, Mutex};
use std::thread::{self, JoinHandle};
use std::time::Duration;

use crate::api::audio::audio_buffer_interpolated::AudioBufferInterpolated;
use crate::api::audio::global::GLOBAL_AUDIO_LOCK;
use crate::api::util::constants::{
    AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, MEDIA_PLAYER_PLAYBACK_MAX_BUFFERING,
    MEDIA_PLAYER_PLAYBACK_MIN_BUFFERING, NUM_CHANNELS, OUTPUT_SAMPLE_RATE, PITCH_SHIFT_BUFFER_SIZE,
    PITCH_SHIFT_OVERSAMPLING, PITCH_SHIFT_WINDOW_DUR_MILLIS,
};
use crate::api::util::util_functions::{
    get_platform_default_cpal_output_config, speed_factor_to_halftones,
};

use crate::api::util::util_functions::load_audio_file;
use std::collections::HashMap;

use ringbuf::{Consumer, SharedRb};
type RingConsumerType = Consumer<f32, Arc<SharedRb<f32, Vec<MaybeUninit<f32>>>>>;

extern crate queues;

#[flutter_rust_bridge::frb(ignore)]
struct PlayerCore {
    pub source_data: AudioBufferInterpolated,
    pub ring_consumer: Option<RingConsumerType>,
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
                buffer_after_speed_change: vec![0.0; PITCH_SHIFT_BUFFER_SIZE],
                buffer_after_pitch_shift: vec![0.0; PITCH_SHIFT_BUFFER_SIZE],
            },
            ring_consumer: None,
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
    buffer_after_speed_change: Vec<f32>,
    buffer_after_pitch_shift: Vec<f32>,
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
            buffer_after_speed_change: vec![0.0; PITCH_SHIFT_BUFFER_SIZE],
            buffer_after_pitch_shift: vec![0.0; PITCH_SHIFT_BUFFER_SIZE],
        });
    static ref RING_CONSUMER: std::sync::Mutex<Option<RingConsumerType>> =
        std::sync::Mutex::new(None);
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

pub(crate) fn mp_start(id: &str) -> bool {
    MIXER.lock().expect("mixer").start(id)
}

pub(crate) fn mp_stop(id: &str) -> bool {
    MIXER.lock().expect("mixer").stop(id)
}

pub(crate) fn mp_set_pitch(id: &str, semitones: f32) -> bool {
    MIXER.lock().expect("mixer").set_pitch(id, semitones)
}

pub(crate) fn mp_set_speed(id: &str, speed: f32) -> bool {
    MIXER.lock().expect("mixer").set_speed(id, speed)
}

pub(crate) fn mp_set_trim_by_factor(id: &str, start: f32, end: f32) {
    MIXER
        .lock()
        .expect("mixer")
        .set_trim_by_factor(id, start, end)
}

pub(crate) fn mp_compute_rms(id: &str, n_bins: usize) -> Vec<f32> {
    MIXER.lock().expect("mixer").compute_rms(id, n_bins)
}

pub(crate) fn mp_set_loop_mode(id: &str, looping: bool) {
    MIXER.lock().expect("mixer").set_loop_value(id, looping)
}

pub(crate) fn mp_get_state(id: &str) -> Option<MediaPlayerState> {
    MIXER.lock().expect("mixer").get_state(id)
}

pub(crate) fn mp_set_pos_factor(id: &str, pos: f32) -> bool {
    MIXER.lock().expect("mixer").set_pos_factor(id, pos)
}

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
            if let Some(consumer) = p.ring_consumer.as_mut() {
                let mut buf = vec![0.0f32; out.len()];
                let mut i = 0usize;
                while i < buf.len() {
                    match consumer.pop() {
                        Some(sample) => {
                            buf[i] = sample * p.volume;
                            i += 1;
                        }
                        None => break,
                    }
                }
                if i > 0 {
                    active += 1;
                    maybe_chunks.push(buf);
                }
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

/// Load a WAV file for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_load_wav_with_id(player_id: String, wav_file_path: String) -> bool {
    log::info!(
        "media player load wav with id: {} - {}",
        &player_id,
        &wav_file_path
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_load(&player_id, &wav_file_path)
    } else {
        false
    }
}

/// Start playback for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_create_audio_stream_with_id(player_id: String) -> bool {
    log::info!("media player start with id: {}", &player_id);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_start(&player_id)
    } else {
        false
    }
}

/// Stop playback for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_destroy_audio_stream_with_id(player_id: String) -> bool {
    log::info!("media player stop with id: {}", &player_id);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_stop(&player_id)
    } else {
        false
    }
}

/// Set pitch (in semitones) for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_pitch_semitones_with_id(player_id: String, pitch_semitones: f32) -> bool {
    log::info!(
        "media player set pitch with id: {} -> {}",
        &player_id,
        pitch_semitones
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_set_pitch(&player_id, pitch_semitones)
    } else {
        false
    }
}

/// Set speed factor for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_new_speed_factor_with_id(player_id: String, speed_factor: f32) -> bool {
    log::info!(
        "media player set speed with id: {} -> {}",
        &player_id,
        speed_factor
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_set_speed(&player_id, speed_factor)
    } else {
        false
    }
}

/// Set trim (range factors) for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_trim_by_factor_with_id(
    player_id: String,
    start_factor: f32,
    end_factor: f32,
) {
    log::info!(
        "media player set trim with id: {} -> {}..{}",
        &player_id,
        start_factor,
        end_factor
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_set_trim_by_factor(&player_id, start_factor, end_factor);
    }
}

/// Get RMS histogram for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_get_rms_values_with_id(player_id: String, n_bins: usize) -> Vec<f32> {
    log::info!(
        "media player get rms with id: {} -> {} bins",
        &player_id,
        n_bins
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_compute_rms(&player_id, n_bins)
    } else {
        vec![]
    }
}

/// Enable/disable loop for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_loop_mode_with_id(player_id: String, looping: bool) {
    log::info!(
        "media player set loop with id: {} -> {}",
        &player_id,
        looping
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_set_loop_mode(&player_id, looping);
    }
}

/// Query state for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_get_new_state_with_id(player_id: String) -> Option<MediaPlayerState> {
    log::info!("media player get state with id: {}", &player_id);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_get_state(&player_id)
    } else {
        None
    }
}

/// Set playback position factor for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_new_pos_factor_with_id(player_id: String, pos_factor: f32) -> bool {
    log::info!(
        "media player set pos factor with id: {} -> {}",
        &player_id,
        pos_factor
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_set_pos_factor(&player_id, pos_factor)
    } else {
        false
    }
}

/// Set volume for a specific player ID
#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_new_volume_with_id(player_id: String, volume: f32) -> bool {
    log::info!(
        "media player set volume with id: {} -> {}",
        &player_id,
        volume
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        mp_set_volume(&player_id, volume)
    } else {
        false
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

    let rb = SharedRb::<f32, Vec<_>>::new(MEDIA_PLAYER_PLAYBACK_MAX_BUFFERING * 2);
    let (mut producer, consumer) = rb.split();
    *RING_CONSUMER
        .lock()
        .expect("Could not lock mutex to RING_CONSUMER") = Some(consumer);

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
            let mut audio_processing_data = PROCESSING_DATA
                .lock()
                .expect("Could not lock mutex to PROCESSING_DATA");

            if let Ok(_command) = channel_receiver_ps.try_recv() {
                return;
            }

            if producer.len() < MEDIA_PLAYER_PLAYBACK_MAX_BUFFERING {
                let mut audio_source_data = SOURCE_DATA
                    .lock()
                    .expect("Could not lock mutex to SOURCE_DATA");

                if !audio_source_data.get_is_playing() {
                    media_player_trigger_destroy_stream();
                    return;
                }

                let read_speed = audio_processing_data.speed_change_factor;
                audio_source_data.get_samples(
                    &mut audio_processing_data.buffer_after_speed_change,
                    read_speed,
                );

                pitch_shift(&mut audio_processing_data);

                for sample in audio_processing_data.buffer_after_pitch_shift.iter() {
                    producer
                        .push(*sample)
                        .expect("Could not push samples to ringbuffer");
                }
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
    let vol = *VOLUME
        .lock()
        .expect("Could not lock mutex to VOLUME to get it in on_audio_out_callback");

    if let Some(ring_consumer) = RING_CONSUMER
        .lock()
        .expect("Could not lock mutex to RING_CONSUMER")
        .deref_mut()
    {
        if ring_consumer.len() < MEDIA_PLAYER_PLAYBACK_MIN_BUFFERING.max(samples_out.len()) {
            log::info!("buffering...");
            return;
        }

        // write to output
        for i in 0..samples_out.len() / NUM_CHANNELS {
            match ring_consumer.pop() {
                Some(sample) => {
                    for channel in 0..NUM_CHANNELS {
                        let index_out = i * NUM_CHANNELS + channel;
                        samples_out[index_out] = sample * vol * 4.0;
                    }
                }
                None => {
                    log::info!("Mediaplayer ring buffer empty - cannot write to audio output");
                    break;
                }
            }
        }
    }
}

fn pitch_shift(audio_processing_data: &mut AudioProcessingData) {
    if (audio_processing_data.speed_change_factor - 1.0).abs() < f32::EPSILON
        && audio_processing_data.pitch_change_semitones.abs() < f32::EPSILON
    {
        // no pitch shift needed
        for (i, sample) in audio_processing_data
            .buffer_after_speed_change
            .iter()
            .enumerate()
        {
            audio_processing_data.buffer_after_pitch_shift[i] = *sample;
        }
    } else {
        // pitch shift
        if let Some(pitch_shifter) = &mut audio_processing_data.pitch_shifter {
            pitch_shifter.shift_pitch(
                PITCH_SHIFT_OVERSAMPLING,
                audio_processing_data.pitch_change_semitones
                    - speed_factor_to_halftones(audio_processing_data.speed_change_factor),
                &audio_processing_data.buffer_after_speed_change,
                &mut audio_processing_data.buffer_after_pitch_shift,
            );
        } else {
            log::info!("pitch shifter not initialized");
        }
    }
}

fn thread_handle_command(_command: ()) {
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    *THREAD_DATA
        .lock()
        .expect("Could not lock mutex to THREAD_DATA to clear") = None;
    *RING_CONSUMER
        .lock()
        .expect("Could not lock mutex to RING_CONSUMER to clear") = None;
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

// TODO: What should be used?
// #[flutter_rust_bridge::frb(ignore)]
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
