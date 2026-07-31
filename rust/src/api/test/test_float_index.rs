#[allow(unused)]
use crate::api::audio::float_index::FloatIndex;

#[allow(unused)]
#[test]
fn move_index_stays_exact_past_f32_integer_cliff() {
    // f32 integers are exact only up to 2^24 = 16_777_216.
    // A 21 minute file at 44.1 kHz is ~55.6M samples — well past the cliff.
    // Stepping by 1.0 must remain bit-exact in f64.
    let total: f64 = 30_000_000.0;
    let mut idx = FloatIndex::new(0.0, total);
    let steps = 25_000_000_u64;
    for _ in 0..steps {
        idx.move_index(1.0);
    }
    assert_eq!(idx.get_index(), steps as f64);
}

#[allow(unused)]
#[test]
fn index_behind_by_returns_the_earlier_index() {
    let mut idx = FloatIndex::new(0.0, 1000.0);
    idx.set_index(500.0);

    assert_eq!(idx.get_index_behind_by(100.0), 400.0);
}

#[allow(unused)]
#[test]
fn index_behind_by_stops_at_the_start() {
    let mut idx = FloatIndex::new(0.0, 1000.0);
    idx.set_index(100.0);

    assert_eq!(idx.get_index_behind_by(400.0), 0.0);
}

#[allow(unused)]
#[test]
fn wrapped_index_behind_by_wraps_around_to_the_end() {
    let mut idx = FloatIndex::new(0.0, 1000.0);
    idx.set_index(100.0);

    assert_eq!(idx.get_wrapped_index_behind_by(400.0), 700.0);
}

#[allow(unused)]
#[test]
fn wrapped_index_behind_by_stays_within_start_and_end() {
    let mut idx = FloatIndex::new(200.0, 800.0);
    idx.set_index(300.0);

    assert_eq!(idx.get_wrapped_index_behind_by(400.0), 500.0);
}
