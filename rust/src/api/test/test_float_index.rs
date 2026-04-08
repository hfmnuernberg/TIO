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
