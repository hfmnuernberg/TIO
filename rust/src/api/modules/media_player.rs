use anyhow::Context;
use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use hound::{SampleFormat, WavSpec, WavWriter};
use midly::{MetaMessage, MidiMessage, Smf, TrackEventKind};
use pitch_shift::PitchShifter;
use rustysynth::{SoundFont, Synthesizer, SynthesizerSettings};
use std::collections::HashMap;
use std::fs;
use std::io::Cursor;
use std::mem::MaybeUninit;
use std::sync::mpsc::{Receiver, Sender, channel};
use std::sync::{Arc, Mutex};
use std::thread::{self, JoinHandle};
use std::time::Duration;

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
    buffer_after_speed_change: Vec<f32>,
    buffer_after_pitch_shift: Vec<f32>,
}

#[derive(Clone)]
struct Ev {
    t: f64,
    ch: u8,
    msg: MidiMessage,
}

type RingConsumerType = Consumer<f32, Arc<SharedRb<f32, Vec<MaybeUninit<f32>>>>>;

#[flutter_rust_bridge::frb(ignore)]
struct PlayerInstance {
    thread_data: Option<ThreadData>,
    source_data: AudioBufferInterpolated,
    processing_data: Box<AudioProcessingData>,
    ring_consumer: Arc<Mutex<Option<RingConsumerType>>>,
    volume: Arc<Mutex<f32>>,
}

impl Default for PlayerInstance {
    fn default() -> Self {
        Self {
            thread_data: None,
            source_data: AudioBufferInterpolated::new(vec![]),
            processing_data: Box::new(AudioProcessingData {
                pitch_change_semitones: 0.0,
                speed_change_factor: 1.0,
                pitch_shifter: None,
                buffer_after_speed_change: vec![0.0; PITCH_SHIFT_BUFFER_SIZE],
                buffer_after_pitch_shift: vec![0.0; PITCH_SHIFT_BUFFER_SIZE],
            }),
            ring_consumer: Arc::new(Mutex::new(None)),
            volume: Arc::new(Mutex::new(1.0)),
        }
    }
}

lazy_static! {
    static ref PLAYERS: Mutex<HashMap<u32, PlayerInstance>> = Mutex::new(HashMap::new());
}

// FUNCTIONS

