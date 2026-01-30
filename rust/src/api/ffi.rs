/***
 * This file contains all functions that are exposed to Flutter.
 */
use flutter_rust_bridge::frb;

use crate::{
    api::audio::global::GLOBAL_AUDIO_LOCK,
    api::modules::{
        generator::{
            generator_create_audio_stream, generator_start_note, generator_stop_current_note,
            generator_trigger_destroy_stream,
        },
        media_player::{
            MediaPlayerState, media_player_compute_rms, media_player_create_stream,
            media_player_query_state, media_player_render_mid_to_wav, media_player_set_buffer,
            media_player_set_loop_value, media_player_set_new_volume, media_player_set_pitch,
            media_player_set_pos_factor, media_player_set_speed, media_player_set_trim_by_factor,
            media_player_trigger_destroy_stream,
        },
        metronome::{
            BeatHappenedEvent, metronome_create_audio_stream, metronome_get_beat_event,
            metronome_load_audio_buffer, metronome_set_audio_muted, metronome_set_new_bpm,
            metronome_set_new_mute_chance, metronome_set_new_volume,
            metronome_set_rhythm_from_bars, metronome_trigger_destroy_stream,
        },
        metronome_rhythm::{BeatSound, MetroBar},
        piano::{
            piano_create_audio_stream, piano_load_and_setup, piano_set_amp,
            piano_trigger_destroy_stream, piano_trigger_note_off, piano_trigger_note_on,
            piano_trigger_set_concert_pitch,
        },
        recorder::{
            recorder_create_stream, recorder_get_buffer_samples, recorder_trigger_destroy_stream,
        },
        tuner::{
            tuner_compute_freq_from_ringbuffer, tuner_create_stream, tuner_trigger_destroy_stream,
        },
    },
    api::util::{
        constants::{INPUT_SAMPLE_RATE, OUTPUT_SAMPLE_RATE},
        util_functions::{
            get_platform_default_input_sample_rate, get_platform_default_output_sample_rate,
            load_audio_file,
        },
    },
};

pub fn init_audio() {
    log::info!("init audio");
    let _guard = GLOBAL_AUDIO_LOCK.lock();
    if _guard.is_err() {
        log::info!("Could not lock global audio lock to init audio settings");
        return;
    }

    let fallback_sample_rate = if cfg!(target_os = "android") {
        44100
    } else {
        48000
    };

    let output_sample_rate = match get_platform_default_output_sample_rate() {
        Ok(sample_rate) => sample_rate as usize,
        Err(err) => {
            log::info!(
                "Could not get platform default output sample rate, setting to fallback: {} - Error: {}",
                fallback_sample_rate,
                err
            );
            fallback_sample_rate
        }
    };

    let input_sample_rate = match get_platform_default_input_sample_rate() {
        Ok(sample_rate) => sample_rate as usize,
        Err(err) => {
            log::info!(
                "Could not get platform default input sample rate, setting to fallback: {} - Error: {}",
                fallback_sample_rate,
                err
            );
            fallback_sample_rate
        }
    };

    *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock OUTPUT_SAMPLE_RATE") = output_sample_rate;
    *INPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock INPUT_SAMPLE_RATE") = input_sample_rate;
}

// pub fn poll_debug_log_message() -> Option<String> {
//     dequeue_log_message()
// }

// tuner

pub fn tuner_get_frequency() -> Option<f32> {
    log::info!("tuner get frequency");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.try_lock() {
        tuner_compute_freq_from_ringbuffer()
    } else {
        None
    }
}

pub fn tuner_start() -> bool {
    log::info!("tuner start");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        tuner_create_stream()
    } else {
        false
    }
}

pub fn tuner_stop() -> bool {
    log::info!("tuner stop");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        tuner_trigger_destroy_stream()
    } else {
        false
    }
}

// generator

pub fn generator_start() -> bool {
    log::info!("generator start");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        generator_create_audio_stream()
    } else {
        false
    }
}

pub fn generator_stop() -> bool {
    log::info!("generator stop");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        generator_trigger_destroy_stream()
    } else {
        false
    }
}

pub fn generator_note_on(new_freq: f32) -> bool {
    log::info!("generator note on");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        generator_start_note(new_freq)
    } else {
        false
    }
}

