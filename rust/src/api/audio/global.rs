use std::sync::Mutex;

#[flutter_rust_bridge::frb(ignore)]
pub static GLOBAL_AUDIO_LOCK: Mutex<()> = Mutex::new(());
