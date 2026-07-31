#[allow(unused)]
use crate::api::audio::audio_buffer_interpolated::AudioBufferInterpolated;
#[allow(unused)]
use crate::api::audio::output_buffer_tracker::OutputBufferTracker;

use hound::{SampleFormat, WavSpec, WavWriter};
use std::io::BufWriter;

const TOTAL_SAMPLES: u64 = 1_000;

#[allow(dead_code)]
fn buffer_of_1000_samples(name: &str) -> (AudioBufferInterpolated, String) {
    buffer_of_samples(name, TOTAL_SAMPLES)
}

#[allow(dead_code)]
fn buffer_of_samples(name: &str, total_samples: u64) -> (AudioBufferInterpolated, String) {
    let path = format!(
        "{}/test_audio_buffer_interpolated_{}.wav",
        std::env::temp_dir().display(),
        name
    );
    let spec = WavSpec {
        channels: 1,
        sample_rate: 44100,
        bits_per_sample: 32,
        sample_format: SampleFormat::Float,
    };
    let mut writer =
        WavWriter::new(BufWriter::new(std::fs::File::create(&path).unwrap()), spec).unwrap();
    for _ in 0..total_samples {
        writer.write_sample(0.5f32).unwrap();
    }
    writer.finalize().unwrap();

    (
        AudioBufferInterpolated::new_from_file(&path, total_samples),
        path,
    )
}

#[allow(dead_code)]
fn assert_factor(actual: f32, expected: f32) {
    assert!(
        (actual - expected).abs() < 1e-4,
        "expected position factor {expected}, got {actual}"
    );
}

#[test]
fn position_behind_the_read_head_is_where_playback_is_audible() {
    let (mut buffer, path) = buffer_of_1000_samples("audible");
    buffer.set_playback_position_factor(0.5);

    assert_factor(buffer.get_playback_position_factor_behind_by(100.0), 0.4);

    let _ = std::fs::remove_file(path);
}

#[test]
fn position_behind_the_read_head_never_precedes_the_trim_start() {
    let (mut buffer, path) = buffer_of_1000_samples("clamped");
    buffer.set_trim(0.2, 0.8);
    buffer.set_playback_position_factor(0.25);

    assert_factor(buffer.get_playback_position_factor_behind_by(100.0), 0.2);

    let _ = std::fs::remove_file(path);
}

#[test]
fn position_behind_the_read_head_wraps_into_the_trim_range_when_looping() {
    let (mut buffer, path) = buffer_of_1000_samples("wrapped");
    buffer.set_trim(0.2, 0.8);
    buffer.set_loop(true);
    buffer.set_playback_position_factor(0.25);

    assert_factor(buffer.get_playback_position_factor_behind_by(100.0), 0.75);

    let _ = std::fs::remove_file(path);
}

#[test]
fn position_behind_the_read_head_is_zero_without_a_loaded_file() {
    let buffer = AudioBufferInterpolated::new_empty();

    assert_factor(buffer.get_playback_position_factor_behind_by(100.0), 0.0);
}

#[allow(dead_code)]
const RING_CAPACITY: u64 = 2_000;
#[allow(dead_code)]
const CHUNK_SIZE: usize = 64;
#[allow(dead_code)]
const SAMPLES_PER_AUDIO_CALLBACK: u64 = 128;

#[test]
fn reported_position_follows_the_audio_that_has_been_played_not_the_read_head() {
    let (mut buffer, path) = buffer_of_samples("playback", 20_000);
    let tracker = OutputBufferTracker::new();
    buffer.set_playing(true);

    let mut chunk = vec![0.0f32; CHUNK_SIZE];
    let mut ring_fill: u64 = 0;
    let mut samples_played: u64 = 0;

    for _ in 0..100 {
        while ring_fill < RING_CAPACITY {
            buffer.get_samples(&mut chunk, 1.0);
            tracker.record_produced(CHUNK_SIZE);
            ring_fill += CHUNK_SIZE as u64;
        }

        let played = SAMPLES_PER_AUDIO_CALLBACK.min(ring_fill);
        ring_fill -= played;
        tracker.record_consumed(played as usize);
        samples_played += played;

        let reported =
            buffer.get_playback_position_factor_behind_by(tracker.buffered_samples() as f64);
        assert_factor(reported, samples_played as f32 / 20_000.0);
    }

    let _ = std::fs::remove_file(path);
}

#[test]
fn reported_position_holds_at_the_seek_target_while_stale_audio_drains() {
    let (mut buffer, path) = buffer_of_samples("seek", 20_000);
    let tracker = OutputBufferTracker::new();
    buffer.set_playing(true);

    let mut chunk = vec![0.0f32; CHUNK_SIZE];
    while tracker.buffered_samples() < RING_CAPACITY {
        buffer.get_samples(&mut chunk, 1.0);
        tracker.record_produced(CHUNK_SIZE);
    }

    buffer.set_playback_position_factor(0.5);
    tracker.discard_buffered();

    let reported = buffer.get_playback_position_factor_behind_by(tracker.buffered_samples() as f64);
    assert_factor(reported, 0.5);

    let _ = std::fs::remove_file(path);
}

#[test]
fn rewinding_moves_the_read_head_back_to_the_last_audible_sample() {
    let (mut buffer, path) = buffer_of_1000_samples("rewind");
    buffer.set_playback_position_factor(0.5);

    buffer.rewind_read_head_by(100.0);

    assert_factor(buffer.get_playback_position_factor(), 0.4);

    let _ = std::fs::remove_file(path);
}

#[test]
fn rewinding_wraps_into_the_trim_range_when_looping() {
    let (mut buffer, path) = buffer_of_1000_samples("rewind_wrapped");
    buffer.set_trim(0.2, 0.8);
    buffer.set_loop(true);
    buffer.set_playback_position_factor(0.25);

    buffer.rewind_read_head_by(100.0);

    assert_factor(buffer.get_playback_position_factor(), 0.75);

    let _ = std::fs::remove_file(path);
}

#[test]
fn rewinding_never_moves_the_read_head_before_the_trim_start() {
    let (mut buffer, path) = buffer_of_1000_samples("rewind_clamped");
    buffer.set_trim(0.2, 0.8);
    buffer.set_playback_position_factor(0.25);

    buffer.rewind_read_head_by(100.0);

    assert_factor(buffer.get_playback_position_factor(), 0.2);

    let _ = std::fs::remove_file(path);
}
