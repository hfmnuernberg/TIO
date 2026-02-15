use pitch_shift::PitchShifter;

use crate::api::audio::audio_buffer_interpolated::AudioBufferInterpolated;
use crate::api::util::constants::{
    PITCH_SHIFT_BUFFER_SIZE, PITCH_SHIFT_OVERSAMPLING, PITCH_SHIFT_WINDOW_DUR_MILLIS,
};
use crate::api::util::util_functions::speed_factor_to_halftones;

/// Renders audio samples with pitch, speed, trim, and volume applied offline.
/// Returns a fully processed `Vec<f32>` ready for playback.
#[flutter_rust_bridge::frb(ignore)]
pub fn render_processed_audio(
    samples: Vec<f32>,
    sample_rate: usize,
    pitch_semitones: f32,
    speed_factor: f32,
    trim_start_factor: f32,
    trim_end_factor: f32,
    volume: f32,
) -> Vec<f32> {
    if samples.is_empty() {
        return vec![];
    }

    let estimated_output_len = estimate_output_length(
        samples.len(),
        speed_factor,
        trim_start_factor,
        trim_end_factor,
    );
    let mut output = Vec::with_capacity(estimated_output_len);

    let mut source = AudioBufferInterpolated::new(samples);
    source.set_trim(trim_start_factor, trim_end_factor);
    source.set_playing(true);

    let needs_pitch_shift = needs_pitch_processing(pitch_semitones, speed_factor);

    let mut pitch_shifter = PitchShifter::new(PITCH_SHIFT_WINDOW_DUR_MILLIS, sample_rate);
    let mut input_chunk = [0.0f32; PITCH_SHIFT_BUFFER_SIZE];
    let mut output_chunk = [0.0f32; PITCH_SHIFT_BUFFER_SIZE];

    loop {
        source.get_samples(&mut input_chunk, speed_factor);

        if !source.get_is_playing() {
            break;
        }

        if needs_pitch_shift {
            let semitones = pitch_semitones - speed_factor_to_halftones(speed_factor);
            pitch_shifter.shift_pitch(
                PITCH_SHIFT_OVERSAMPLING,
                semitones,
                &input_chunk,
                &mut output_chunk,
            );
        } else {
            output_chunk.copy_from_slice(&input_chunk);
        }

        for sample in &output_chunk {
            output.push(sample * volume);
        }
    }

    output
}

fn needs_pitch_processing(pitch_semitones: f32, speed_factor: f32) -> bool {
    (speed_factor - 1.0).abs() >= f32::EPSILON || pitch_semitones.abs() >= f32::EPSILON
}

fn estimate_output_length(
    sample_count: usize,
    speed_factor: f32,
    trim_start_factor: f32,
    trim_end_factor: f32,
) -> usize {
    let trimmed_fraction = (trim_end_factor - trim_start_factor).max(0.0);
    let trimmed_samples = (sample_count as f32 * trimmed_fraction) as usize;
    ((trimmed_samples as f32 / speed_factor) * 1.1) as usize
}
