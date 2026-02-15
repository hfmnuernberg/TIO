#[allow(unused)]
use crate::api::modules::media_player::{
    media_player_compute_rms, media_player_destroy, media_player_query_state,
    media_player_set_buffer, media_player_set_loop_value, media_player_set_new_volume,
    media_player_set_pitch, media_player_set_speed, media_player_set_trim_by_factor,
};

#[test]
fn two_instances_store_independent_buffers() {
    let buffer_0 = vec![0.5; 100];
    let buffer_1 = vec![0.25; 200];

    media_player_set_buffer(0, buffer_0);
    media_player_set_buffer(1, buffer_1);

    let state_0 = media_player_query_state(0).expect("state for id=0");
    let state_1 = media_player_query_state(1).expect("state for id=1");

    assert!(
        (state_0.total_length_seconds - state_1.total_length_seconds).abs() > f32::EPSILON,
        "Different buffers should produce different durations"
    );

    media_player_destroy(0);
    media_player_destroy(1);
}

#[test]
fn settings_on_one_do_not_affect_other() {
    media_player_set_buffer(10, vec![1.0; 100]);
    media_player_set_buffer(11, vec![1.0; 100]);

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
}

#[test]
fn destroy_removes_instance() {
    media_player_set_buffer(20, vec![1.0; 100]);
    let state = media_player_query_state(20).expect("state for id=20");
    assert!(state.total_length_seconds > 0.0);

    media_player_destroy(20);

    let state_after = media_player_query_state(20).expect("state for id=20 after destroy");
    assert!(
        state_after.total_length_seconds == 0.0,
        "After destroy, a fresh default instance should have zero length"
    );

    media_player_destroy(20);
}

#[test]
fn rms_computation_is_independent() {
    media_player_set_buffer(30, vec![1.0; 100]);
    media_player_set_buffer(31, vec![0.0; 100]);

    let rms_30 = media_player_compute_rms(30, 10);
    let rms_31 = media_player_compute_rms(31, 10);

    assert_eq!(rms_30.len(), 10);
    assert_eq!(rms_31.len(), 10);

    assert!(rms_30[0] > 0.0, "Buffer of 1.0 should have non-zero RMS");
    assert!(rms_31[0] == 0.0, "Buffer of 0.0 should have zero RMS");

    media_player_destroy(30);
    media_player_destroy(31);
}
