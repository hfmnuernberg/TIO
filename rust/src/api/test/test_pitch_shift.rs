#![allow(unused)]

use pitch_shift::PitchShifter;
use std::f32::consts::PI;

use crate::api::util::constants::{PITCH_SHIFT_BUFFER_SIZE, PITCH_SHIFT_OVERSAMPLING};
use crate::api::util::util_functions::speed_factor_to_halftones;

const TEST_SAMPLE_RATE: usize = 48000;
const TEST_WINDOW_MS: usize = 70;
const TEST_FREQUENCY: f32 = 440.0;
const TOLERANCE_HZ: f32 = 2.0;

fn generate_sine_wave(frequency: f32, sample_rate: usize, num_samples: usize) -> Vec<f32> {
    (0..num_samples)
        .map(|i| (2.0 * PI * frequency * i as f32 / sample_rate as f32).sin())
        .collect()
}

fn read_at_speed(source: &[f32], speed: f32, num_output_samples: usize) -> Vec<f32> {
    let mut output = Vec::with_capacity(num_output_samples);
    let mut pos: f64 = 0.0;
    let speed_f64 = speed as f64;
    for _ in 0..num_output_samples {
        let idx = pos.floor() as usize;
        let frac = (pos - pos.floor()) as f32;
        if idx + 1 < source.len() {
            let sample = source[idx] * (1.0 - frac) + source[idx + 1] * frac;
            output.push(sample);
        } else {
            output.push(0.0);
        }
        pos += speed_f64;
    }
    output
}

fn read_at_speed_looping(source: &[f32], speed: f32, num_output_samples: usize) -> Vec<f32> {
    let mut output = Vec::with_capacity(num_output_samples);
    let mut pos: f64 = 0.0;
    let speed_f64 = speed as f64;
    let end = source.len() as f64;
    for _ in 0..num_output_samples {
        let idx = pos.floor() as usize;
        let frac = (pos - pos.floor()) as f32;
        if idx + 1 < source.len() {
            let sample = source[idx] * (1.0 - frac) + source[idx + 1] * frac;
            output.push(sample);
        } else {
            let sample = source[idx % source.len()] * (1.0 - frac) + source[0] * frac;
            output.push(sample);
        }
        pos += speed_f64;
        if pos >= end {
            pos -= end;
        }
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

fn process_through_pitch_shifter(
    input: &[f32],
    shift_semitones: f32,
    sample_rate: usize,
) -> Vec<f32> {
    let mut pitch_shifter = PitchShifter::new(TEST_WINDOW_MS, sample_rate);
    let mut output = Vec::with_capacity(input.len());
    let mut in_buf = vec![0.0f32; PITCH_SHIFT_BUFFER_SIZE];
    let mut out_buf = vec![0.0f32; PITCH_SHIFT_BUFFER_SIZE];

    for chunk in input.chunks(PITCH_SHIFT_BUFFER_SIZE) {
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

    output
}

fn run_pitch_shift_pipeline(speed: f32, pitch_semitones: f32) -> f32 {
    let duration = 2.0_f32;
    let num_source = (TEST_SAMPLE_RATE as f32 * duration * speed) as usize;
    let source = generate_sine_wave(TEST_FREQUENCY, TEST_SAMPLE_RATE, num_source);
    let num_output = (TEST_SAMPLE_RATE as f32 * duration) as usize;
    let sped_up = read_at_speed(&source, speed, num_output);
    let shift = pitch_semitones - speed_factor_to_halftones(speed);
    let output = process_through_pitch_shifter(&sped_up, shift, TEST_SAMPLE_RATE);
    measure_frequency_by_zero_crossings(&output, TEST_SAMPLE_RATE)
}

fn run_looping_pitch_shift_pipeline(speed: f32) -> f32 {
    let file_duration = 10.0_f32;
    let playback_duration = 20.0_f32;
    let num_source = (TEST_SAMPLE_RATE as f32 * file_duration) as usize;
    let source = generate_sine_wave(TEST_FREQUENCY, TEST_SAMPLE_RATE, num_source);
    let num_output = (TEST_SAMPLE_RATE as f32 * playback_duration) as usize;
    let sped_up = read_at_speed_looping(&source, speed, num_output);
    let shift = -speed_factor_to_halftones(speed);
    let output = process_through_pitch_shifter(&sped_up, shift, TEST_SAMPLE_RATE);
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

#[test]
fn pitch_is_preserved_when_looping_at_various_speeds() {
    let speeds = [1.1, 1.2, 1.3, 1.4, 1.9];
    for speed in speeds {
        let measured = run_looping_pitch_shift_pipeline(speed);
        let error = (measured - TEST_FREQUENCY).abs();
        assert!(
            error < TOLERANCE_HZ,
            "At {speed}x speed (looping): expected ~{TEST_FREQUENCY} Hz, got {measured:.1} Hz (error: {error:.1} Hz)"
        );
    }
}
