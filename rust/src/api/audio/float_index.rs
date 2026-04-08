#[flutter_rust_bridge::frb(ignore)]
pub struct FloatIndex {
    start: f64,
    end: f64,
    index: f64,
    range: f64,
}

impl FloatIndex {
    #[flutter_rust_bridge::frb(ignore)]
    pub fn new(start: f64, end: f64) -> Self {
        let mut index = FloatIndex {
            start: 0.0,
            end: 1.0,
            index: 0.0,
            range: 1.0,
        };
        index.set_start_end(start, end);
        index
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn set_start_end(&mut self, start: f64, end: f64) {
        self.start = start.min(end);
        self.end = start.max(end);
        self.range = self.end - self.start;
        self.index = self.index.clamp(self.start, self.end);
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn move_index(&mut self, step: f64) -> bool {
        self.index += step;
        if self.index > self.end {
            self.index = self.start + (self.index - self.end);
            return true;
        }
        false
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_index(&self) -> f64 {
        self.index
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn set_index(&mut self, index: f64) {
        self.index = index.clamp(self.start, self.end);
    }
}
