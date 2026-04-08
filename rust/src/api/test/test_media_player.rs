#[allow(unused)]
use crate::api::modules::media_player::{
    media_player_compute_rms, media_player_destroy, media_player_query_state,
    media_player_set_file_source, media_player_set_loop_value, media_player_set_new_volume,
    media_player_set_pitch, media_player_set_speed, media_player_set_trim_by_factor,
};

use hound::{SampleFormat, WavSpec, WavWriter};
use std::io::BufWriter;

#[allow(dead_code)]
fn write_test_wav(path: &str, samples: &[f32]) {
    let spec = WavSpec {
        channels: 1,
        sample_rate: 44100,
        bits_per_sample: 32,
        sample_format: SampleFormat::Float,
    };
    let mut writer =
        WavWriter::new(BufWriter::new(std::fs::File::create(path).unwrap()), spec).unwrap();
    for &s in samples {
        writer.write_sample(s).unwrap();
    }
    writer.finalize().unwrap();
}

#[allow(dead_code)]
fn set_buffer_via_file(id: u32, samples: &[f32]) -> String {
    let path = format!(
        "{}/test_media_player_{}.wav",
        std::env::temp_dir().display(),
        id
    );
    write_test_wav(&path, samples);
    media_player_set_file_source(id, &path, samples.len() as u64);
    path
}

#[test]
fn two_instances_store_independent_buffers() {
    let path_0 = set_buffer_via_file(0, &vec![0.5; 100]);
    let path_1 = set_buffer_via_file(1, &vec![0.25; 200]);

    let state_0 = media_player_query_state(0).expect("state for id=0");
    let state_1 = media_player_query_state(1).expect("state for id=1");

    assert!(
        (state_0.total_length_seconds - state_1.total_length_seconds).abs() > f32::EPSILON,
        "Different buffers should produce different durations"
    );

    media_player_destroy(0);
    media_player_destroy(1);
    let _ = std::fs::remove_file(path_0);
    let _ = std::fs::remove_file(path_1);
}

#[test]
fn settings_on_one_do_not_affect_other() {
    let path_10 = set_buffer_via_file(10, &vec![1.0; 100]);
    let path_11 = set_buffer_via_file(11, &vec![1.0; 100]);

    media_player_set_new_volume(10, 0.5);
    media_player_set_pitch(10, 3.0);
    media_player_set_speed(10, 2.0);
    media_player_set_trim_by_factor(10, 0.1, 0.9);
    media_player_set_loop_value(10, true);

    let state_11 = media_player_query_state(11).expect("state for id=11");

    assert!(!state_11.looping, "id=11 looping should still be false");
    assert!(
        (state_11.trim_start_factor - 0.0).abs() < f32::EPSILON,
        "id=11 trim start should still be 0.0"
    );
    assert!(
        (state_11.trim_end_factor - 1.0).abs() < f32::EPSILON,
        "id=11 trim end should still be 1.0"
    );

    media_player_destroy(10);
    media_player_destroy(11);
    let _ = std::fs::remove_file(path_10);
    let _ = std::fs::remove_file(path_11);
}

#[test]
fn destroy_removes_instance() {
    let path = set_buffer_via_file(20, &vec![1.0; 100]);
    let state = media_player_query_state(20).expect("state for id=20");
    assert!(state.total_length_seconds > 0.0);

    media_player_destroy(20);

    let state_after = media_player_query_state(20).expect("state for id=20 after destroy");
    assert!(
        state_after.total_length_seconds == 0.0,
        "After destroy, a fresh default instance should have zero length"
    );

    media_player_destroy(20);
    let _ = std::fs::remove_file(path);
}

#[test]
fn rms_computation_is_independent() {
    let path_30 = set_buffer_via_file(30, &vec![1.0; 100]);
    let path_31 = set_buffer_via_file(31, &vec![0.0; 100]);

    let rms_30 = media_player_compute_rms(30, 10);
    let rms_31 = media_player_compute_rms(31, 10);

    assert_eq!(rms_30.len(), 10);
    assert_eq!(rms_31.len(), 10);

    assert!(rms_30[0] > 0.0, "Buffer of 1.0 should have non-zero RMS");
    assert!(rms_31[0] == 0.0, "Buffer of 0.0 should have zero RMS");

    media_player_destroy(30);
    media_player_destroy(31);
    let _ = std::fs::remove_file(path_30);
    let _ = std::fs::remove_file(path_31);
}
