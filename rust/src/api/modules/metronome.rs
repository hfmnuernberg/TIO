use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use enum_map::EnumMap;
use lazy_static::__Deref;
use rand::Rng;

use std::{
    ops::Neg,
    sync::{
        mpsc::{channel, Receiver, Sender},
        Arc, Mutex,
    },
    thread::{self, JoinHandle},
    time::Duration,
};

use crate::{
    api::audio::{audio_buffer::AudioBufferReader, global::GLOBAL_AUDIO_LOCK},
    api::modules::metronome_rhythm::BeatSound,
    api::util::{
        constants::{AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, OUTPUT_SAMPLE_RATE, SAMPLE_RATE_HALF, SAMPLE_RATE_IN_KHZ},
        util_functions::{
            get_platform_default_cpal_output_config, quarters_to_samples, samples_to_quarters,
        },
    },
};

use super::metronome_rhythm::{BeatType, MetroBar, MetroRhythmUnpacked};

// DATA

lazy_static! {
    static ref THREAD: Mutex<Option<JoinHandle<()>>> = Mutex::new(None);
    static ref THREAD_SENDER: Mutex<Option<Sender<CommandMetro>>> = Mutex::new(None);
    static ref RHYTHM: Mutex<MetroRhythmUnpacked> =
        Mutex::new(MetroRhythmUnpacked::new(vec![], false));
    static ref RHYTHM_2: Mutex<MetroRhythmUnpacked> =
        Mutex::new(MetroRhythmUnpacked::new(vec![], true));
    static ref BPM: Mutex<f32> = Mutex::new(90.0);
    static ref LOADED_AUDIO_BUFFERS: Mutex<EnumMap<BeatSound, Arc<Vec<f32>>>> =
        Mutex::new(enum_map! {
            BeatSound::Accented => Arc::new(vec![0.5, 0.3, 0.2, 0.1]),
            BeatSound::Accented2 => Arc::new(vec![0.5, 0.3, 0.2, 0.1]),
            BeatSound::Unaccented => Arc::new(vec![0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]),
            BeatSound::Unaccented2 => Arc::new(vec![0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]),
            BeatSound::PolyAccented => Arc::new(vec![0.8, 0.2, 0.1]),
            BeatSound::PolyAccented2 => Arc::new(vec![0.8, 0.2, 0.1]),
            BeatSound::PolyUnaccented => Arc::new(vec![0.8, 0.4]),
            BeatSound::PolyUnaccented2 => Arc::new(vec![0.8, 0.4]),
            BeatSound::Muted => Arc::new(vec![]),
        });
    static ref CURRENTLY_PLAYING_BUFFERS: Mutex<Vec<AudioBufferReader>> = Mutex::new(vec![]);
    static ref BEAT_EVENT_HAPPENED: Mutex<Vec<BeatHappenedEvent>> = Mutex::new(Vec::new());
    static ref MUTED: Mutex<bool> = Mutex::new(false);
    static ref BEAT_MUTE_CHANCE: Mutex<f32> = Mutex::new(0.0);
}

#[derive(Debug, Clone)]
pub struct BeatHappenedEvent {
    pub milliseconds_before_start: i32,
    pub is_random_mute: bool,
    pub bar_index: i32,
    pub is_poly: bool,
    pub is_secondary: bool,
    pub beat_index: i32,
}

static VOLUME: Mutex<f32> = Mutex::new(1.0);

// COMMANDS

enum CommandMetro {
    Stop,
}

// FUNCTIONS

