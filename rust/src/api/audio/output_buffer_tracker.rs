use std::sync::atomic::{AtomicU64, Ordering};

#[flutter_rust_bridge::frb(ignore)]
#[derive(Default)]
pub struct OutputBufferTracker {
    produced: AtomicU64,
    consumed: AtomicU64,
    produced_when_discarded: AtomicU64,
}

impl OutputBufferTracker {
    #[flutter_rust_bridge::frb(ignore)]
    pub fn new() -> Self {
        Self::default()
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn record_produced(&self, samples: usize) {
        self.produced.fetch_add(samples as u64, Ordering::Relaxed);
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn record_consumed(&self, samples: usize) {
        self.consumed.fetch_add(samples as u64, Ordering::Relaxed);
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn discard_buffered(&self) {
        self.produced_when_discarded
            .store(self.produced.load(Ordering::Relaxed), Ordering::Relaxed);
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn reset(&self) {
        self.produced.store(0, Ordering::Relaxed);
        self.consumed.store(0, Ordering::Relaxed);
        self.produced_when_discarded.store(0, Ordering::Relaxed);
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn buffered_samples(&self) -> u64 {
        let produced = self.produced.load(Ordering::Relaxed);
        let unplayed = produced.saturating_sub(self.consumed.load(Ordering::Relaxed));
        let since_discard =
            produced.saturating_sub(self.produced_when_discarded.load(Ordering::Relaxed));
        unplayed.min(since_discard)
    }
}
