use ::num::{Float, NumCast};
use anyhow::{Error, Result};
use cpal::{
    traits::{DeviceTrait, HostTrait},
    BufferSize, Device,
};
use rubato::{
    Resampler, SincFixedIn, SincInterpolationParameters, SincInterpolationType, WindowFunction,
};
use std::{fs::File, path::Path};
use symphonia::core::{
    audio::{AudioBufferRef, Signal},
    io::MediaSourceStream,
    probe::Hint,
    sample::Sample,
};

use super::constants::{INPUT_SAMPLE_RATE, NUM_CHANNELS, OUTPUT_SAMPLE_RATE};
use crate::api::api::get_sample_rate;

#[flutter_rust_bridge::frb(ignore)]
pub fn speed_factor_to_halftones<T: Float>(speed_factor: T) -> T {
    speed_factor.log2()
        * NumCast::from(12.0)
            .expect("Something went wrong casting suring calculation of speed factor.")
}

#[flutter_rust_bridge::frb(ignore)]
pub fn load_audio_file(file_path: String) -> Result<Vec<f32>> {
    let default_sample_rate = get_sample_rate();

    let (channels, sample_rate) = load_audio_file_channels(file_path)?;

    // mix down to mono
    if channels.is_empty() {
        return Err(Error::msg("No channels found in audio file."));
    }
    let channel_lenghts: Vec<_> = channels.iter().map(|chan| chan.len()).collect();
    if channel_lenghts.iter().min() != channel_lenghts.iter().max() {
        return Err(Error::msg(
            "Channels have different lengths, something went wrong.",
        ));
    }
    let channel_length = channel_lenghts[0];
    let mut out_samples = vec![0.0; channel_length];

    for (i, out_sample) in out_samples.iter_mut().enumerate() {
        *out_sample = channels
            .iter()
            .map(|channel| channel[i])
            .fold(0.0, |acc, s| acc + s)
            / channels.len() as f32;
    }

    // resample
    if sample_rate != default_sample_rate as u32 {
        log::info!(
            "Resampling from {} to {}.",
            sample_rate,
            default_sample_rate
        );
        let params = SincInterpolationParameters {
            sinc_len: 4,
            f_cutoff: 0.95,
            interpolation: SincInterpolationType::Cubic,
            oversampling_factor: 64,
            window: WindowFunction::BlackmanHarris2,
        };
        let resample_ratio = default_sample_rate as f64 / sample_rate as f64;
        let mut resampler =
            SincFixedIn::<f64>::new(resample_ratio, 1.0, params, out_samples.len(), 1)
                .expect("Failed to create resampler.");
        let channels: Vec<Vec<f64>> = vec![out_samples.iter().map(|s| *s as f64).collect(); 1];
        let resampled = resampler
            .process(&channels, None)
            .expect("Failed to resample.");

        out_samples = resampled[0].iter().map(|s| *s as f32).collect();
        log::info!("Resampling done.");
    }

    Ok(out_samples)
}

#[flutter_rust_bridge::frb(ignore)]
pub fn load_audio_file_channels(file_path: String) -> Result<(Vec<Vec<f32>>, u32)> {
    let file = File::open(Path::new(&file_path))?;
    let mss = MediaSourceStream::new(Box::new(file), Default::default());

    let extension = Path::new(&file_path)
        .extension()
        .ok_or_else(|| anyhow::anyhow!("Could not get file extension."))?
        .to_str()
        .ok_or_else(|| anyhow::anyhow!("Could not convert file extension to string."))?;

    let mut hint = Hint::new();
    let hint = hint.with_extension(extension);

    let probed = symphonia::default::get_probe().format(
        hint,
        mss,
        &Default::default(),
        &Default::default(),
    )?;
    let mut reader = probed.format;
    let track = reader
        .default_track()
        .ok_or_else(|| anyhow::anyhow!("Could not get default track from audio file."))?;

    let mut decoder =
        symphonia::default::get_codecs().make(&track.codec_params, &Default::default())?;

    let sample_rate = track
        .codec_params
        .sample_rate
        .ok_or_else(|| anyhow::anyhow!("Could not get sample rate from audio file."))?
        as u32;

    let seconds_to_allocate = 45; // Magic number to avoid reallocations. If the audio file is longer than 45 seconds, it will reallocate.
    let mut samples = vec![];

    while let Ok(packet) = reader.next_packet() {
        let decoded = decoder.decode(&packet)?;

        match decoded {
            AudioBufferRef::U8(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(
                            (sample.clamped() as f32 - 2_u32.pow(7) as f32) / 2_u32.pow(7) as f32,
                        )
                    }
                }
            }
            AudioBufferRef::U16(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(
                            (sample.clamped() as f32 - 2_u32.pow(15) as f32) / 2_u32.pow(15) as f32,
                        )
                    }
                }
            }
            AudioBufferRef::U24(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(
                            (sample.clamped().0 as f32 - 2_u32.pow(23) as f32)
                                / 2_u32.pow(23) as f32,
                        );
                    }
                }
            }
            AudioBufferRef::U32(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(
                            (sample.clamped() as f32 - 2_u32.pow(31) as f32) / 2_u32.pow(31) as f32,
                        )
                    }
                }
            }
            AudioBufferRef::S8(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(sample.clamped() as f32 / 2_u32.pow(7) as f32);
                    }
                }
            }
            AudioBufferRef::S16(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(sample.clamped() as f32 / 2_u32.pow(15) as f32);
                    }
                }
            }
            AudioBufferRef::S24(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(sample.clamped().0 as f32 / 2_u32.pow(23) as f32);
                    }
                }
            }
            AudioBufferRef::S32(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(sample.clamped() as f32 / 2_u32.pow(31) as f32);
                    }
                }
            }
            AudioBufferRef::F32(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(sample.clamped());
                    }
                }
            }
            AudioBufferRef::F64(buffer) => {
                if samples.is_empty() {
                    samples = allocate_audio_buffer_vector(
                        seconds_to_allocate,
                        sample_rate as usize,
                        buffer.spec().channels.iter().count(),
                    );
                }
                for (channel_index, channel) in samples.iter_mut().enumerate() {
                    for sample in buffer.chan(channel_index) {
                        channel.push(sample.clamped() as f32);
                    }
                }
            }
        }
    }

    Ok((samples, sample_rate))
}

