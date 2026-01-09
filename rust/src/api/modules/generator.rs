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
// Harmonic enrichment for better audibility of low fundamentals on small speakers.
// Keeps the true fundamental frequency present, and adds quiet harmonics.
static GENERATOR_HARMONICS_ENABLED: bool = true;

// Harmonic enrichment ramp:
// - at/above GENERATOR_HARMONICS_START_HZ: no added harmonics
// - between START and CURVE_START: linear ramp (gentle)
// - between CURVE_START and FULL: quadratic ease-out (stronger for very low frequencies)
// - at/below GENERATOR_HARMONICS_FULL_HZ: full harmonic mix
static GENERATOR_HARMONICS_START_HZ: f32 = 250.0;
static GENERATOR_HARMONICS_CURVE_START_HZ: f32 = 130.0;
static GENERATOR_HARMONICS_FULL_HZ: f32 = 20.0;

// Relative amplitudes for harmonics (added on top of the fundamental).
// These are multiplied by the ramp factor (0..1).
static GENERATOR_H2: f32 = 0.60;
static GENERATOR_H3: f32 = 0.35;
// Optional 4th harmonic kept subtle; helps audibility on tiny speakers.
static GENERATOR_H4: f32 = 0.15;
// Optional 5th harmonic kept very subtle; can help audibility on tiny speakers.
static GENERATOR_H5: f32 = 0.10;

#[inline]
fn harmonic_ramp(freq: f32) -> f32 {
    // Returns 0..1 where 1 means full harmonics.
    // We keep the original linear behavior above 130Hz, then ramp faster below 130Hz.

    // Guard against invalid configs.
    if GENERATOR_HARMONICS_FULL_HZ >= GENERATOR_HARMONICS_START_HZ {
        return if freq < GENERATOR_HARMONICS_START_HZ {
            1.0
        } else {
            0.0
        };
    }
    if GENERATOR_HARMONICS_CURVE_START_HZ >= GENERATOR_HARMONICS_START_HZ {
        // If curve start is misconfigured, fall back to a simple linear ramp.
        let t = (GENERATOR_HARMONICS_START_HZ - freq)
            / (GENERATOR_HARMONICS_START_HZ - GENERATOR_HARMONICS_FULL_HZ);
        return t.clamp(0.0, 1.0);
    }
    if GENERATOR_HARMONICS_FULL_HZ >= GENERATOR_HARMONICS_CURVE_START_HZ {
        // If FULL is misconfigured, fall back to linear.
        let t = (GENERATOR_HARMONICS_START_HZ - freq)
            / (GENERATOR_HARMONICS_START_HZ - GENERATOR_HARMONICS_FULL_HZ);
        return t.clamp(0.0, 1.0);
    }

    // No harmonics at/above START.
    if freq >= GENERATOR_HARMONICS_START_HZ {
        return 0.0;
    }

    // Linear segment from START -> CURVE_START.
    if freq >= GENERATOR_HARMONICS_CURVE_START_HZ {
        let t = (GENERATOR_HARMONICS_START_HZ - freq)
            / (GENERATOR_HARMONICS_START_HZ - GENERATOR_HARMONICS_CURVE_START_HZ);
        return t.clamp(0.0, 1.0);
    }

    // Below CURVE_START we continue from whatever the linear segment reached at CURVE_START.
    // At CURVE_START the linear ramp equals 1.0 * (segment complete) => 1.0 for that segment,
    // but overall we want continuity with the original START->FULL mapping.
    // Compute the original linear value at CURVE_START (same as old behavior for >130Hz).
    let ramp_at_curve_start = (GENERATOR_HARMONICS_START_HZ - GENERATOR_HARMONICS_CURVE_START_HZ)
        / (GENERATOR_HARMONICS_START_HZ - GENERATOR_HARMONICS_FULL_HZ);

    // Curved segment from CURVE_START -> FULL (cubic ease-out: stronger for very low frequencies).
    let t = (GENERATOR_HARMONICS_CURVE_START_HZ - freq)
        / (GENERATOR_HARMONICS_CURVE_START_HZ - GENERATOR_HARMONICS_FULL_HZ);
    let t = t.clamp(0.0, 1.0);
    let ease_out = 1.0 - (1.0 - t) * (1.0 - t) * (1.0 - t);

    (ramp_at_curve_start + (1.0 - ramp_at_curve_start) * ease_out).clamp(0.0, 1.0)
}

#[inline]
fn generator_sample_with_harmonics(phase: f64, freq: f32) -> f32 {
    // `phase` is the fundamental phase in radians.
    // Harmonics ramp in linearly from 300Hz down to 20Hz.
    if !GENERATOR_HARMONICS_ENABLED {
        return phase.sin() as f32;
    }

    let ramp = harmonic_ramp(freq);
    if ramp <= 0.0 {
        return phase.sin() as f32;
    }

    let s1 = phase.sin() as f32;
    let s2 = (2.0 * phase).sin() as f32;
    let s3 = (3.0 * phase).sin() as f32;
    let s4 = (4.0 * phase).sin() as f32;
    let s5 = (5.0 * phase).sin() as f32;

    // Fundamental stays at 1.0, harmonics are scaled by `ramp`.
    let h2 = GENERATOR_H2 * ramp;
    let h3 = GENERATOR_H3 * ramp;
    let h4 = GENERATOR_H4 * ramp;
    let h5 = GENERATOR_H5 * ramp;

    // Normalize so output level stays roughly comparable across the ramp.
    let norm = 1.0 / (1.0 + h2 + h3 + h4 + h5);

    (s1 + h2 * s2 + h3 * s3 + h4 * s4 + h5 * s5) * norm
}
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

        // Keep the phase bounded to avoid precision loss on very long runs.
        if *phase > 2.0 * PI as f64 {
            *phase %= 2.0 * PI as f64;
        }

        let sample = generator_sample_with_harmonics(*phase, freq);
        *data = sample * amp * GENERATOR_GLOBAL_AMP;
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
