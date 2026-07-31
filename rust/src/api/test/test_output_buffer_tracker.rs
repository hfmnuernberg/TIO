#[allow(unused)]
use crate::api::audio::output_buffer_tracker::OutputBufferTracker;

#[test]
fn nothing_is_buffered_before_playback_starts() {
    let tracker = OutputBufferTracker::new();

    assert_eq!(tracker.buffered_samples(), 0);
}

#[test]
fn buffered_samples_are_those_produced_but_not_yet_played() {
    let tracker = OutputBufferTracker::new();

    tracker.record_produced(16_448);
    tracker.record_consumed(512);

    assert_eq!(tracker.buffered_samples(), 15_936);
}

#[test]
fn buffered_samples_stay_constant_while_production_keeps_up_with_playback() {
    let tracker = OutputBufferTracker::new();
    tracker.record_produced(16_448);

    for _ in 0..100 {
        tracker.record_consumed(512);
        tracker.record_produced(512);
    }

    assert_eq!(tracker.buffered_samples(), 16_448);
}

#[test]
fn discarding_drops_buffered_samples_to_zero() {
    let tracker = OutputBufferTracker::new();
    tracker.record_produced(16_448);

    tracker.discard_buffered();

    assert_eq!(tracker.buffered_samples(), 0);
}

#[test]
fn buffered_samples_grow_back_only_with_audio_produced_after_a_discard() {
    let tracker = OutputBufferTracker::new();
    tracker.record_produced(16_448);
    tracker.discard_buffered();

    tracker.record_produced(4_000);

    assert_eq!(tracker.buffered_samples(), 4_000);
}

#[test]
fn discarded_audio_is_not_counted_again_once_it_has_been_played() {
    let tracker = OutputBufferTracker::new();
    tracker.record_produced(16_448);
    tracker.discard_buffered();

    tracker.record_produced(4_000);
    tracker.record_consumed(16_448);

    assert_eq!(tracker.buffered_samples(), 4_000);
}

#[test]
fn buffered_samples_never_go_negative_while_discarded_audio_drains() {
    let tracker = OutputBufferTracker::new();
    tracker.record_produced(16_448);
    tracker.discard_buffered();

    tracker.record_consumed(8_000);

    assert_eq!(tracker.buffered_samples(), 0);
}

#[test]
fn resetting_forgets_the_audio_of_a_torn_down_stream() {
    let tracker = OutputBufferTracker::new();
    tracker.record_produced(16_448);

    tracker.reset();
    tracker.record_produced(512);

    assert_eq!(tracker.buffered_samples(), 512);
}