fn with_player<F, R>(id: u32, f: F) -> R
where
    F: FnOnce(&mut PlayerInstance) -> R,
{
    let mut players = PLAYERS.lock().expect("Could not lock PLAYERS");
    let instance = players.entry(id).or_default();
    f(instance)
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_create_stream(id: u32) -> bool {
    media_player_trigger_destroy_stream(id);

    log::info!("Starting media player stream (id={})", id);

    let mut players = PLAYERS.lock().expect("Could not lock PLAYERS");
    let instance = players.entry(id).or_default();

    if instance.source_data.get_is_empty() {
        return false;
    }
    instance.source_data.set_playing(true);

    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to get sample rate");

    instance.thread_data = None;
    instance.processing_data.pitch_shifter = Some(PitchShifter::new(
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

    let ring_consumer = Arc::clone(&instance.ring_consumer);
    *ring_consumer.lock().expect("Could not lock ring_consumer") = Some(consumer);

    let callback_volume = Arc::clone(&instance.volume);
    let callback_ring_consumer = Arc::clone(&instance.ring_consumer);

    let (channel_sender, channel_receiver): (Sender<()>, Receiver<()>) = channel();
    let callback_id = id;
    let audio_out_thread = thread::spawn(move || {
        match device.build_output_stream(
            &config,
            move |samples_out: &mut [f32], _: &cpal::OutputCallbackInfo| {
                on_audio_callback(samples_out, &callback_volume, &callback_ring_consumer);
            },
            move |_| log::info!("something went wrong with the audio stream"),
            Some(Duration::from_secs(AUDIO_STREAM_CREATE_TIMEOUT_SECONDS)),
        ) {
            Ok(stream_out) => {
                stream_out.play().expect("Could not play stream");

                while let Ok(command) = channel_receiver.recv() {
                    thread_handle_command(callback_id, command);
                }
            }
            Err(e) => log::info!("failed to build audio stream: {}", e),
        }
    });

    let pitch_shift_id = id;
    let (channel_sender_ps, channel_receiver_ps): (Sender<()>, Receiver<()>) = channel();
    let pitch_shift_thread = thread::spawn(move || {
        loop {
            let mut players = PLAYERS.lock().expect("Could not lock PLAYERS");
            let Some(instance) = players.get_mut(&pitch_shift_id) else {
                return;
            };

            if let Ok(_command) = channel_receiver_ps.try_recv() {
                return;
            }

            if producer.len() < MEDIA_PLAYER_PLAYBACK_MAX_BUFFERING {
                if !instance.source_data.get_is_playing() {
                    drop(players);
                    media_player_trigger_destroy_stream(pitch_shift_id);
                    return;
                }

                let read_speed = instance.processing_data.speed_change_factor;
                instance.source_data.get_samples(
                    &mut instance.processing_data.buffer_after_speed_change,
                    read_speed,
                );

                pitch_shift(&mut instance.processing_data);

                for sample in instance.processing_data.buffer_after_pitch_shift.iter() {
                    producer
                        .push(*sample)
                        .expect("Could not push samples to ringbuffer");
                }
            }
        }
    });

    instance.thread_data = Some(ThreadData {
        _audio_out_thread: audio_out_thread,
        _pitch_shift_thread: pitch_shift_thread,
        stop_sender: channel_sender,
        stop_sender_ps: channel_sender_ps,
    });

    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_trigger_destroy_stream(id: u32) -> bool {
    let players = PLAYERS.lock().expect("Could not lock PLAYERS");
    let Some(instance) = players.get(&id) else {
        log::info!(
            "Mediaplayer (id={}) failed to trigger audio stream to stop. No player instance.",
            id,
        );
        return false;
    };

    match &instance.thread_data {
        Some(thread_data) => {
            let success_audio_thread = match thread_data.stop_sender.send(()) {
                Ok(_) => true,
                Err(_) => {
                    log::info!("Could not send stop signal to audio stream (id={})", id);
                    false
                }
            };
            let success_pitch_shift = match thread_data.stop_sender_ps.send(()) {
                Ok(_) => true,
                Err(_) => {
                    log::info!(
                        "Could not send stop signal to pitch shift thread (id={})",
                        id
                    );
                    false
                }
            };

            success_audio_thread && success_pitch_shift
        }
        None => {
            log::info!(
                "Mediaplayer (id={}) failed to trigger audio stream to stop. No audio stream running.",
                id,
            );
            false
        }
    }
}

fn on_audio_callback(
    samples_out: &mut [f32],
    volume: &Arc<Mutex<f32>>,
    ring_consumer: &Arc<Mutex<Option<RingConsumerType>>>,
) {
    let vol = *volume
        .lock()
        .expect("Could not lock volume in on_audio_callback");

    if let Some(consumer) = ring_consumer
        .lock()
        .expect("Could not lock ring_consumer in on_audio_callback")
        .as_mut()
    {
        if consumer.len() < MEDIA_PLAYER_PLAYBACK_MIN_BUFFERING.max(samples_out.len()) {
            log::info!("buffering...");
            return;
        }

        for i in 0..samples_out.len() / NUM_CHANNELS {
            match consumer.pop() {
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
    }
}

fn pitch_shift(audio_processing_data: &mut AudioProcessingData) {
    if (audio_processing_data.speed_change_factor - 1.0).abs() < f32::EPSILON
        && audio_processing_data.pitch_change_semitones.abs() < f32::EPSILON
    {
        for (i, sample) in audio_processing_data
            .buffer_after_speed_change
            .iter()
            .enumerate()
        {
            audio_processing_data.buffer_after_pitch_shift[i] = *sample;
        }
    } else if let Some(pitch_shifter) = &mut audio_processing_data.pitch_shifter {
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

fn thread_handle_command(id: u32, _command: ()) {
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    let mut players = PLAYERS.lock().expect("Could not lock PLAYERS");
    if let Some(instance) = players.get_mut(&id) {
        instance.thread_data = None;
        *instance
            .ring_consumer
            .lock()
            .expect("Could not lock ring_consumer to clear") = None;
        instance.source_data.set_playing(false);
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_buffer(id: u32, new_buffer: Vec<f32>) {
    with_player(id, |instance| {
        instance.source_data = AudioBufferInterpolated::new(new_buffer);
    });
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_pos_factor(id: u32, pos_factor: f32) -> bool {
    with_player(id, |instance| {
        instance
            .source_data
            .set_playback_position_factor(pos_factor);
        true
    })
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_pitch(id: u32, semitones: f32) -> bool {
    with_player(id, |instance| {
        instance.processing_data.pitch_change_semitones = semitones;
        true
    })
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_speed(id: u32, speed_factor: f32) -> bool {
    with_player(id, |instance| {
        instance.processing_data.speed_change_factor = speed_factor;
        true
    })
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_compute_rms(id: u32, n_bins: usize) -> Vec<f32> {
    with_player(id, |instance| instance.source_data.compute_rms(n_bins))
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_loop_value(id: u32, loop_on: bool) {
    with_player(id, |instance| {
        instance.source_data.set_loop(loop_on);
    });
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_trim_by_factor(id: u32, start_factor: f32, end_factor: f32) {
    with_player(id, |instance| {
        instance.source_data.set_trim(start_factor, end_factor);
    });
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_set_new_volume(id: u32, new_volume: f32) -> bool {
    with_player(id, |instance| {
        *instance
            .volume
            .lock()
            .expect("Could not lock volume to set new value") = new_volume;
        true
    })
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
pub fn media_player_query_state(id: u32) -> Option<MediaPlayerState> {
    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to get sample rate");

    with_player(id, |instance| {
        let playback_position_factor = instance.source_data.get_playback_position_factor();
        let total_length_seconds = instance.source_data.get_length_seconds(sample_rate as u32);
        let (trim_start_factor, trim_end_factor) = instance.source_data.get_trim();

        Some(MediaPlayerState {
            playing: instance.source_data.get_is_playing(),
            playback_position_factor,
            total_length_seconds,
            looping: instance.source_data.get_is_looping(),
            trim_start_factor,
            trim_end_factor,
        })
    })
}

#[flutter_rust_bridge::frb(ignore)]
pub fn media_player_destroy(id: u32) {
    let mut players = PLAYERS.lock().expect("Could not lock PLAYERS");
    if players.remove(&id).is_some() {
        log::info!("Destroyed media player instance (id={})", id);
    }
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
