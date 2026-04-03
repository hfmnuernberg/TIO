#![allow(unused)]

use pitch_shift::PitchShifter;
use std::f32::consts::PI;

use crate::api::util::constants::{PITCH_SHIFT_BUFFER_SIZE, PITCH_SHIFT_OVERSAMPLING};
use crate::api::util::util_functions::speed_factor_to_halftones;

const TEST_SAMPLE_RATE: usize = 44100;
const TEST_WINDOW_MS: usize = 70;
const TEST_FREQUENCY: f32 = 440.0;
const TEST_DURATION_SECONDS: f32 = 2.0;
const TOLERANCE_HZ: f32 = 2.0;

fn generate_sine_wave(frequency: f32, sample_rate: usize, num_samples: usize) -> Vec<f32> {
    (0..num_samples)
        .map(|i| (2.0 * PI * frequency * i as f32 / sample_rate as f32).sin())
        .collect()
}

fn read_at_speed(source: &[f32], speed: f32, num_output_samples: usize) -> Vec<f32> {
    let mut output = Vec::with_capacity(num_output_samples);
    let mut pos: f32 = 0.0;
    for _ in 0..num_output_samples {
        let idx = pos.floor() as usize;
        let frac = pos - pos.floor();
        if idx + 1 < source.len() {
            let sample = source[idx] * (1.0 - frac) + source[idx + 1] * frac;
            output.push(sample);
        } else {
            output.push(0.0);
        }
        pos += speed;
    }
    output
}

fn measure_frequency_by_zero_crossings(samples: &[f32], sample_rate: usize) -> f32 {
    let skip = sample_rate / 4;
    if samples.len() < skip + sample_rate / 2 {
        return 0.0;
    }
    let analysis_samples = &samples[skip..];
    let mut crossings = 0u32;
    for i in 1..analysis_samples.len() {
        if (analysis_samples[i - 1] >= 0.0) != (analysis_samples[i] >= 0.0) {
            crossings += 1;
        }
    }
    crossings as f32 / 2.0 * sample_rate as f32 / (analysis_samples.len() - 1) as f32
}

fn run_pitch_shift_pipeline(speed: f32, pitch_semitones: f32) -> f32 {
    let num_source_samples = (TEST_SAMPLE_RATE as f32 * TEST_DURATION_SECONDS * speed) as usize;
    let source = generate_sine_wave(TEST_FREQUENCY, TEST_SAMPLE_RATE, num_source_samples);

    let num_output_samples = (TEST_SAMPLE_RATE as f32 * TEST_DURATION_SECONDS) as usize;
    let sped_up = read_at_speed(&source, speed, num_output_samples);

    let shift_semitones = pitch_semitones - speed_factor_to_halftones(speed);

    let mut pitch_shifter = PitchShifter::new(TEST_WINDOW_MS, TEST_SAMPLE_RATE);
    let mut output = Vec::with_capacity(num_output_samples);
    let mut in_buf = vec![0.0f32; PITCH_SHIFT_BUFFER_SIZE];
    let mut out_buf = vec![0.0f32; PITCH_SHIFT_BUFFER_SIZE];

    for chunk in sped_up.chunks(PITCH_SHIFT_BUFFER_SIZE) {
        in_buf[..chunk.len()].copy_from_slice(chunk);
        if chunk.len() < PITCH_SHIFT_BUFFER_SIZE {
            in_buf[chunk.len()..].fill(0.0);
        }
        pitch_shifter.shift_pitch(
            PITCH_SHIFT_OVERSAMPLING,
            shift_semitones,
            &in_buf,
            &mut out_buf,
        );
        output.extend_from_slice(&out_buf[..chunk.len()]);
    }

    measure_frequency_by_zero_crossings(&output, TEST_SAMPLE_RATE)
}

#[test]
fn pitch_is_preserved_at_double_speed() {
    let measured = run_pitch_shift_pipeline(2.0, 0.0);
    let error = (measured - TEST_FREQUENCY).abs();
    assert!(
        error < TOLERANCE_HZ,
        "At 2.0x speed: expected ~{TEST_FREQUENCY} Hz, got {measured:.1} Hz (error: {error:.1} Hz)"
    );
}

#[test]
fn pitch_is_preserved_at_half_speed() {
    let measured = run_pitch_shift_pipeline(0.5, 0.0);
    let error = (measured - TEST_FREQUENCY).abs();
    assert!(
        error < TOLERANCE_HZ,
        "At 0.5x speed: expected ~{TEST_FREQUENCY} Hz, got {measured:.1} Hz (error: {error:.1} Hz)"
    );
}

#[test]
fn pitch_is_preserved_at_one_and_a_half_speed() {
    let measured = run_pitch_shift_pipeline(1.5, 0.0);
    let error = (measured - TEST_FREQUENCY).abs();
    assert!(
        error < TOLERANCE_HZ,
        "At 1.5x speed: expected ~{TEST_FREQUENCY} Hz, got {measured:.1} Hz (error: {error:.1} Hz)"
    );
}
