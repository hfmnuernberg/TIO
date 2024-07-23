#[allow(unused)]
use crate::modules::metronome_rhythm::{BeatType, MetroBar, MetroRhythmUnpacked};

#[allow(unused)]
#[test]
pub fn rhythm_01() {
    let mut r = MetroRhythmUnpacked::new(
        vec![MetroBar {
            beats: vec![
                BeatType::Accented,
                BeatType::Unaccented,
                BeatType::Unaccented,
                BeatType::Unaccented,
            ],
            poly_beats: vec![],
            beat_len: 0.25,
            id: 0,
        }],
        false,
    );
    r.get_next_events(0.0001);
    assert_eq!(r.get_next_events(0.3).len(), 1);
}

#[test]
pub fn rhythm_02() {
    let mut r = MetroRhythmUnpacked::new(
        vec![MetroBar {
            beats: vec![
                BeatType::Accented,
                BeatType::Unaccented,
                BeatType::Unaccented,
                BeatType::Unaccented,
            ],
            poly_beats: vec![],
            beat_len: 0.25,
            id: 0,
        }],
        false,
    );
    r.get_next_events(0.0001);
    for _ in 0..10 {
        assert_eq!(r.get_next_events(0.5).len(), 2);
    }
}

#[test]
pub fn rhythm_03() {
    let mut r = MetroRhythmUnpacked::new(
        vec![MetroBar {
            beats: vec![
                BeatType::Accented,
                BeatType::Unaccented,
                BeatType::Unaccented,
                BeatType::Unaccented,
            ],
            poly_beats: vec![],
            beat_len: 0.25,
            id: 0,
        }],
        false,
    );
    r.get_next_events(0.0001);
    for _ in 0..10 {
        assert_eq!(r.get_next_events(0.25).len(), 1);
    }
}

#[test]
pub fn rhythm_values() {
    let mut r = MetroRhythmUnpacked::new(
        vec![MetroBar {
            beats: vec![
                BeatType::Accented,
                BeatType::Unaccented,
                BeatType::Unaccented,
                BeatType::Unaccented,
            ],
            poly_beats: vec![],
            beat_len: 0.25,
            id: 0,
        }],
        false,
    );
    let next_values = r.get_next_events(1.5);
    assert_eq!(next_values.len(), 7);

    assert_eq!(next_values[0].quarters_until_start, 0.0);
    assert_eq!(next_values[1].quarters_until_start, 0.25);
    assert_eq!(next_values[2].quarters_until_start, 0.5);
    assert_eq!(next_values[3].quarters_until_start, 0.75);
    assert_eq!(next_values[4].quarters_until_start, 1.0);
    assert_eq!(next_values[5].quarters_until_start, 1.25);
    assert_eq!(next_values[6].quarters_until_start, 1.5);
}
