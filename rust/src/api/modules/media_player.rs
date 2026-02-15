use anyhow::Context;
use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use hound::{SampleFormat, WavSpec, WavWriter};
use lazy_static::__Deref;
use midly::{MetaMessage, MidiMessage, Smf, TrackEventKind};
use pitch_shift::PitchShifter;
use rustysynth::{SoundFont, Synthesizer, SynthesizerSettings};
use std::fs;
use std::io::Cursor;
use std::mem::MaybeUninit;
use std::ops::DerefMut;
use std::sync::mpsc::{Receiver, Sender, channel};
use std::sync::{Arc, Mutex};
use std::thread::{self, JoinHandle};
use std::time::Duration;

use crate::api::audio::audio_buffer::AudioBufferReader;
use crate::api::audio::audio_buffer_interpolated::AudioBufferInterpolated;
use crate::api::audio::global::GLOBAL_AUDIO_LOCK;
use crate::api::util::constants::{
    AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, MEDIA_PLAYER_PLAYBACK_MAX_BUFFERING,
    MEDIA_PLAYER_PLAYBACK_MIN_BUFFERING, NUM_CHANNELS, OUTPUT_SAMPLE_RATE, PITCH_SHIFT_BUFFER_SIZE,
    PITCH_SHIFT_OVERSAMPLING, PITCH_SHIFT_WINDOW_DUR_MILLIS,
};
use crate::api::util::util_functions::{
    get_platform_default_cpal_output_config, speed_factor_to_halftones,
};

use ringbuf::{Consumer, SharedRb};
extern crate queues;

// DATA

struct ThreadData {
    _audio_out_thread: JoinHandle<()>,
    _pitch_shift_thread: JoinHandle<()>,
    stop_sender: Sender<()>,
    stop_sender_ps: Sender<()>,
}

struct AudioProcessingData {
    pitch_change_semitones: f32,
    speed_change_factor: f32,
    pitch_shifter: Option<PitchShifter>,
    buffer_after_speed_change: [f32; PITCH_SHIFT_BUFFER_SIZE],
    buffer_after_pitch_shift: [f32; PITCH_SHIFT_BUFFER_SIZE],
}

#[derive(Clone)]
struct Ev {
    t: f64,
    ch: u8,
    msg: MidiMessage,
}

type RingConsumerType = Consumer<f32, Arc<SharedRb<f32, Vec<MaybeUninit<f32>>>>>;

lazy_static! {
    static ref THREAD_DATA: Mutex<Option<ThreadData>> = Mutex::new(None);
    static ref SOURCE_DATA: Mutex<AudioBufferInterpolated> =
        Mutex::new(AudioBufferInterpolated::new(vec![]));
    static ref PROCESSING_DATA: Mutex<AudioProcessingData> = Mutex::new(AudioProcessingData {
        pitch_change_semitones: 0.0,
        speed_change_factor: 1.0,
        pitch_shifter: None,
        buffer_after_speed_change: [0.0; PITCH_SHIFT_BUFFER_SIZE],
        buffer_after_pitch_shift: [0.0; PITCH_SHIFT_BUFFER_SIZE],
    });
    static ref RING_CONSUMER: Mutex<Option<RingConsumerType>> = Mutex::new(None);
    static ref SECONDARY_SOURCE: Mutex<Option<AudioBufferReader>> = Mutex::new(None);
}

static VOLUME: Mutex<f32> = Mutex::new(1.0);
static SECONDARY_VOLUME: Mutex<f32> = Mutex::new(1.0);