pub fn generator_note_off() -> bool {
    log::info!("generator note off");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        generator_stop_current_note()
    } else {
        false
    }
}

pub fn piano_set_concert_pitch(new_concert_pitch: f32) -> bool {
    log::info!("piano set concert pitch");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        piano_trigger_set_concert_pitch(new_concert_pitch)
    } else {
        false
    }
}

lazy_static! {
    static ref MEDIA_PLAYER_WAV_CACHE: std::sync::Mutex<std::collections::HashMap<String, Vec<f32>>> =
        std::sync::Mutex::new(std::collections::HashMap::new());
}

const MEDIA_PLAYER_WAV_CACHE_MAX_ENTRIES: usize = 4;

// media player

pub fn media_player_load_wav(wav_file_path: String) -> bool {
    log::info!("media player load wav: {}", wav_file_path);

    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        // Fast path: return cached decoded buffer (avoid disk I/O on tool switching).
        {
            let cache = MEDIA_PLAYER_WAV_CACHE
                .lock()
                .expect("Could not lock MEDIA_PLAYER_WAV_CACHE");
            if let Some(buffer) = cache.get(&wav_file_path) {
                media_player_set_buffer(buffer.clone());
                log::info!("media player load wav done (cache hit)");
                return true;
            }
        }

        // Slow path: decode from disk and cache it.
        match load_audio_file(wav_file_path.clone()) {
            Ok(buffer) => {
                media_player_set_buffer(buffer.clone());

                let mut cache = MEDIA_PLAYER_WAV_CACHE
                    .lock()
                    .expect("Could not lock MEDIA_PLAYER_WAV_CACHE");

                // Simple size cap: if full and this is a new entry, drop an arbitrary existing entry.
                if !cache.contains_key(&wav_file_path)
                    && cache.len() >= MEDIA_PLAYER_WAV_CACHE_MAX_ENTRIES
                    && let Some(key) = cache.keys().next().cloned()
                {
                    cache.remove(&key);
                }

                cache.insert(wav_file_path, buffer);

                log::info!("media player load wav done (cached)");
                true
            }
            Err(e) => {
                log::info!("media player load wav failed: {}", e);
                false
            }
        }
    } else {
        false
    }
}

pub fn media_player_start() -> bool {
    log::info!("media player play start");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_create_stream()
    } else {
        false
    }
}

pub fn media_player_stop() -> bool {
    log::info!("media player play stop");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_trigger_destroy_stream()
    } else {
        false
    }
}

pub fn media_player_start_recording() -> bool {
    log::info!("media player recording start");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        recorder_create_stream()
    } else {
        false
    }
}

pub fn media_player_stop_recording() -> bool {
    log::info!("media player recording stop");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        recorder_trigger_destroy_stream()
    } else {
        false
    }
}

pub fn media_player_get_recording_samples() -> Vec<f64> {
    log::info!("media player get recording samples");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        recorder_get_buffer_samples()
    } else {
        Vec::new()
    }
}

pub fn media_player_set_pitch_semitones(pitch_semitones: f32) -> bool {
    log::info!("media player set pitch semitones: {}", pitch_semitones);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_set_pitch(pitch_semitones)
    } else {
        false
    }
}

pub fn media_player_set_speed_factor(speed_factor: f32) -> bool {
    log::info!("media player set speed factor: {}", speed_factor);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_set_speed(speed_factor)
    } else {
        false
    }
}

pub fn media_player_set_trim(start_factor: f32, end_factor: f32) {
    log::info!(
        "media player set trim: start: {}, end: {}",
        start_factor,
        end_factor
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_set_trim_by_factor(start_factor, end_factor)
    }
}

#[frb(type_64bit_int)]
pub fn media_player_get_rms(n_bins: usize) -> Vec<f32> {
    log::info!("media player get rms: n_bins: {}", n_bins);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_compute_rms(n_bins)
    } else {
        Vec::new()
    }
}

pub fn media_player_set_loop(looping: bool) {
    log::info!("media player set loop: {}", looping);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_set_loop_value(looping)
    }
}

pub fn media_player_get_state() -> Option<MediaPlayerState> {
    log::info!("media player get state");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_query_state()
    } else {
        None
    }
}

pub fn media_player_set_playback_pos_factor(pos_factor: f32) -> bool {
    log::info!("media player set pos factor: {}", pos_factor);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_set_pos_factor(pos_factor)
    } else {
        false
    }
}

