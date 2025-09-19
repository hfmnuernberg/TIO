use lerp::Lerp;

use super::float_index::FloatIndex;

#[flutter_rust_bridge::frb(ignore)]
pub(crate) struct AudioBufferInterpolated {
    buffer_size_f32: f32,
    buffer: Vec<f32>,
    looping: bool,
    is_playing: bool,
    start_factor: f32,
    end_factor: f32,
    read_head: FloatIndex,
}

impl AudioBufferInterpolated {
    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn new(buffer: Vec<f32>) -> Self {
        let buffer_size_f32 = buffer.len() as f32;
        Self {
            buffer_size_f32,
            buffer,
            looping: false,
            is_playing: false,
            start_factor: 0.0,
            end_factor: 1.0,
            read_head: FloatIndex::new(0.0, buffer_size_f32),
        }
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn set_new_file(&mut self, buffer: Vec<f32>) {
        self.buffer_size_f32 = buffer.len() as f32;
        self.buffer = buffer;
        // Reset playback-related state to safe defaults for a fresh file
        self.looping = false;
        self.is_playing = false;
        self.start_factor = 0.0;
        self.end_factor = 1.0;
        // Reset the read head to cover the whole new buffer
        self.read_head = FloatIndex::new(0.0, self.buffer_size_f32);
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn get_samples(&mut self, buffer_to_write_to: &mut [f32], read_speed: f32) {
        if self.buffer.len() < 2 {
            return;
        }

        if !self.is_playing {
            for sample_to_write in buffer_to_write_to.iter_mut() {
                *sample_to_write = 0.0;
            }
            return;
        }

        let mut buffer_at_end = false;
        for sample_to_write in buffer_to_write_to.iter_mut() {
            if buffer_at_end {
                *sample_to_write = 0.0;
                continue;
            }

            let buffer_just_hit_end = self.read_head.move_index(read_speed);

            if buffer_just_hit_end && !self.looping {
                buffer_at_end = true;
                self.set_playing(false);
                *sample_to_write = 0.0;
                continue;
            }

            *sample_to_write = self.get_interpolated(self.read_head.get_index());
        }
    }

    fn get_interpolated(&self, index: f32) -> f32 {
        let index_prev = index.floor();
        let index_next = index.ceil();
        if index_next >= self.buffer_size_f32 || index_prev < 0.0 {
            return 0.0;
        }
        self.buffer[index_prev as usize].lerp(
            self.buffer[index_next as usize],
            (index - index_prev).clamp(0.0, 1.0),
        )
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn compute_rms(&self, n_bins: usize) -> Vec<f32> {
        // if buffer is empty return zeros
        if self.buffer.is_empty() {
            return vec![0.0; n_bins];
        }

        let buffer_len = self.buffer.len() as f32;
        let bin_size = buffer_len / n_bins as f32;

        (0..n_bins)
            .map(|bin_i| {
                let bin_i_f = bin_i as f32;
                let bin_start = (bin_i_f * bin_size).floor().max(0.0) as usize;
                let bin_end = (((bin_i_f + 1.0) * bin_size).ceil() as usize).min(self.buffer.len());

                let sum_squared = (bin_start..bin_end)
                    .map(|sample_i| self.buffer[sample_i].powi(2))
                    .sum::<f32>()
                    / (bin_end - bin_start) as f32;
                sum_squared.sqrt()
            })
            .collect()
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn set_playing(&mut self, playing: bool) {
        self.is_playing = playing;
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn get_is_playing(&self) -> bool {
        self.is_playing
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn set_loop(&mut self, looping: bool) {
        self.looping = looping;
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn get_is_looping(&self) -> bool {
        self.looping
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn get_playback_position_factor(&self) -> f32 {
        self.read_head.get_index() / self.buffer_size_f32
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn set_playback_position_factor(&mut self, playback_position_factor: f32) {
        self.read_head
            .set_index(playback_position_factor * self.buffer_size_f32);
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn get_is_empty(&self) -> bool {
        self.buffer.is_empty()
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn get_length_seconds(&self, sample_rate: u32) -> f32 {
        self.buffer.len() as f32 / sample_rate as f32
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn set_trim(&mut self, start_factor: f32, end_factor: f32) {
        self.start_factor = start_factor.min(end_factor).clamp(0.0, 1.0);
        self.end_factor = start_factor.max(end_factor).clamp(0.0, 1.0);
        self.read_head.set_start_end(
            self.start_factor * self.buffer_size_f32,
            self.end_factor * self.buffer_size_f32,
        )
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub(crate) fn get_trim(&self) -> (f32, f32) {
        (self.start_factor, self.end_factor)
    }
}
