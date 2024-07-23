use std::sync::Mutex;

pub static GLOBAL_AUDIO_LOCK: Mutex<()> = Mutex::new(());