#[flutter_rust_bridge::frb(ignore)]
pub fn metronome_load_audio_buffer(sound_type: BeatSound, buffer: Vec<f32>) -> bool {
    let mut sounds_by_type = LOADED_AUDIO_BUFFERS
        .lock()
        .expect("Could not lock mutex to LOADED_AUDIO_BUFFERS");
    sounds_by_type[sound_type] = Arc::new(buffer);
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn metronome_create_audio_stream() -> bool {
    metronome_trigger_destroy_stream();

    let host = cpal::default_host();
    let device = host
        .default_output_device()
        .expect("no output device available");

    let config = get_platform_default_cpal_output_config(&device);
    if config.is_none() {
        log::info!("Could not start metronome output stream - Could not get default output config");
        return false;
    }
    let config = config.expect("Could not get default stream output config");

    let (tx, rx): (Sender<CommandMetro>, Receiver<CommandMetro>) = channel();
    let join_handle = thread::spawn(move || {
        let stream_out = device
            .build_output_stream(
                &config,
                on_audio_callback,
                move |_| {
                    log::info!("something went wrong with the audio stream");
                },
                Some(Duration::from_secs(AUDIO_STREAM_CREATE_TIMEOUT_SECONDS)),
            )
            .expect("Could not create output stream");
        stream_out.play().expect("Could not play stream");

        while let Ok(command) = rx.recv() {
            audio_out_thread_handle_command(command);
        }
    });
    *THREAD.lock().expect("Could not lock mutex to THREAD") = Some(join_handle);
    *THREAD_SENDER
        .lock()
        .expect("Could not lock mutex to THREAD_SENDER") = Some(tx);
    true
}

fn on_audio_callback(data: &mut [f32], _: &cpal::OutputCallbackInfo) {
    let mut rythm = RHYTHM.lock().expect("Could not lock mutex to RHYTHM");
    let mut rythm_2 = RHYTHM_2.lock().expect("Could not lock mutex to RHYTHM_2");
    let bpm = *BPM.lock().expect("Could not lock mutex to BPM");

    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to OUTPUT_SAMPLE_RATE");

    let data_dur_quarters = samples_to_quarters(data.len() as f32, sample_rate as f32, bpm);
    let next_events = rythm.get_next_events(data_dur_quarters);
    let next_events_2 = rythm_2.get_next_events(data_dur_quarters);

    // add new events

    let loaded_buffers = LOADED_AUDIO_BUFFERS
        .lock()
        .expect("Could not lock mutex to LOADED_AUDIO_BUFFERS");
    let mut playing_buffers = CURRENTLY_PLAYING_BUFFERS
        .lock()
        .expect("Could not lock mutex to CURRENTLY_PLAYING_BUFFERS");

    for s in data.iter_mut() {
        *s = 0.0;
    }

    let beat_mute_chance = *BEAT_MUTE_CHANCE
        .lock()
        .expect("Could not lock mutex to BEAT_MUTE_CHANCE");
    let mut rng = rand::thread_rng();

    let mut beat_event_queue = BEAT_EVENT_HAPPENED
        .lock()
        .expect("Could not lock mutex to BEAT_EVENT_HAPPENED to set true");

    for next_event in next_events.iter().chain(next_events_2.iter()) {
        let is_random_mute = rng.gen_range(0.0..1.0) < beat_mute_chance;
        let samples_before_start =
            quarters_to_samples(next_event.quarters_until_start, sample_rate as f32, bpm) + SAMPLE_RATE_HALF;

        if next_event.beat_sound != BeatSound::Muted && !is_random_mute {
            playing_buffers.push(AudioBufferReader::new(
                loaded_buffers[next_event.beat_sound].clone(),
                false,
                samples_before_start.neg(),
            ));
        }

        if beat_event_queue.len() < 4 {
            beat_event_queue.push(BeatHappenedEvent {
                beat_index: next_event.beat_index,
                is_poly: next_event.is_poly,
                bar_index: next_event.bar_index,
                milliseconds_before_start: (samples_before_start as f32 / SAMPLE_RATE_IN_KHZ).round() as i32,
                is_random_mute,
                is_secondary: next_event.is_secondary,
            });
        }
    }

    // output playing events

    let vol = *VOLUME
        .lock()
        .expect("Could not lock mutex to VOLUME to get it in on_audio_callback");

    for buffer in playing_buffers.iter_mut() {
        buffer.add_samples_to_buffer(data, vol);
    }
    playing_buffers.retain(|buf| !buf.is_done);

    if *MUTED.lock().expect("Could not lock mutex to MUTED") {
        for s in data.iter_mut() {
            *s = 0.0;
        }
    }
}

fn audio_out_thread_handle_command(command: CommandMetro) {
    match command {
        CommandMetro::Stop => {
            let _guard = GLOBAL_AUDIO_LOCK
                .lock()
                .expect("Could not lock global audio lock");
            *THREAD_SENDER.lock().expect("Could not lock mutex") = None;
            *THREAD.lock().expect("Could not lock mutex") = None;
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn metronome_trigger_destroy_stream() -> bool {
    match THREAD_SENDER
        .lock()
        .expect("Could not lock mutex to THREAD_SENDER")
        .deref()
    {
        Some(thread_record_sender) => match thread_record_sender.send(CommandMetro::Stop) {
            Ok(_) => {}
            Err(_) => {
                log::info!("Could not send stop command to metronome thread");
                return false;
            }
        },
        None => {
            log::info!("Could not send command to destroy metronome audio stream - no sender");
        }
    }

    RHYTHM
        .lock()
        .expect("Could not lock mutex to RHYTHM")
        .reset_playhead();
    RHYTHM_2
        .lock()
        .expect("Could not lock mutex to RHYTHM_2")
        .reset_playhead();
    CURRENTLY_PLAYING_BUFFERS
        .lock()
        .expect("Could not lock mutex to CURRENTLY_PLAYING_BUFFERS")
        .clear();

    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn metronome_set_new_bpm(new_bpm: f32) -> bool {
    *BPM.lock().expect("Could not lock mutex BPM to set bpm") = new_bpm;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn metronome_set_rhythm_from_bars(bars: Vec<MetroBar>, bars_2: Vec<MetroBar>) -> bool {
    if bars.is_empty() {
        *RHYTHM
            .lock()
            .expect("Could not lock mutex to RHYTHM to set bars") = MetroRhythmUnpacked::new(
            vec![MetroBar {
                id: 0,
                beats: vec![
                    BeatType::Accented,
                    BeatType::Unaccented,
                    BeatType::Unaccented,
                    BeatType::Unaccented,
                ],
                poly_beats: vec![],
                beat_len: 1.0,
            }],
            false,
        );
    } else {
        *RHYTHM
            .lock()
            .expect("Could not lock mutex to RHYTHM to set bars") =
            MetroRhythmUnpacked::new(bars, false);
    }
    *RHYTHM_2
        .lock()
        .expect("Could not lock mutex to RHYTHM to set bars") =
        MetroRhythmUnpacked::new(bars_2, true);
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn metronome_get_beat_event() -> Option<BeatHappenedEvent> {
    let mut beat_happened_lock = BEAT_EVENT_HAPPENED
        .lock()
        .expect("Could not lock mutex to BEAT_EVENT_HAPPENED");
    beat_happened_lock.pop()
}

#[flutter_rust_bridge::frb(ignore)]
pub fn metronome_set_audio_muted(muted: bool) -> bool {
    *MUTED
        .lock()
        .expect("Could not lock mutex to MUTED to set muted state") = muted;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn metronome_set_new_mute_chance(mute_chance: f32) -> bool {
    *BEAT_MUTE_CHANCE
        .lock()
        .expect("Could not lock mutex to BEAT_MUTE_CHANCE to set new value") = mute_chance;
    true
}

#[flutter_rust_bridge::frb(ignore)]
pub fn metronome_set_new_volume(new_volume: f32) -> bool {
    *VOLUME
        .lock()
        .expect("Could not lock mutex to VOLUME to set new value") = new_volume;
    true
}
