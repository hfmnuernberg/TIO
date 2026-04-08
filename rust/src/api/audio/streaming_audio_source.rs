use std::fs::File;
use std::io::{Read, Seek, SeekFrom};

use crate::api::util::constants::{RMS_STREAMING_CHUNK_SIZE, SAMPLE_RATE, STREAMING_CACHE_SECONDS};

#[flutter_rust_bridge::frb(ignore)]
pub struct StreamingAudioSource {
    file: File,
    data_offset: u64,
    total_samples: u64,
    cache: Vec<f32>,
    cache_start: u64,
    cache_end: u64,
}

impl StreamingAudioSource {
    pub fn new(wav_path: &str, total_samples: u64) -> anyhow::Result<Self> {
        let mut file = File::open(wav_path)?;
        let data_offset = find_wav_data_offset(&mut file)?;
        let cache_capacity = STREAMING_CACHE_SECONDS * SAMPLE_RATE;

        let mut source = Self {
            file,
            data_offset,
            total_samples,
            cache: vec![0.0; cache_capacity],
            cache_start: 0,
            cache_end: 0,
        };

        source.fill_cache(0)?;
        Ok(source)
    }

    pub fn total_samples(&self) -> u64 {
        self.total_samples
    }

    pub fn get_sample(&mut self, index: usize) -> f32 {
        let idx = index as u64;
        if idx >= self.total_samples {
            return 0.0;
        }

        if idx >= self.cache_start && idx < self.cache_end {
            return self.cache[(idx - self.cache_start) as usize];
        }

        if self.fill_cache(idx).is_err() {
            return 0.0;
        }

        if idx >= self.cache_start && idx < self.cache_end {
            self.cache[(idx - self.cache_start) as usize]
        } else {
            0.0
        }
    }

    pub fn ensure_range_cached(&mut self, start: u64, count: u64) {
        let end = (start + count).min(self.total_samples);
        if start >= self.cache_start && end <= self.cache_end {
            return;
        }
        let _ = self.fill_cache(start);
    }

    pub fn invalidate_cache(&mut self) {
        self.cache_start = 0;
        self.cache_end = 0;
    }

    pub fn compute_rms_streaming(&mut self, n_bins: usize) -> Vec<f32> {
        if self.total_samples == 0 {
            return vec![0.0; n_bins];
        }

        let total = self.total_samples as f64;
        let bin_size = total / n_bins as f64;
        let mut rms = vec![0.0f32; n_bins];
        let mut chunk_buf = vec![0.0f32; RMS_STREAMING_CHUNK_SIZE];

        if self.file.seek(SeekFrom::Start(self.data_offset)).is_err() {
            return rms;
        }

        let mut sample_index: u64 = 0;
        loop {
            let samples_remaining = self.total_samples - sample_index;
            if samples_remaining == 0 {
                break;
            }
            let to_read = (samples_remaining as usize).min(RMS_STREAMING_CHUNK_SIZE);
            let byte_count = to_read * 4;
            let byte_buf = unsafe {
                std::slice::from_raw_parts_mut(chunk_buf.as_mut_ptr() as *mut u8, byte_count)
            };

            match self.file.read_exact(byte_buf) {
                Ok(()) => {}
                Err(_) => break,
            }

            for (i, &s) in chunk_buf.iter().enumerate().take(to_read) {
                let bin =
                    ((sample_index as f64 + i as f64) / bin_size).min((n_bins - 1) as f64) as usize;
                rms[bin] += s * s;
            }

            sample_index += to_read as u64;
        }

        for (bin, rms_val) in rms.iter_mut().enumerate().take(n_bins) {
            let bin_start = (bin as f64 * bin_size).floor() as u64;
            let bin_end = (((bin + 1) as f64 * bin_size).ceil() as u64).min(self.total_samples);
            let count = bin_end - bin_start;
            if count > 0 {
                *rms_val = (*rms_val / count as f32).sqrt();
            }
        }

        rms
    }

    fn fill_cache(&mut self, start: u64) -> anyhow::Result<()> {
        let start = start.min(self.total_samples);
        let samples_available = self.total_samples - start;
        let to_read = (self.cache.len() as u64).min(samples_available) as usize;

        let byte_offset = self.data_offset + start * 4;
        self.file.seek(SeekFrom::Start(byte_offset))?;

        let byte_count = to_read * 4;
        let byte_buf = unsafe {
            std::slice::from_raw_parts_mut(self.cache.as_mut_ptr() as *mut u8, byte_count)
        };
        self.file.read_exact(byte_buf)?;

        self.cache_start = start;
        self.cache_end = start + to_read as u64;
        Ok(())
    }
}

fn find_wav_data_offset(file: &mut File) -> anyhow::Result<u64> {
    file.seek(SeekFrom::Start(0))?;

    let mut header = [0u8; 12];
    file.read_exact(&mut header)?;

    if &header[0..4] != b"RIFF" || &header[8..12] != b"WAVE" {
        return Err(anyhow::anyhow!("Not a valid WAV file"));
    }

    loop {
        let mut chunk_header = [0u8; 8];
        file.read_exact(&mut chunk_header)?;

        let chunk_id = &chunk_header[0..4];
        let chunk_size = u32::from_le_bytes([
            chunk_header[4],
            chunk_header[5],
            chunk_header[6],
            chunk_header[7],
        ]);

        if chunk_id == b"data" {
            return Ok(file.stream_position()?);
        }

        file.seek(SeekFrom::Current(chunk_size as i64))?;
    }
}
