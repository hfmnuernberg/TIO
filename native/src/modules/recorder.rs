use std::{
    sync::{
        mpsc::{channel, Receiver, Sender},
        Mutex,
    },
    thread::{self, JoinHandle},
    time::Duration,
};

use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use lazy_static::__Deref;

use crate::{
    audio::global::GLOBAL_AUDIO_LOCK,
    util::{
        constants::AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, debug_log::debug_log,
        util_functions::get_platform_default_cpal_input_config,
    },
};

static THREAD: Mutex<Option<JoinHandle<()>>> = Mutex::new(None);
static THREAD_SENDER: Mutex<Option<Sender<CommandRecorder>>> = Mutex::new(None);
static RECORDING_BUFFER: Mutex<Vec<f32>> = Mutex::new(vec![]);

enum CommandRecorder {
    Stop,
}

pub fn recorder_create_stream() -> bool {
    recorder_trigger_destroy_stream();

    let host = cpal::default_host();
    let device = host
        .default_input_device()
        .expect("no input device available");

    let config = get_platform_default_cpal_input_config(&device);
    if config.is_none() {
        debug_log("Could not start recorder input stream - Could not get default input config");
        return false;
    }
    let config = config.expect("Could not get default input config");

    let (tx, rx): (Sender<CommandRecorder>, Receiver<CommandRecorder>) = channel();

    RECORDING_BUFFER
        .lock()
        .expect("Could not lock RECORDING_BUFFER to empty")
        .clear();

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
    let mut recording_buffer = RECORDING_BUFFER
        .lock()
        .expect("Could not lock mutex to RECORDING_BUFFER");

    for sample in data {
        recording_buffer.push(*sample)
    }
}

fn handle_command(command: CommandRecorder) {
    match command {
        CommandRecorder::Stop => {
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

fn normalize_recording_buffer(buffer: &mut [f32]) {
    let max_sample_option = buffer.iter().max_by(|a, b| {
        a.abs()
            .partial_cmp(&b.abs())
            .expect("Could not compare samples")
    });

    if max_sample_option.is_none() {
        return;
    }

    let max_sample = *max_sample_option.expect("Could not get max sample");

    if max_sample < 0.0001 {
        return;
    }

    let factor = (1.0 / max_sample).clamp(0.0, 50.0);

    for sample in buffer.iter_mut() {
        *sample *= factor;
    }
}

pub fn recorder_trigger_destroy_stream() -> bool {
    match THREAD_SENDER
        .lock()
        .expect("Could not lock mutex to THREAD_SENDER")
        .deref()
    {
        Some(thread_record_sender) => {
            thread_record_sender
                .send(CommandRecorder::Stop)
                .expect("Could not send command");
            true
        }
        None => {
            debug_log("Failed to send command to stop recorder");
            false
        }
    }
}

pub fn recorder_get_buffer_samples() -> Vec<f64> {
    let mut rec_buffer_cloned = RECORDING_BUFFER
        .lock()
        .expect("Could not lock mutex to get RECORDING_BUFFER")
        .clone();

    normalize_recording_buffer(&mut rec_buffer_cloned);

    rec_buffer_cloned
        .iter()
        .map(|sample| *sample as f64)
        .collect()
}
