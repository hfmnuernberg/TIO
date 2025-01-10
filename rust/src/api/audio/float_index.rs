#[flutter_rust_bridge::frb(ignore)]
pub struct FloatIndex {
    start: f32,
    end: f32,
    index: f32,
    range: f32,
}

impl FloatIndex {
    #[flutter_rust_bridge::frb(ignore)]
    pub fn new(start: f32, end: f32) -> Self {
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
    pub fn set_start_end(&mut self, start: f32, end: f32) {
        self.start = start.min(end);
        self.end = start.max(end);
        self.range = self.end - self.start;
        self.index = self.index.clamp(self.start, self.end);
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn move_index(&mut self, step: f32) -> bool {
        self.index += step;
        if self.index > self.end {
            self.index = self.start;
            return true;
        }
        false
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_index(&self) -> f32 {
        self.index
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn set_index(&mut self, index: f32) {
        self.index = index.clamp(self.start, self.end);
    }
}
