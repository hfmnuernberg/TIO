use ::num::{Float, NumCast};
use anyhow::{Error, Result};
use cpal::{
    BufferSize, Device,
    traits::{DeviceTrait, HostTrait},
};
use hound::{SampleFormat, WavSpec, WavWriter};
use rubato::{
    Resampler, SincFixedIn, SincInterpolationParameters, SincInterpolationType, WindowFunction,
};
use std::{fs::File, io::BufWriter, path::Path};
use symphonia::core::{
    audio::{AudioBufferRef, Signal},
    io::MediaSourceStream,
    probe::Hint,
    sample::Sample,
};

use super::constants::{INPUT_SAMPLE_RATE, NUM_CHANNELS, OUTPUT_SAMPLE_RATE};
use crate::api::ffi::get_sample_rate;

const RESAMPLE_CHUNK_SIZE: usize = 4096;
const DECODE_WRITER_BUFFER_BYTES: usize = 256 * 1024;

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
pub fn decode_audio_to_wav_file(file_path: String, output_wav_path: String) -> Result<u64> {
    let default_sample_rate = get_sample_rate() as u32;

    let (reader, mut decoder, sample_rate, num_channels) = open_audio_decoder(&file_path)?;
    let needs_resample = sample_rate != default_sample_rate;

    let spec = WavSpec {
        channels: 1,
        sample_rate: default_sample_rate,
        bits_per_sample: 32,
        sample_format: SampleFormat::Float,
    };
    let writer = WavWriter::new(
        BufWriter::with_capacity(DECODE_WRITER_BUFFER_BYTES, File::create(&output_wav_path)?),
        spec,
    )?;

    if needs_resample {
        decode_with_resample(
            reader,
            &mut decoder,
            writer,
            sample_rate,
            default_sample_rate,
            num_channels,
        )
    } else {
        decode_without_resample(reader, &mut decoder, writer, num_channels)
    }
}

fn decode_with_resample(
    mut reader: Box<dyn symphonia::core::formats::FormatReader>,
    decoder: &mut Box<dyn symphonia::core::codecs::Decoder>,
    mut writer: WavWriter<BufWriter<File>>,
    source_rate: u32,
    target_rate: u32,
    num_channels: usize,
) -> Result<u64> {
    log::info!("Resampling from {} to {}.", source_rate, target_rate);

    let params = SincInterpolationParameters {
        sinc_len: 4,
        f_cutoff: 0.95,
        interpolation: SincInterpolationType::Cubic,
        oversampling_factor: 64,
        window: WindowFunction::BlackmanHarris2,
    };
    let resample_ratio = target_rate as f64 / source_rate as f64;
    let mut resampler =
        SincFixedIn::<f64>::new(resample_ratio, 1.0, params, RESAMPLE_CHUNK_SIZE, 1)?;

    let mut mono_accumulator: Vec<f64> = Vec::with_capacity(RESAMPLE_CHUNK_SIZE * 2);
    let mut chunk_buf: Vec<f64> = Vec::with_capacity(RESAMPLE_CHUNK_SIZE);
    let mut output_buf = resampler.output_buffer_allocate(true);
    let mut total_samples: u64 = 0;

    while let Ok(packet) = reader.next_packet() {
        let decoded = decoder.decode(&packet)?;
        append_mono_f64(&decoded, num_channels, &mut mono_accumulator);

        while mono_accumulator.len() >= RESAMPLE_CHUNK_SIZE {
            chunk_buf.clear();
            chunk_buf.extend(mono_accumulator.drain(..RESAMPLE_CHUNK_SIZE));
            let (_, written) =
                resampler.process_into_buffer(&[chunk_buf.as_slice()], &mut output_buf, None)?;
            for &sample in &output_buf[0][..written] {
                writer.write_sample(sample as f32)?;
                total_samples += 1;
            }
        }
    }

    if !mono_accumulator.is_empty() {
        let resampled = resampler.process_partial(Some(&[mono_accumulator.as_slice()]), None)?;
        for &sample in &resampled[0] {
            writer.write_sample(sample as f32)?;
            total_samples += 1;
        }
    }

    writer.finalize()?;
    log::info!("Resampling done. Total samples: {}", total_samples);
    Ok(total_samples)
}

fn decode_without_resample(
    mut reader: Box<dyn symphonia::core::formats::FormatReader>,
    decoder: &mut Box<dyn symphonia::core::codecs::Decoder>,
    mut writer: WavWriter<BufWriter<File>>,
    num_channels: usize,
) -> Result<u64> {
    let mut total_samples: u64 = 0;
    let mut mono_chunk: Vec<f32> = Vec::with_capacity(RESAMPLE_CHUNK_SIZE);

    while let Ok(packet) = reader.next_packet() {
        let decoded = decoder.decode(&packet)?;
        append_mono_f32(&decoded, num_channels, &mut mono_chunk);

        for &sample in &mono_chunk {
            writer.write_sample(sample)?;
            total_samples += 1;
        }
        mono_chunk.clear();
    }

    writer.finalize()?;
    log::info!("Decode done. Total samples: {}", total_samples);
    Ok(total_samples)
}

type AudioDecoderResult = (
    Box<dyn symphonia::core::formats::FormatReader>,
    Box<dyn symphonia::core::codecs::Decoder>,
    u32,
    usize,
);

