#[allow(unused)]
use crate::api::util::util_functions::{quarters_to_samples, samples_to_quarters};

#[test]
pub fn samples_to_quarters_01() {
    let quarters = samples_to_quarters(44100.0, 44100.0, 60.0);
    assert_eq!(quarters, 1.0)
}

#[test]
pub fn samples_to_quarters_02() {
    let quarters = samples_to_quarters(44100.0, 44100.0, 120.0);
    assert_eq!(quarters, 2.0)
}

#[test]
pub fn quarters_to_samples_01() {
    let quarters = quarters_to_samples(1.0, 44100.0, 60.0);
    assert_eq!(quarters, 44100)
}

#[test]
pub fn quarters_to_samples_02() {
    let quarters = quarters_to_samples(1.0, 44100.0, 120.0);
    assert_eq!(quarters, 22050)
}
