use std::{
    fs::File,
    io::BufWriter,
    sync::{
        Mutex,
        atomic::{AtomicUsize, Ordering},
        mpsc::{Receiver, Sender, channel},
    },
    thread::{self, JoinHandle},
    time::Duration,
};

use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use hound::{SampleFormat, WavSpec, WavWriter};
use lazy_static::__Deref;

use crate::{
    api::audio::global::GLOBAL_AUDIO_LOCK,
    api::util::{
        constants::{AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, INPUT_SAMPLE_RATE},
        util_functions::get_platform_default_cpal_input_config,
    },
};

static THREAD: Mutex<Option<JoinHandle<()>>> = Mutex::new(None);
static THREAD_SENDER: Mutex<Option<Sender<CommandRecorder>>> = Mutex::new(None);
static RECORDING_WRITER: Mutex<Option<WavWriter<BufWriter<File>>>> = Mutex::new(None);
static RECORDING_FILE_PATH: Mutex<Option<String>> = Mutex::new(None);
static RECORDING_SAMPLE_COUNT: AtomicUsize = AtomicUsize::new(0);

enum CommandRecorder {
    Stop,
}

#[flutter_rust_bridge::frb(ignore)]
pub fn recorder_create_stream(file_path: String) -> bool {
    recorder_trigger_destroy_stream();

    let host = cpal::default_host();
    let device = host
        .default_input_device()
        .expect("no input device available");

    let config = get_platform_default_cpal_input_config(&device);
    if config.is_none() {
        log::info!("Could not start recorder input stream - Could not get default input config");
        return false;
    }
    let config = config.expect("Could not get default input config");

    let sample_rate = *INPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock INPUT_SAMPLE_RATE") as u32;

    let spec = WavSpec {
        channels: 1,
        sample_rate,
        bits_per_sample: 32,
        sample_format: SampleFormat::Float,
    };

    let writer = match WavWriter::create(&file_path, spec) {
        Ok(w) => w,
        Err(e) => {
            log::info!("Could not create WAV writer: {}", e);
            return false;
        }
    };

    *RECORDING_WRITER
        .lock()
        .expect("Could not lock RECORDING_WRITER") = Some(writer);
    *RECORDING_FILE_PATH
        .lock()
        .expect("Could not lock RECORDING_FILE_PATH") = Some(file_path);
    RECORDING_SAMPLE_COUNT.store(0, Ordering::Relaxed);

    let (tx, rx): (Sender<CommandRecorder>, Receiver<CommandRecorder>) = channel();

    let join_handle = thread::spawn(move || {
        let stream_in = device
            .build_input_stream(
                &config,
                on_audio_callback,
                move |_| {
                    log::info!("something went wrong with the audio stream");
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
    let mut writer_guard = RECORDING_WRITER
        .lock()
        .expect("Could not lock mutex to RECORDING_WRITER");

    if let Some(ref mut writer) = *writer_guard {
        for &sample in data {
            if writer.write_sample(sample).is_err() {
                log::info!("Failed to write sample to WAV file");
                return;
            }
        }
        RECORDING_SAMPLE_COUNT.fetch_add(data.len(), Ordering::Relaxed);
    }
}

fn handle_command(command: CommandRecorder) {
    match command {
        CommandRecorder::Stop => {
            let _guard = GLOBAL_AUDIO_LOCK
                .lock()
                .expect("Could not lock global audio lock");

            if let Some(writer) = RECORDING_WRITER
                .lock()
                .expect("Could not lock RECORDING_WRITER to finalize")
                .take()
                && let Err(e) = writer.finalize()
            {
                log::info!("Failed to finalize WAV file: {}", e);
            }

            *THREAD_SENDER
                .lock()
                .expect("Could not lock mutex to THREAD_SENDER to clear") = None;
            *THREAD
                .lock()
                .expect("Could not lock mutex to THREAD to clear") = None;
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn recorder_trigger_destroy_stream() -> bool {
    match THREAD_SENDER
        .lock()
        .expect("Could not lock mutex to THREAD_SENDER")
        .deref()
    {
        Some(thread_record_sender) => {
            match thread_record_sender.send(CommandRecorder::Stop) {
                Ok(_) => {}
                Err(_) => {
                    log::info!("Could not send command to stop recorder");
                    return false;
                }
            }

            true
        }
        None => {
            log::info!("Failed to send command to stop recorder");
            false
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn recorder_get_sample_count() -> usize {
    RECORDING_SAMPLE_COUNT.load(Ordering::Relaxed)
}

#[flutter_rust_bridge::frb(ignore)]
pub fn recorder_get_recording_file_path() -> Option<String> {
    RECORDING_FILE_PATH
        .lock()
        .expect("Could not lock RECORDING_FILE_PATH")
        .clone()
}
