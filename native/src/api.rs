/***
 * This file contains all functions that are exposed to Flutter.
 */

use crate::{
    audio::global::GLOBAL_AUDIO_LOCK,
    modules::{
        generator::{
            generator_create_audio_stream, generator_start_note, generator_stop_current_note,
            generator_trigger_destroy_stream,
        },
        media_player::{
            media_player_compute_rms, media_player_create_stream, media_player_query_state,
            media_player_set_buffer, media_player_set_loop_value, media_player_set_new_volume,
            media_player_set_pitch, media_player_set_pos_factor, media_player_set_speed,
            media_player_set_trim_by_factor, media_player_trigger_destroy_stream, MediaPlayerState,
        },
        metronome::{
            metronome_create_audio_stream, metronome_get_beat_event, metronome_load_audio_buffer,
            metronome_set_audio_muted, metronome_set_new_bpm, metronome_set_new_mute_chance,
            metronome_set_new_volume, metronome_set_rhythm_from_bars,
            metronome_trigger_destroy_stream, BeatHappenedEvent,
        },
        metronome_rhythm::{BeatSound, MetroBar},
        piano::{
            piano_create_audio_stream, piano_load_and_setup, piano_set_amp,
            piano_trigger_destroy_stream, piano_trigger_note_off, piano_trigger_note_on,
        },
        recorder::{
            recorder_create_stream, recorder_get_buffer_samples, recorder_trigger_destroy_stream,
        },
        tuner::{
            tuner_compute_freq_from_ringbuffer, tuner_create_stream, tuner_trigger_destroy_stream,
        },
    },
    util::{
        constants::{INPUT_SAMPLE_RATE, OUTPUT_SAMPLE_RATE},
        debug_log::{debug_log, debug_log_string, dequeue_log_message},
        util_functions::{
            get_platform_default_input_sample_rate, get_platform_default_output_sample_rate,
            load_audio_file,
        },
    },
};

