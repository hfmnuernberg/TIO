#[derive(Enum, Debug, Clone, PartialEq, Copy)]
pub enum BeatType {
    Accented,
    Unaccented,
    Muted,
}

#[derive(Enum, Debug, Clone, PartialEq, Copy)]
pub enum BeatTypePoly {
    Accented,
    Unaccented,
    Muted,
}

#[derive(Enum, Debug, Clone, PartialEq, Copy)]
pub enum BeatSound {
    Accented,
    Accented2,
    Unaccented,
    Unaccented2,
    PolyAccented,
    PolyAccented2,
    PolyUnaccented,
    PolyUnaccented2,
    Muted,
}

#[derive(Debug, Clone)]
pub struct MetroBar {
    pub id: i32,
    pub beats: Vec<BeatType>,
    pub poly_beats: Vec<BeatTypePoly>,
    pub beat_len: f32, // bpm agnostic -> 1.0 == one quarter note
}

#[derive(Debug, Clone)]
struct BeatEvent {
    time_quarters: f32,
    bar_index: i32,
    beat_sound: BeatSound,
    is_poly: bool,
    beat_index: i32,
}

#[derive(Debug, Clone)]
pub struct MetroRhythmUnpacked {
    _bars: Vec<MetroBar>,

    beat_events: Vec<BeatEvent>,
    total_dur_quarters: f32,

    play_head: f32,
    play_head_index: i32,

    is_secondary: bool,
}

#[derive(Debug, Clone)]
pub struct UpcomingEvent {
    pub beat_sound: BeatSound,
    pub is_poly: bool,
    pub is_secondary: bool,
    pub quarters_until_start: f32,
    pub bar_index: i32,
    pub beat_index: i32,
}

impl MetroRhythmUnpacked {
    #[flutter_rust_bridge::frb(ignore)]
    pub fn new(bars: Vec<MetroBar>, is_secondary: bool) -> Self {
        let mut beat_events: Vec<BeatEvent> = vec![];
        let mut beat_time_quarters: f32 = 0.0;

        for (bar_index, bar) in bars.iter().enumerate() {
            // create regular beats
            let mut bar_playhead_regular = beat_time_quarters;
            for (beat_index, beat) in bar.beats.iter().enumerate() {
                let upcoming_sound = match beat {
                    BeatType::Accented => {
                        if is_secondary {
                            BeatSound::Accented2
                        } else {
                            BeatSound::Accented
                        }
                    }
                    BeatType::Unaccented => {
                        if is_secondary {
                            BeatSound::Unaccented2
                        } else {
                            BeatSound::Unaccented
                        }
                    }
                    BeatType::Muted => BeatSound::Muted,
                };

                beat_events.push(BeatEvent {
                    beat_sound: upcoming_sound,
                    time_quarters: bar_playhead_regular,
                    bar_index: bar_index as i32,
                    beat_index: beat_index as i32,
                    is_poly: false,
                });
                bar_playhead_regular += bar.beat_len;
            }

            // create poly beats
            if !bar.poly_beats.is_empty() {
                let mut bar_playhead_poly = beat_time_quarters;
                let beat_len_poly =
                    (bar.beat_len * bar.beats.len() as f32) / bar.poly_beats.len() as f32;
                for (beat_poly_index, beat_poly) in bar.poly_beats.iter().enumerate() {
                    let upcoming_sound = match beat_poly {
                        BeatTypePoly::Accented => {
                            if is_secondary {
                                BeatSound::PolyAccented2
                            } else {
                                BeatSound::PolyAccented
                            }
                        }
                        BeatTypePoly::Unaccented => {
                            if is_secondary {
                                BeatSound::PolyUnaccented2
                            } else {
                                BeatSound::PolyUnaccented
                            }
                        }
                        BeatTypePoly::Muted => BeatSound::Muted,
                    };

                    beat_events.push(BeatEvent {
                        beat_sound: upcoming_sound,
                        time_quarters: bar_playhead_poly,
                        bar_index: bar_index as i32,
                        beat_index: beat_poly_index as i32,
                        is_poly: true,
                    });
                    bar_playhead_poly += beat_len_poly;
                }
            }

            // update time for next bar
            beat_time_quarters += bar.beat_len * bar.beats.len() as f32;
        }

        beat_events.sort_by(|a, b| {
            a.time_quarters
                .partial_cmp(&b.time_quarters)
                .expect("Could not compare beat events")
        });

        Self {
            _bars: bars,
            beat_events,
            total_dur_quarters: beat_time_quarters,
            play_head: 0.0,
            play_head_index: -1,
            is_secondary,
        }
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn reset_playhead(&mut self) {
        self.play_head = 0.0;
        self.play_head_index = -1;
    }

    fn get_event(&self, index: usize) -> BeatEvent {
        self.beat_events[index % self.beat_events.len()].clone()
    }

    fn get_event_time(&self, index: usize) -> f32 {
        let mut index_left = index;
        let mut time = 0.0;
        while index_left >= self.beat_events.len() {
            time += self.total_dur_quarters;
            index_left -= self.beat_events.len();
        }
        time + self.beat_events[index_left].time_quarters
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_next_events(&mut self, quarters: f32) -> Vec<UpcomingEvent> {
        if self._bars.is_empty() {
            return vec![];
        }
        let mut next_events: Vec<UpcomingEvent> = vec![];

        let mut time_left = quarters;
        let mut total_advancement = 0.0;

        loop {
            let time_at_next = self.get_event_time((self.play_head_index + 1) as usize);
            let advancement = time_at_next - self.play_head;

            if advancement > time_left {
                // no next beat
                self.play_head += time_left;
                break;
            } else {
                self.play_head += advancement;
                self.play_head_index += 1;
                time_left -= advancement;
                total_advancement += advancement;

                let event: BeatEvent = self.get_event(self.play_head_index as usize);

                next_events.push(UpcomingEvent {
                    quarters_until_start: total_advancement,
                    bar_index: event.bar_index,
                    beat_index: event.beat_index,
                    beat_sound: event.beat_sound,
                    is_poly: event.is_poly,
                    is_secondary: self.is_secondary,
                });

                //             pub beat_type: UpcomingBeatType,
                // pub quarters_until_start: f32,
                // pub bar_index: i32,
                // pub is_poly: bool,
                // pub beat_index: i32,
            }
        }

        next_events
    }
}