fn open_audio_decoder(file_path: &str) -> Result<AudioDecoderResult> {
    let file = File::open(Path::new(file_path))?;
    let mss = MediaSourceStream::new(Box::new(file), Default::default());

    let extension = Path::new(file_path)
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
    let reader = probed.format;
    let track = reader
        .default_track()
        .ok_or_else(|| anyhow::anyhow!("Could not get default track from audio file."))?;

    let sample_rate = track
        .codec_params
        .sample_rate
        .ok_or_else(|| anyhow::anyhow!("Could not get sample rate from audio file."))?;

    let num_channels = track.codec_params.channels.map(|c| c.count()).unwrap_or(1);

    let decoder =
        symphonia::default::get_codecs().make(&track.codec_params, &Default::default())?;

    Ok((reader, decoder, sample_rate, num_channels))
}

fn append_mono_f32(decoded: &AudioBufferRef, num_channels: usize, out: &mut Vec<f32>) {
    let inv = 1.0 / num_channels as f32;
    match decoded {
        AudioBufferRef::F32(buf) => {
            let frames = buf.frames();
            for i in 0..frames {
                let mut sum = 0.0f32;
                for ch in 0..num_channels.min(buf.spec().channels.count()) {
                    sum += buf.chan(ch)[i].clamped();
                }
                out.push(sum * inv);
            }
        }
        _ => append_mono_f32_generic(decoded, num_channels, out),
    }
}

fn append_mono_f32_generic(decoded: &AudioBufferRef, num_channels: usize, out: &mut Vec<f32>) {
    let inv = 1.0 / num_channels as f32;
    macro_rules! handle_buffer {
        ($buf:expr, $convert:expr) => {{
            let frames = $buf.frames();
            for i in 0..frames {
                let mut sum = 0.0f32;
                for ch in 0..num_channels.min($buf.spec().channels.count()) {
                    sum += $convert($buf.chan(ch)[i]);
                }
                out.push(sum * inv);
            }
        }};
    }
    match decoded {
        AudioBufferRef::U8(buf) => {
            handle_buffer!(buf, |s: u8| { (s.clamped() as f32 - 128.0) / 128.0 })
        }
        AudioBufferRef::U16(buf) => {
            handle_buffer!(buf, |s: u16| { (s.clamped() as f32 - 32768.0) / 32768.0 })
        }
        AudioBufferRef::U24(buf) => handle_buffer!(buf, |s: symphonia::core::sample::u24| {
            (s.clamped().0 as f32 - 8388608.0) / 8388608.0
        }),
        AudioBufferRef::U32(buf) => handle_buffer!(buf, |s: u32| {
            (s.clamped() as f32 - 2147483648.0) / 2147483648.0
        }),
        AudioBufferRef::S8(buf) => handle_buffer!(buf, |s: i8| { s.clamped() as f32 / 128.0 }),
        AudioBufferRef::S16(buf) => {
            handle_buffer!(buf, |s: i16| { s.clamped() as f32 / 32768.0 })
        }
        AudioBufferRef::S24(buf) => handle_buffer!(buf, |s: symphonia::core::sample::i24| {
            s.clamped().0 as f32 / 8388608.0
        }),
        AudioBufferRef::S32(buf) => {
            handle_buffer!(buf, |s: i32| { s.clamped() as f32 / 2147483648.0 })
        }
        AudioBufferRef::F32(buf) => handle_buffer!(buf, |s: f32| { s.clamped() }),
        AudioBufferRef::F64(buf) => handle_buffer!(buf, |s: f64| { s.clamped() as f32 }),
    }
}

fn append_mono_f64(decoded: &AudioBufferRef, num_channels: usize, out: &mut Vec<f64>) {
    let inv = 1.0 / num_channels as f64;
    macro_rules! handle_buffer {
        ($buf:expr, $convert:expr) => {{
            let frames = $buf.frames();
            for i in 0..frames {
                let mut sum = 0.0f64;
                for ch in 0..num_channels.min($buf.spec().channels.count()) {
                    sum += $convert($buf.chan(ch)[i]);
                }
                out.push(sum * inv);
            }
        }};
    }
    match decoded {
        AudioBufferRef::U8(buf) => {
            handle_buffer!(buf, |s: u8| { (s.clamped() as f64 - 128.0) / 128.0 })
        }
        AudioBufferRef::U16(buf) => {
            handle_buffer!(buf, |s: u16| { (s.clamped() as f64 - 32768.0) / 32768.0 })
        }
        AudioBufferRef::U24(buf) => handle_buffer!(buf, |s: symphonia::core::sample::u24| {
            (s.clamped().0 as f64 - 8388608.0) / 8388608.0
        }),
        AudioBufferRef::U32(buf) => handle_buffer!(buf, |s: u32| {
            (s.clamped() as f64 - 2147483648.0) / 2147483648.0
        }),
        AudioBufferRef::S8(buf) => handle_buffer!(buf, |s: i8| { s.clamped() as f64 / 128.0 }),
        AudioBufferRef::S16(buf) => {
            handle_buffer!(buf, |s: i16| { s.clamped() as f64 / 32768.0 })
        }
        AudioBufferRef::S24(buf) => handle_buffer!(buf, |s: symphonia::core::sample::i24| {
            s.clamped().0 as f64 / 8388608.0
        }),
        AudioBufferRef::S32(buf) => {
            handle_buffer!(buf, |s: i32| { s.clamped() as f64 / 2147483648.0 })
        }
        AudioBufferRef::F32(buf) => handle_buffer!(buf, |s: f32| { s.clamped() as f64 }),
        AudioBufferRef::F64(buf) => handle_buffer!(buf, |s: f64| { s.clamped() }),
    }
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