pub fn init() {
    debug_log("init");

    let fallback_sample_rate = if cfg!(target_os = "android") {
        44100
    } else {
        48000
    };

    let output_sample_rate = match get_platform_default_output_sample_rate() {
        Ok(sample_rate) => sample_rate as usize,
        Err(err) => {
            debug_log_string(format!(
                "Could not get platform default output sample rate, setting to fallback: {} - Error: {}",
                fallback_sample_rate, err
            ));
            fallback_sample_rate
        }
    };

    let input_sample_rate = match get_platform_default_input_sample_rate() {
        Ok(sample_rate) => sample_rate as usize,
        Err(err) => {
            debug_log_string(format!(
                "Could not get platform default input sample rate, setting to fallback: {} - Error: {}",
                fallback_sample_rate, err
            ));
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

pub fn poll_debug_log_message() -> Option<String> {
    dequeue_log_message()
}

// tuner

pub fn tuner_get_frequency() -> Option<f32> {
    debug_log("tuner get frequency");
    let guard = GLOBAL_AUDIO_LOCK.try_lock();
    match guard {
        Ok(_guard) => tuner_compute_freq_from_ringbuffer(),
        Err(_) => None,
    }
}

pub fn tuner_start() -> bool {
    debug_log("tuner start");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    tuner_create_stream()
}

pub fn tuner_stop() -> bool {
    debug_log("tuner stop");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    tuner_trigger_destroy_stream()
}

// generator

pub fn generator_start() -> bool {
    debug_log("generator start");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    generator_create_audio_stream()
}

pub fn generator_stop() -> bool {
    debug_log("generator stop");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    generator_trigger_destroy_stream()
}

pub fn generator_note_on(new_freq: f32) -> bool {
    debug_log("generator note on");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    generator_start_note(new_freq)
}

pub fn generator_note_off() -> bool {
    debug_log("generator note off");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    generator_stop_current_note()
}

// media player

pub fn media_player_load_wav(wav_file_path: String) -> bool {
    debug_log(&format!("media player load wav: {}", wav_file_path));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    match load_audio_file(wav_file_path) {
        Ok(buffer) => {
            media_player_set_buffer(buffer);
            debug_log("media player load wav done");
            true
        }
        Err(e) => {
            debug_log(format!("media player load wav failed: {}", e).as_str());
            false
        }
    }
}

pub fn media_player_start() -> bool {
    debug_log("media player play start");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_create_stream()
}

pub fn media_player_stop() -> bool {
    debug_log("media player play stop");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_trigger_destroy_stream()
}

pub fn media_player_start_recording() -> bool {
    debug_log("media player recording start");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    recorder_create_stream()
}

pub fn media_player_stop_recording() -> bool {
    debug_log("media player recording stop");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    recorder_trigger_destroy_stream()
}

pub fn media_player_get_recording_samples() -> Vec<f64> {
    debug_log("media player get recording samples");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    recorder_get_buffer_samples()
}

pub fn media_player_set_pitch_semitones(pitch_semitones: f32) -> bool {
    debug_log(&format!(
        "media player set pitch semitones: {}",
        pitch_semitones
    ));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_set_pitch(pitch_semitones)
}

pub fn media_player_set_speed_factor(speed_factor: f32) -> bool {
    debug_log(&format!("media player set speed factor: {}", speed_factor));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_set_speed(speed_factor)
}

pub fn media_player_set_trim(start_factor: f32, end_factor: f32) {
    debug_log(&format!(
        "media player set trim: start: {}, end: {}",
        start_factor, end_factor
    ));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_set_trim_by_factor(start_factor, end_factor)
}

pub fn media_player_get_rms(n_bins: usize) -> Vec<f32> {
    debug_log(&format!("media player get rms: n_bins: {}", n_bins));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_compute_rms(n_bins)
}

pub fn media_player_set_loop(looping: bool) {
    debug_log(&format!("media player set loop: {}", looping));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_set_loop_value(looping)
}

pub fn media_player_get_state() -> Option<MediaPlayerState> {
    debug_log("media player get state");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_query_state()
}

pub fn media_player_set_playback_pos_factor(pos_factor: f32) -> bool {
    debug_log(&format!("media player set pos factor: {}", pos_factor));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_set_pos_factor(pos_factor)
}

pub fn media_player_set_volume(volume: f32) -> bool {
    debug_log(&format!("media player set volume: {}", volume));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    media_player_set_new_volume(volume)
}

// metronome

pub fn metronome_start() -> bool {
    debug_log("metronome start");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    metronome_create_audio_stream()
}

pub fn metronome_stop() -> bool {
    debug_log("metronome stop");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    metronome_trigger_destroy_stream()
}

pub fn metronome_set_bpm(bpm: f32) -> bool {
    debug_log(&format!("metronome set bpm: {}", bpm));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    metronome_set_new_bpm(bpm)
}

pub fn metronome_load_file(beat_type: BeatSound, wav_file_path: String) -> bool {
    debug_log(&format!("metronome load file: {}", wav_file_path));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    match load_audio_file(wav_file_path) {
        Ok(buffer) => {
            metronome_load_audio_buffer(beat_type, buffer);
            true
        }
        Err(e) => {
            debug_log(format!("metronome load file failed: {}", e).as_str());
            false
        }
    }
}

pub fn metronome_set_rhythm(bars: Vec<MetroBar>, bars_2: Vec<MetroBar>) -> bool {
    debug_log("metronome set rhythm");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    metronome_set_rhythm_from_bars(bars, bars_2)
}

pub fn metronome_poll_beat_event_happened() -> Option<BeatHappenedEvent> {
    debug_log("metronome poll beat event happened");
    let guard = GLOBAL_AUDIO_LOCK.try_lock();
    match guard {
        Ok(_guard) => metronome_get_beat_event(),
        Err(_) => None,
    }
}

pub fn metronome_set_muted(muted: bool) -> bool {
    debug_log(&format!("metronome set muted: {}", muted));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    metronome_set_audio_muted(muted)
}

pub fn metronome_set_beat_mute_chance(mute_chance: f32 /*[0.0, 1.0]*/) -> bool {
    debug_log(&format!("metronome set beat mute chance: {}", mute_chance));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    metronome_set_new_mute_chance(mute_chance)
}

pub fn metronome_set_volume(volume: f32) -> bool {
    debug_log(&format!("metronome set volume: {}", volume));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    metronome_set_new_volume(volume)
}

// piano

pub fn piano_setup(sound_font_path: String) -> bool {
    debug_log(&format!("piano setup: {}", sound_font_path));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    piano_load_and_setup(&sound_font_path)
}

pub fn piano_start() -> bool {
    debug_log("piano start");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    piano_create_audio_stream()
}

pub fn piano_stop() -> bool {
    debug_log("piano stop");
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    piano_trigger_destroy_stream()
}

pub fn piano_note_on(note: i32) -> bool {
    let success = piano_trigger_note_on(note);
    debug_log(&format!("piano note on: {}", note));
    success
}

pub fn piano_note_off(note: i32) -> bool {
    let success = piano_trigger_note_off(note);
    debug_log(&format!("piano note off: {}", note));
    success
}

pub fn piano_set_volume(volume: f32) -> bool {
    debug_log(&format!("piano set volume: {}", volume));
    let _guard = GLOBAL_AUDIO_LOCK
        .lock()
        .expect("Could not lock global audio lock");
    piano_set_amp(volume)
}

// misc

pub fn get_sample_rate() -> usize {
    *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock OUTPUT_SAMPLE_RATE")
}

pub fn debug_test_function() -> bool {
    debug_log("debug test function");
    true
}