// FUNCTIONS

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_create_stream() -> bool {
    media_player_trigger_destroy_stream();

    log::info!("Starting media player stream");

    let mut source_data = SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA");

    if source_data.get_is_empty() {
        return false;
    } else {
        source_data.set_playing(true);
    }

    // Reset secondary source to start of buffer
    if let Some(ref mut secondary) = *SECONDARY_SOURCE
        .lock()
        .expect("Could not lock mutex to SECONDARY_SOURCE")
    {
        secondary.reset();
        secondary.set_looping(source_data.get_is_looping());
    }

    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to get sample rate");

    *THREAD_DATA
        .lock()
        .expect("Could not lock mutex to THREAD_DATA") = None;
    PROCESSING_DATA
        .lock()
        .expect("Could not lock mutex to PROCESSING_DATA")
        .pitch_shifter = Some(PitchShifter::new(
        PITCH_SHIFT_WINDOW_DUR_MILLIS,
        sample_rate,
    ));

    let host = cpal::default_host();
    let device = host
        .default_output_device()
        .expect("no output device available");

    let config = get_platform_default_cpal_output_config(&device);
    if config.is_none() {
        log::info!(
            "Could not start media player output stream - Could not get default output config",
        );
        return false;
    }
    let config = config.expect("Could not get default stream output config");

    let rb = SharedRb::<f32, Vec<_>>::new(MEDIA_PLAYER_PLAYBACK_MAX_BUFFERING * 2);
    let (mut producer, consumer) = rb.split();
    *RING_CONSUMER
        .lock()
        .expect("Could not lock mutex to RING_CONSUMER") = Some(consumer);

    let (channel_sender, channel_receiver): (Sender<()>, Receiver<()>) = channel();
    let audio_out_thread = thread::spawn(move || {
        match device.build_output_stream(
            &config,
            on_audio_callback,
            move |_| log::info!("something went wrong with the audio stream"),
            Some(Duration::from_secs(AUDIO_STREAM_CREATE_TIMEOUT_SECONDS)),
        ) {
            Ok(stream_out) => {
                stream_out.play().expect("Could not play stream");

                while let Ok(command) = channel_receiver.recv() {
                    // this waits until stop is sent
                    thread_handle_command(command);
                }
            }
            Err(e) => log::info!("failed to build audio stream: {}", e),
        }
    });

    let (channel_sender_ps, channel_receiver_ps): (Sender<()>, Receiver<()>) = channel();
    let pitch_shift_thread = thread::spawn(move || {
        loop {
            let mut audio_processing_data = PROCESSING_DATA
                .lock()
                .expect("Could not lock mutex to PROCESSING_DATA");

            if let Ok(_command) = channel_receiver_ps.try_recv() {
                return;
            }

            if producer.len() < MEDIA_PLAYER_PLAYBACK_MAX_BUFFERING {
                let mut audio_source_data = SOURCE_DATA
                    .lock()
                    .expect("Could not lock mutex to SOURCE_DATA");

                if !audio_source_data.get_is_playing() {
                    media_player_trigger_destroy_stream();
                    return;
                }

                let read_speed = audio_processing_data.speed_change_factor;
                audio_source_data.get_samples(
                    &mut audio_processing_data.buffer_after_speed_change,
                    read_speed,
                );

                pitch_shift(&mut audio_processing_data);

                for sample in audio_processing_data.buffer_after_pitch_shift.iter() {
                    producer
                        .push(*sample)
                        .expect("Could not push samples to ringbuffer");
                }
            }
        }
    });

    *THREAD_DATA
        .lock()
        .expect("Could not lock mutex to THREAD_DATA") = Some(ThreadData {
        _audio_out_thread: audio_out_thread,
        _pitch_shift_thread: pitch_shift_thread,
        stop_sender: channel_sender,
        stop_sender_ps: channel_sender_ps,
    });

    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_trigger_destroy_stream() -> bool {
    match THREAD_DATA
        .lock()
        .expect("Could not lock mutex to THREAD_DATA")
        .deref()
    {
        Some(thread_data) => {
            let succcess_audio_thread = match thread_data.stop_sender.send(()) {
                Ok(_) => true,
                Err(_) => {
                    log::info!("Could not send stop signal to audio stream");
                    false
                }
            };
            let success_pitch_shift = match thread_data.stop_sender_ps.send(()) {
                Ok(_) => true,
                Err(_) => {
                    log::info!("Could not send stop signal to pitch shift thread");
                    false
                }
            };

            succcess_audio_thread && success_pitch_shift
        }
        None => {
            log::info!(
                "Mediaplayer failed to trigger audio stream to stop. No audio stream running.",
            );
            false
        }
    }
}

fn on_audio_callback(samples_out: &mut [f32], _: &cpal::OutputCallbackInfo) {
    let vol = *VOLUME
        .lock()
        .expect("Could not lock mutex to VOLUME to get it in on_audio_out_callback");

    if let Some(ring_consumer) = RING_CONSUMER
        .lock()
        .expect("Could not lock mutex to RING_CONSUMER")
        .deref_mut()
    {
        if ring_consumer.len() < MEDIA_PLAYER_PLAYBACK_MIN_BUFFERING.max(samples_out.len()) {
            log::info!("buffering...");
            return;
        }

        // write to output
        for i in 0..samples_out.len() / NUM_CHANNELS {
            match ring_consumer.pop() {
                Some(sample) => {
                    for channel in 0..NUM_CHANNELS {
                        let index_out = i * NUM_CHANNELS + channel;
                        samples_out[index_out] = sample * vol;
                    }
                }
                None => {
                    log::info!("Mediaplayer ring buffer empty - cannot write to audio output");
                    break;
                }
            }
        }

        // Mix in secondary audio source
        let secondary_vol = *SECONDARY_VOLUME
            .lock()
            .expect("Could not lock mutex to SECONDARY_VOLUME");
        if let Some(ref mut secondary) = *SECONDARY_SOURCE
            .lock()
            .expect("Could not lock mutex to SECONDARY_SOURCE")
        {
            secondary.add_samples_to_buffer(samples_out, secondary_vol);
        }
    }
}

fn pitch_shift(audio_processing_data: &mut AudioProcessingData) {
    if (audio_processing_data.speed_change_factor - 1.0).abs() < f32::EPSILON
        && audio_processing_data.pitch_change_semitones.abs() < f32::EPSILON
    {
        // no pitch shift needed
        for (i, sample) in audio_processing_data
            .buffer_after_speed_change
            .iter()
            .enumerate()
        {
            audio_processing_data.buffer_after_pitch_shift[i] = *sample;
        }
    } else {
        // pitch shift
        if let Some(pitch_shifter) = &mut audio_processing_data.pitch_shifter {
            pitch_shifter.shift_pitch(
                PITCH_SHIFT_OVERSAMPLING,
                audio_processing_data.pitch_change_semitones
                    - speed_factor_to_halftones(audio_processing_data.speed_change_factor),
                &audio_processing_data.buffer_after_speed_change,
                &mut audio_processing_data.buffer_after_pitch_shift,
            );
        } else {
            log::info!("pitch shifter not initialized");
        }
    }
}

fn thread_handle_command(_command: ()) {
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    *THREAD_DATA
        .lock()
        .expect("Could not lock mutex to THREAD_DATA to clear") = None;
    *RING_CONSUMER
        .lock()
        .expect("Could not lock mutex to RING_CONSUMER to clear") = None;
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to set playing flag")
        .set_playing(false);
    if let Some(ref mut secondary) = *SECONDARY_SOURCE
        .lock()
        .expect("Could not lock mutex to SECONDARY_SOURCE")
    {
        secondary.reset();
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_buffer(new_buffer: Vec<f32>) {
    *SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to set buffer") =
        AudioBufferInterpolated::new(new_buffer);
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_pos_factor(pos_factor: f32) -> bool {
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to compute rms")
        .set_playback_position_factor(pos_factor);
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_pitch(semitones: f32) -> bool {
    PROCESSING_DATA
        .lock()
        .expect("Could not lock mutex to PROCESSING_DATA to set pitch")
        .pitch_change_semitones = semitones;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_speed(speed_factor: f32) -> bool {
    PROCESSING_DATA
        .lock()
        .expect("Could not lock mutex to PROCESSING_DATA to set speed")
        .speed_change_factor = speed_factor;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_compute_rms(n_bins: usize) -> Vec<f32> {
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to compute rms")
        .compute_rms(n_bins)
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_loop_value(loop_on: bool) {
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to set loop flag")
        .set_loop(loop_on);
    if let Some(ref mut secondary) = *SECONDARY_SOURCE
        .lock()
        .expect("Could not lock mutex to SECONDARY_SOURCE")
    {
        secondary.set_looping(loop_on);
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_trim_by_factor(start_factor: f32, end_factor: f32) {
    SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to set loop flag")
        .set_trim(start_factor, end_factor);
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_new_volume(new_volume: f32) -> bool {
    *VOLUME
        .lock()
        .expect("Could not lock mutex to VOLUME to set new value") = new_volume;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub struct MediaPlayerState {
    pub playing: bool,
    pub playback_position_factor: f32,
    pub total_length_seconds: f32,
    pub looping: bool,
    pub trim_start_factor: f32,
    pub trim_end_factor: f32,
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_query_state() -> Option<MediaPlayerState> {
    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to get sample rate");

    let source_data = SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to get media player state");

    let playback_position_factor = source_data.get_playback_position_factor();
    let total_length_seconds = source_data.get_length_seconds(sample_rate as u32);
    let (trim_start_factor, trim_end_factor) = source_data.get_trim();

    Some(MediaPlayerState {
        playing: source_data.get_is_playing(),
        playback_position_factor,
        total_length_seconds,
        looping: source_data.get_is_looping(),
        trim_start_factor,
        trim_end_factor,
    })
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_secondary_buffer(new_buffer: Vec<f32>) {
    let looping = SOURCE_DATA
        .lock()
        .expect("Could not lock mutex to SOURCE_DATA to get loop flag")
        .get_is_looping();
    *SECONDARY_SOURCE
        .lock()
        .expect("Could not lock mutex to SECONDARY_SOURCE to set buffer") =
        Some(AudioBufferReader::new(Arc::new(new_buffer), looping, -1));
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_unload_secondary() {
    *SECONDARY_SOURCE
        .lock()
        .expect("Could not lock mutex to SECONDARY_SOURCE to unload") = None;
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_secondary_volume(new_volume: f32) -> bool {
    *SECONDARY_VOLUME
        .lock()
        .expect("Could not lock mutex to SECONDARY_VOLUME to set new value") = new_volume;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_render_mid_to_wav(
    midi_path: String,
    soundfont_path: String,
    wav_out_path: String,
    sample_rate: u32,
    gain: f32,
) -> bool {
    let result = (|| -> anyhow::Result<()> {
        let midi_bytes =
            fs::read(&midi_path).with_context(|| format!("reading midi {}", midi_path))?;
        let smf = Smf::parse(&midi_bytes).context("parsing midi")?;

        let ticks_per_quarter = match smf.header.timing {
            midly::Timing::Metrical(t) => t.as_int() as f64,
            _ => 480.0,
        };

        let mut tempo_changes: Vec<(u32, f64)> = Vec::new();
        for track in &smf.tracks {
            let mut tick: u32 = 0;
            for ev in track {
                tick = tick.saturating_add(ev.delta.as_int());
                if let TrackEventKind::Meta(MetaMessage::Tempo(us)) = ev.kind {
                    tempo_changes.push((tick, us.as_int() as f64));
                }
            }
        }
        tempo_changes.sort_by_key(|e| e.0);

        let ticks_to_seconds = |abs_tick: u32| -> f64 {
            let mut secs = 0.0;
            let mut last_tick: u32 = 0;
            let mut current_tempo_in_us = 500_000.0;
            for (t, us) in tempo_changes.iter() {
                if *t > abs_tick {
                    break;
                }
                let delta_ticks = *t - last_tick;
                secs +=
                    (delta_ticks as f64) * current_tempo_in_us / 1_000_000.0 / ticks_per_quarter;
                last_tick = *t;
                current_tempo_in_us = *us;
            }
            let dt = abs_tick - last_tick;
            secs += (dt as f64) * current_tempo_in_us / 1_000_000.0 / ticks_per_quarter;
            secs
        };

        let sf2_bytes = fs::read(&soundfont_path)
            .with_context(|| format!("reading soundfont {}", soundfont_path))?;
        let mut cursor = Cursor::new(sf2_bytes);
        let sf2 = SoundFont::new(&mut cursor).context("parsing soundfont")?;
        let sf2 = Arc::new(sf2);
        let settings = SynthesizerSettings::new(sample_rate as i32);
        let mut synth = Synthesizer::new(&sf2, &settings).context("creating synthesizer")?;
        synth.set_master_volume(gain);

        let mut events: Vec<Ev> = Vec::new();
        for track in &smf.tracks {
            let mut tick: u32 = 0;
            for event in track {
                tick = tick.saturating_add(event.delta.as_int());
                if let TrackEventKind::Midi { channel, message } = event.kind {
                    events.push(Ev {
                        t: ticks_to_seconds(tick),
                        ch: channel.as_int(),
                        msg: message,
                    });
                }
            }
        }
        events.sort_by(|a, b| a.t.partial_cmp(&b.t).unwrap());

        let spec = WavSpec {
            channels: 2,
            sample_rate,
            bits_per_sample: 16,
            sample_format: SampleFormat::Int,
        };
        let mut writer = WavWriter::create(&wav_out_path, spec)
            .with_context(|| format!("creating wav {}", wav_out_path))?;

        let mut index = 0usize;
        let mut time = 0.0f64;
        let delta_ticks = 128.0 / (sample_rate as f64);
        let mut left = vec![0.0f32; 128];
        let mut right = vec![0.0f32; 128];
        let end = events.last().map(|e| e.t).unwrap_or(0.0) + 2.0;

        while time < end {
            let next = time + delta_ticks;
            while index < events.len() && events[index].t < next {
                let event = &events[index];
                let ch = event.ch as i32;
                match event.msg {
                    MidiMessage::NoteOn { key, vel } => {
                        let k = key.as_int() as i32;
                        let v = vel.as_int() as i32;
                        if v == 0 {
                            synth.note_off(ch, k);
                        } else {
                            synth.note_on(ch, k, v);
                        }
                    }
                    MidiMessage::NoteOff { key, .. } => {
                        synth.note_off(ch, key.as_int() as i32);
                    }
                    _ => {}
                }
                index += 1;
            }

            synth.render(&mut left, &mut right);
            for i in 0..left.len() {
                let l = (left[i].clamp(-1.0, 1.0) * i16::MAX as f32) as i16;
                let r = (right[i].clamp(-1.0, 1.0) * i16::MAX as f32) as i16;
                writer.write_sample(l)?;
                writer.write_sample(r)?;
            }
            time = next;
        }

        writer.finalize()?;
        Ok(())
    })();

    if let Err(e) = result {
        log::error!("Error rendering MIDI to WAV: {:?}", e);
        return false;
    }

    true
}
