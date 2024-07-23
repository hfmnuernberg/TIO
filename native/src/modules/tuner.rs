use std::ops::DerefMut;
use std::sync::mpsc::{channel, Receiver, Sender};
use std::sync::Mutex;
use std::thread::{self, JoinHandle};
use std::time::Duration;

use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use lazy_static::__Deref;

// use pitch_detection::detector::mcleod::McLeodDetector;
use pitch_detection::detector::yin::YINDetector;
use pitch_detection::detector::PitchDetector;

extern crate indexed_ring_buffer;
use indexed_ring_buffer::*;

use crate::audio::global::GLOBAL_AUDIO_LOCK;
use crate::util::constants::{
    AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, CLARITY_THRESHOLD, INPUT_SAMPLE_RATE, POWER_THRESHOLD,
    TUNER_RING_BUFFER_SIZE,
};
use crate::util::debug_log::debug_log;
use crate::util::util_functions::get_platform_default_cpal_input_config;

// DATA

static THREAD: Mutex<Option<JoinHandle<()>>> = Mutex::new(None);
static THREAD_SENDER: Mutex<Option<Sender<CommandTuner>>> = Mutex::new(None);

pub static RING_PRODUCER: Mutex<Option<Producer<f32>>> = Mutex::new(None);
pub static RING_CONSUMER: Mutex<Option<Consumer<f32>>> = Mutex::new(None);

pub static RING_DATA: Mutex<[f32; TUNER_RING_BUFFER_SIZE]> =
    Mutex::new([0.0; TUNER_RING_BUFFER_SIZE]);

// COMMANDS

enum CommandTuner {
    Stop,
}

// METHODS

pub fn tuner_init() {
    let (producer, consumer, _reader) = indexed_ring_buffer::<f32>(0, TUNER_RING_BUFFER_SIZE);
    *RING_PRODUCER
        .lock()
        .expect("Could not lock mutex to RING_PRODUCER") = Some(producer);
    *RING_CONSUMER
        .lock()
        .expect("Could not lock mutex to RING_CONSUMER") = Some(consumer);
}

pub fn tuner_create_stream() -> bool {
    tuner_trigger_destroy_stream();
    tuner_init();

    let host = cpal::default_host();

    let device = host
        .default_input_device()
        .expect("no input device available");

    let config = get_platform_default_cpal_input_config(&device);
    if config.is_none() {
        debug_log("Could not start tuner input stream - Could not get default input config");
        return false;
    }
    let config = config.expect("Could not get default input config");

    let (tx, rx): (Sender<CommandTuner>, Receiver<CommandTuner>) = channel();
    let join_handle = thread::spawn(move || {
        let stream_in = device
            .build_input_stream(
                &config,
                on_audio_callback,
                move |_| {
                    debug_log("something went wrong with the audio stream");
                },
                Some(Duration::from_secs(AUDIO_STREAM_CREATE_TIMEOUT_SECONDS)),
            )
            .expect("Could not create input stream");
        stream_in.play().expect("Could not play stream");

        while let Ok(command) = rx.recv() {
            handle_command(command);
        }
    });
    *THREAD.lock().expect("Could not lock mutex to THREAD") = Some(join_handle);
    *THREAD_SENDER
        .lock()
        .expect("Could not lock mutex to THREAD_SENDER") = Some(tx);
    true
}

fn on_audio_callback(data: &[f32], _: &cpal::InputCallbackInfo) {
    match RING_PRODUCER
        .lock()
        .expect("Could not lock mutex to RING_PRODUCER")
        .deref_mut()
    {
        Some(ring_producer) => {
            for sample in data {
                if !ring_producer.push(*sample) {
                    break;
                }
            }
        }
        None => debug_log("Could not lock mutex to RING_PRODUCER"),
    }
}

fn handle_command(command: CommandTuner) {
    match command {
        CommandTuner::Stop => {
            let _guard = GLOBAL_AUDIO_LOCK
                .lock()
                .expect("Could not lock global audio lock");
            *THREAD_SENDER
                .lock()
                .expect("Could not lock mutex to THREAD_SENDER to clear") = None;
            *THREAD
                .lock()
                .expect("Could not lock mutex to THREAD to clear") = None;
        }
    }
}

pub fn tuner_trigger_destroy_stream() -> bool {
    match THREAD_SENDER
        .lock()
        .expect("Could not lock mutex to THREAD_SENDER")
        .deref()
    {
        Some(thread_record_sender) => {
            thread_record_sender
                .send(CommandTuner::Stop)
                .expect("Could not send command");
            true
        }
        None => false,
    }
}

pub fn tuner_compute_freq_from_ringbuffer() -> Option<f32> {
    let input_sample_rate: usize = *INPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to INPUT_SAMPLE_RATE");

    match RING_DATA.lock().as_deref_mut() {
        Ok(ring_data) => {
            match RING_CONSUMER
                .lock()
                .expect("Could not lock mutex to RING_CONSUMER")
                .deref_mut()
            {
                Some(ring_consumer) => {
                    if !ring_consumer.is_full() {
                        return None;
                    }
                    for s in ring_data.iter_mut() {
                        match ring_consumer.shift() {
                            Some((_index, sample)) => *s = sample,
                            None => break,
                        }
                    }
                }
                None => return None,
            }

            let mut detector: YINDetector<f32> =
                YINDetector::new(ring_data.len(), ring_data.len() / 2);
            match detector.get_pitch(
                ring_data,
                input_sample_rate,
                POWER_THRESHOLD,
                CLARITY_THRESHOLD,
            ) {
                Some(pitch) => Some(pitch.frequency),
                None => Some(-1.0),
            }
        }
        Err(_) => None,
    }
}