pub fn media_player_set_volume(volume: f32) -> bool {
    log::info!("media player set volume: {}", volume);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_set_new_volume(volume)
    } else {
        false
    }
}

pub fn media_player_render_midi_to_wav(
    midi_path: String,
    sound_font_path: String,
    wav_out_path: String,
    sample_rate: u32,
    gain: f32,
) -> bool {
    log::info!(
        "media player render midi to wav: {}, {}, {}, {}, {}",
        midi_path,
        sound_font_path,
        wav_out_path,
        sample_rate,
        gain
    );
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        media_player_render_mid_to_wav(midi_path, sound_font_path, wav_out_path, sample_rate, gain)
    } else {
        false
    }
}

// metronome

pub fn metronome_start() -> bool {
    log::info!("metronome start");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        metronome_create_audio_stream()
    } else {
        false
    }
}

pub fn metronome_stop() -> bool {
    log::info!("metronome stop");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        metronome_trigger_destroy_stream()
    } else {
        false
    }
}

pub fn metronome_set_bpm(bpm: f32) -> bool {
    log::info!("metronome set bpm: {}", bpm);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        metronome_set_new_bpm(bpm)
    } else {
        false
    }
}

pub fn metronome_load_file(beat_type: BeatSound, wav_file_path: String) -> bool {
    log::info!("metronome load file: {}", wav_file_path);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        match load_audio_file(wav_file_path) {
            Ok(buffer) => {
                metronome_load_audio_buffer(beat_type, buffer);
                true
            }
            Err(e) => {
                log::info!("metronome load file failed: {}", e);
                false
            }
        }
    } else {
        false
    }
}

pub fn metronome_set_rhythm(bars: Vec<MetroBar>, bars_2: Vec<MetroBar>) -> bool {
    log::info!("metronome set rhythm");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        metronome_set_rhythm_from_bars(bars, bars_2)
    } else {
        false
    }
}

pub fn metronome_poll_beat_event_happened() -> Option<BeatHappenedEvent> {
    log::info!("metronome poll beat event happened");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.try_lock() {
        metronome_get_beat_event()
    } else {
        None
    }
}

pub fn metronome_set_muted(muted: bool) -> bool {
    log::info!("metronome set muted: {}", muted);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        metronome_set_audio_muted(muted)
    } else {
        false
    }
}

pub fn metronome_set_beat_mute_chance(mute_chance: f32 /*[0.0, 1.0]*/) -> bool {
    log::info!("metronome set beat mute chance: {}", mute_chance);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        metronome_set_new_mute_chance(mute_chance)
    } else {
        false
    }
}

pub fn metronome_set_volume(volume: f32) -> bool {
    log::info!("metronome set volume: {}", volume);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        metronome_set_new_volume(volume)
    } else {
        false
    }
}

// piano

pub fn piano_setup(sound_font_path: String) -> bool {
    log::info!("piano setup: {}", sound_font_path);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        piano_load_and_setup(&sound_font_path)
    } else {
        false
    }
}

pub fn piano_start() -> bool {
    log::info!("piano start");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        piano_create_audio_stream()
    } else {
        false
    }
}

pub fn piano_stop() -> bool {
    log::info!("piano stop");
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        piano_trigger_destroy_stream()
    } else {
        false
    }
}

pub fn piano_note_on(note: i32) -> bool {
    let success = piano_trigger_note_on(note);
    log::info!("piano note on: {}", note);
    success
}

pub fn piano_note_off(note: i32) -> bool {
    let success = piano_trigger_note_off(note);
    log::info!("piano note off: {}", note);
    success
}

pub fn piano_set_volume(volume: f32) -> bool {
    log::info!("piano set volume: {}", volume);
    if let Ok(_guard) = GLOBAL_AUDIO_LOCK.lock() {
        piano_set_amp(volume)
    } else {
        false
    }
}

// misc

#[frb(type_64bit_int)]
pub fn get_sample_rate() -> usize {
    let sample_rate = OUTPUT_SAMPLE_RATE.lock();
    match sample_rate {
        Ok(sample_rate) => *sample_rate,
        Err(_) => 44100,
    }
}

pub fn debug_test_function() -> bool {
    log::info!("debug test function");
    true
}