fn allocate_audio_buffer_vector(
    seconds: usize,
    sample_rate: usize,
    num_channels: usize,
) -> Vec<Vec<f32>> {
    vec![Vec::with_capacity(sample_rate * seconds); num_channels]
}

#[flutter_rust_bridge::frb(ignore)]
pub fn quarters_to_samples(quarters: f32, sample_rate: f32, bpm: f32) -> i32 {
    let quarter_in_seconds = 60.0 / bpm;
    let seconds = quarters * quarter_in_seconds;
    (seconds * sample_rate) as i32
}

#[flutter_rust_bridge::frb(ignore)]
pub fn samples_to_quarters(samples: f32, sample_rate: f32, bpm: f32) -> f32 {
    let quarter_in_seconds = 60.0 / bpm;
    samples / sample_rate / quarter_in_seconds
}

#[flutter_rust_bridge::frb(ignore)]
pub fn get_platform_default_cpal_output_config(device: &Device) -> Option<cpal::StreamConfig> {
    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock OUTPUT_SAMPLE_RATE") as u32;

    if cfg!(target_os = "android") {
        Some(cpal::StreamConfig {
            channels: NUM_CHANNELS as u16,
            sample_rate: cpal::SampleRate(sample_rate),
            buffer_size: BufferSize::Default,
        })
    } else {
        let mut config = device
            .default_output_config()
            .expect("Could not get default output config of device")
            .config();
        config.sample_rate = cpal::SampleRate(sample_rate);
        config.channels = 1;
        Some(config)
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn get_platform_default_cpal_input_config(device: &Device) -> Option<cpal::StreamConfig> {
    let sample_rate = *INPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock INPUT_SAMPLE_RATE") as u32;

    if cfg!(target_os = "android") {
        Some(cpal::StreamConfig {
            channels: NUM_CHANNELS as u16,
            sample_rate: cpal::SampleRate(sample_rate),
            buffer_size: cpal::BufferSize::Default,
        })
    } else {
        let mut config = device
            .default_input_config()
            .expect("Could not get default input config")
            .config();
        config.sample_rate = cpal::SampleRate(sample_rate);
        config.channels = 1;
        Some(config)
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn get_platform_default_input_sample_rate() -> Result<u32> {
    if cfg!(target_os = "android") {
        return Ok(44100);
    }
    let host = cpal::default_host();
    let device = host
        .default_input_device()
        .expect("no input device available");
    Ok(device.default_input_config()?.sample_rate().0)
}

#[flutter_rust_bridge::frb(ignore)]
pub fn get_platform_default_output_device() -> Result<Device> {
    let host = cpal::default_host();
    let device = host
        .default_output_device()
        .expect("no output device available");

    Ok(device)
}

#[flutter_rust_bridge::frb(ignore)]
pub fn get_platform_default_output_sample_rate() -> Result<u32> {
    if cfg!(target_os = "android") {
        return Ok(44100);
    }
    let device = get_platform_default_output_device()?;
    Ok(device.default_output_config()?.sample_rate().0)
}
