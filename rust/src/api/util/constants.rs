// audio general

use std::sync::Mutex;

pub const NUM_CHANNELS: usize = 1;

pub const AUDIO_STREAM_CREATE_TIMEOUT_SECONDS: u64 = 10;

pub static OUTPUT_SAMPLE_RATE: Mutex<usize> = Mutex::new(44100);
pub static INPUT_SAMPLE_RATE: Mutex<usize> = Mutex::new(44100);

// media player

pub const PITCH_SHIFT_BUFFER_SIZE: usize = 64;
pub const MEDIA_PLAYER_PLAYBACK_MAX_BUFFERING: usize = 2048 * 2 + PITCH_SHIFT_BUFFER_SIZE;
pub const MEDIA_PLAYER_PLAYBACK_MIN_BUFFERING: usize = 1024;
pub const PITCH_SHIFT_OVERSAMPLING: usize = 4;
pub const PITCH_SHIFT_WINDOW_DUR_MILLIS: usize = 70;

// tuner

pub const TUNER_RING_BUFFER_SIZE: usize = 2048;

pub const POWER_THRESHOLD: f32 = 0.055;
pub const CLARITY_THRESHOLD: f32 = 0.7;
