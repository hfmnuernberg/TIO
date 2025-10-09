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

use ringbuf::{Consumer, SharedRb};
extern crate queues;

// DATA

struct ThreadData {
    _audio_out_thread: JoinHandle<()>,
    _pitch_shift_thread: JoinHandle<()>,
    stop_sender: Sender<()>,
    stop_sender_ps: Sender<()>,
}

struct AudioProcessingData {
    pitch_change_semitones: f32,
    speed_change_factor: f32,
    pitch_shifter: Option<PitchShifter>,
    buffer_after_speed_change: [f32; PITCH_SHIFT_BUFFER_SIZE],
    buffer_after_pitch_shift: [f32; PITCH_SHIFT_BUFFER_SIZE],
}

type RingConsumerType = Consumer<f32, Arc<SharedRb<f32, Vec<MaybeUninit<f32>>>>>;

lazy_static! {
    static ref THREAD_DATA: Mutex<Option<ThreadData>> = Mutex::new(None);
    static ref SOURCE_DATA: Mutex<AudioBufferInterpolated> =
        Mutex::new(AudioBufferInterpolated::new(vec![]));
    static ref PROCESSING_DATA: Mutex<AudioProcessingData> = Mutex::new(AudioProcessingData {
        pitch_change_semitones: 0.0,
        speed_change_factor: 1.0,
        pitch_shifter: None,
        buffer_after_speed_change: [0.0; PITCH_SHIFT_BUFFER_SIZE],
        buffer_after_pitch_shift: [0.0; PITCH_SHIFT_BUFFER_SIZE],
    });
    static ref RING_CONSUMER: Mutex<Option<RingConsumerType>> = Mutex::new(None);
}

static VOLUME: Mutex<f32> = Mutex::new(1.0);

// FUNCTIONS

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

#[flutter_rust_bridge::frb(ignore)]
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
