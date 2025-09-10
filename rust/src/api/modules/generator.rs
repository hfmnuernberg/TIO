use std::f32::consts::PI;
use std::sync::Mutex;
use std::sync::mpsc::{Receiver, Sender, channel};
use std::thread::{self, JoinHandle};
use std::time::Duration;

use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use lazy_static::__Deref;

use crate::api::audio::global::GLOBAL_AUDIO_LOCK;
use crate::api::util::constants::{AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, OUTPUT_SAMPLE_RATE};
use crate::api::util::util_functions::get_platform_default_cpal_output_config;

extern crate indexed_ring_buffer;

// DATA

struct GeneratorValuesInterpolated {
    freq_target: f32,
    freq: f32,
    amp_target: f32,
    amp: f32,
}
impl GeneratorValuesInterpolated {
    fn new() -> Self {
        Self {
            freq_target: 440.0,
            freq: 440.0,
            amp: 0.0,
            amp_target: 0.0,
        }
    }
    fn set_freq(&mut self, freq: f32) {
        self.freq_target = freq;
        if self.amp < 0.001 {
            self.freq = freq;
        }
    }
    fn set_amp(&mut self, amp: f32) {
        self.amp_target = amp;
    }
    fn stop(&mut self) {
        self.freq_target = 440.0;
        self.freq = 440.0;
        self.amp_target = 0.0;
        self.amp = 0.0;
    }

    fn next(&mut self) -> (f32, f32) {
        // freq, amp, sample_index
        self.freq += (self.freq_target - self.freq) * 0.005;
        self.amp += (self.amp_target - self.amp) * 0.002;
        (self.freq, self.amp)
    }
}

static PHASE: Mutex<f64> = Mutex::new(0.0);

static THREAD: Mutex<Option<JoinHandle<()>>> = Mutex::new(None);
static THREAD_SENDER: Mutex<Option<Sender<CommandGenerator>>> = Mutex::new(None);

static GENERATOR_GLOBAL_AMP: f32 = 0.8;
lazy_static! {
    static ref VALUES: Mutex<GeneratorValuesInterpolated> =
        Mutex::new(GeneratorValuesInterpolated::new());
}

// COMMANDS

enum CommandGenerator {
    Stop,
}

// FUNCTIONS

#[flutter_rust_bridge::frb(ignore)]
pub fn generator_create_audio_stream() -> bool {
    generator_trigger_destroy_stream();

    let host = cpal::default_host();
    let device = host
        .default_output_device()
        .expect("no output device available");

    let config = get_platform_default_cpal_output_config(&device);
    if config.is_none() {
        log::info!("Could not start generator output stream - Could not get default output config");
        return false;
    }
    let config = config.expect("Could not get default stream output config");

    VALUES
        .lock()
        .expect("Could not lock mutex to VALUES to set new value")
        .stop();

    let (tx, rx): (Sender<CommandGenerator>, Receiver<CommandGenerator>) = channel();
    let join_handle = thread::spawn(move || {
        let stream_out = device
            .build_output_stream(
                &config,
                on_audio_callback,
                move |_| {
                    log::info!("something went wrong with the audio stream");
                },
                Some(Duration::from_secs(AUDIO_STREAM_CREATE_TIMEOUT_SECONDS)),
            )
            .expect("Could not create output stream");
        stream_out.play().expect("Could not play stream");

        while let Ok(command) = rx.recv() {
            // this waits until stop is sent
            thread_handle_command(command);
        }
    });
    *THREAD.lock().expect("Could not lock mutex to THREAD") = Some(join_handle);
    *THREAD_SENDER
        .lock()
        .expect("Could not lock mutex to THREAD_SENDER") = Some(tx);
    true
}

fn on_audio_callback(data: &mut [f32], _: &cpal::OutputCallbackInfo) {
    let mut values = VALUES
        .lock()
        .expect("Could not lock mutex to VALUES to read it in on_audio_callback");

    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to OUTPUT_SAMPLE_RATE");

    let mut phase = PHASE
        .lock()
        .expect("Could not lock mutex to OUTPUT_SAMPLE_COUNT");

    for data in data.iter_mut() {
        let (freq, amp) = values.next();
        if amp < 0.01 {
            *data = 0.0;
            continue;
        }

        *phase += freq as f64 * 2.0 * PI as f64 / (sample_rate as f64);
        *data = phase.sin() as f32 * amp * GENERATOR_GLOBAL_AMP;
    }
}

fn thread_handle_command(command: CommandGenerator) {
    match command {
        CommandGenerator::Stop => {
            let _guard = GLOBAL_AUDIO_LOCK
                .lock()
                .expect("Could not lock global audio lock");
            *THREAD_SENDER
                .lock()
                .expect("Could not lock mutex to THREAD_SENDER to clear") = None;
            *THREAD
                .lock()
                .expect("Could not lock mutex to THREAD to clear") = None;
            VALUES
                .lock()
                .expect("Could not lock mutex to VALUES to set new value")
                .set_amp(0.0);
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn generator_trigger_destroy_stream() -> bool {
    match THREAD_SENDER
        .lock()
        .expect("Could not lock mutex to THREAD_SENDER")
        .deref()
    {
        Some(thread_record_sender) => {
            match thread_record_sender.send(CommandGenerator::Stop) {
                Ok(_) => {}
                Err(_) => {
                    log::info!("Could not send stop command to generator thread");
                    return false;
                }
            }
            true
        }
        None => false,
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn generator_start_note(new_freq: f32) -> bool {
    VALUES
        .lock()
        .expect("Could not lock mutex to VALUES to set new value")
        .set_freq(new_freq);
    VALUES
        .lock()
        .expect("Could not lock mutex to VALUES to set new value")
        .set_amp(1.0);
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn generator_stop_current_note() -> bool {
    VALUES
        .lock()
        .expect("Could not lock mutex to VALUES to set new value")
        .set_amp(0.0);
    true
}
