use lerp::Lerp;

use super::float_index::FloatIndex;
use super::streaming_audio_source::StreamingAudioSource;

#[flutter_rust_bridge::frb(ignore)]
pub struct AudioBufferInterpolated {
    buffer_size_f32: f32,
    source: Option<StreamingAudioSource>,
    looping: bool,
    is_playing: bool,
    start_factor: f32,
    end_factor: f32,
    read_head: FloatIndex,
}

impl AudioBufferInterpolated {
    #[flutter_rust_bridge::frb(ignore)]
    pub fn new_empty() -> Self {
        Self {
            buffer_size_f32: 0.0,
            source: None,
            looping: false,
            is_playing: false,
            start_factor: 0.0,
            end_factor: 1.0,
            read_head: FloatIndex::new(0.0, 0.0),
        }
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn new_from_file(wav_path: &str, total_samples: u64) -> Self {
        let buffer_size_f32 = total_samples as f32;
        let source = StreamingAudioSource::new(wav_path, total_samples).ok();

        Self {
            buffer_size_f32,
            source,
            looping: false,
            is_playing: false,
            start_factor: 0.0,
            end_factor: 1.0,
            read_head: FloatIndex::new(0.0, buffer_size_f32),
        }
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_samples(&mut self, buffer_to_write_to: &mut [f32], read_speed: f32) {
        if self.source.is_none() || self.buffer_size_f32 < 2.0 {
            buffer_to_write_to.fill(0.0);
            return;
        }

        if !self.is_playing {
            buffer_to_write_to.fill(0.0);
            return;
        }

        self.pre_fill_cache_for_read(read_speed, buffer_to_write_to.len());

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

    fn pre_fill_cache_for_read(&mut self, read_speed: f32, chunk_size: usize) {
        if let Some(source) = &mut self.source {
            let start = self.read_head.get_index().max(0.0) as u64;
            let samples_needed = (chunk_size as f32 * read_speed.abs() + 2.0) as u64;
            source.ensure_range_cached(start, samples_needed);
        }
    }

    fn get_interpolated(&mut self, index: f32) -> f32 {
        let index_prev = index.floor();
        if index_prev < 0.0 {
            return 0.0;
        }
        let prev_idx = index_prev as usize;
        let total = self.buffer_size_f32 as usize;
        if prev_idx >= total {
            return 0.0;
        }

        let source = match &mut self.source {
            Some(s) => s,
            None => return 0.0,
        };

        let prev_sample = source.get_sample(prev_idx);

        let next_idx = if prev_idx + 1 < total {
            prev_idx + 1
        } else if self.looping {
            0
        } else {
            return prev_sample;
        };

        let next_sample = source.get_sample(next_idx);
        prev_sample.lerp(next_sample, (index - index_prev).clamp(0.0, 1.0))
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn compute_rms(&mut self, n_bins: usize) -> Vec<f32> {
        match &mut self.source {
            Some(source) => source.compute_rms_streaming(n_bins),
            None => vec![0.0; n_bins],
        }
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn set_playing(&mut self, playing: bool) {
        self.is_playing = playing;
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_is_playing(&self) -> bool {
        self.is_playing
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn set_loop(&mut self, looping: bool) {
        self.looping = looping;
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_is_looping(&self) -> bool {
        self.looping
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_playback_position_factor(&self) -> f32 {
        if self.buffer_size_f32 == 0.0 {
            return 0.0;
        }
        self.read_head.get_index() / self.buffer_size_f32
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn set_playback_position_factor(&mut self, playback_position_factor: f32) {
        self.read_head
            .set_index(playback_position_factor * self.buffer_size_f32);
        if let Some(source) = &mut self.source {
            source.invalidate_cache();
        }
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_is_empty(&self) -> bool {
        self.source.is_none()
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_length_seconds(&self, sample_rate: u32) -> f32 {
        if sample_rate == 0 {
            return 0.0;
        }
        self.buffer_size_f32 / sample_rate as f32
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn set_trim(&mut self, start_factor: f32, end_factor: f32) {
        self.start_factor = start_factor.min(end_factor).clamp(0.0, 1.0);
        self.end_factor = start_factor.max(end_factor).clamp(0.0, 1.0);
        self.read_head.set_start_end(
            self.start_factor * self.buffer_size_f32,
            self.end_factor * self.buffer_size_f32,
        )
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn get_trim(&self) -> (f32, f32) {
        (self.start_factor, self.end_factor)
    }
}
