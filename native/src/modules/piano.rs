use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use lazy_static::__Deref;
use rustysynth::{SoundFont, Synthesizer, SynthesizerSettings};

use std::{
    fs::File,
    sync::{
        mpsc::{channel, Receiver, Sender},
        Arc, Mutex,
    },
    thread::{self, JoinHandle},
    time::Duration,
    vec,
};

use crate::{
    audio::global::GLOBAL_AUDIO_LOCK,
    util::{
        constants::{AUDIO_STREAM_CREATE_TIMEOUT_SECONDS, OUTPUT_SAMPLE_RATE},
        debug_log::debug_log,
        util_functions::get_platform_default_cpal_output_config,
    },
};

// DATA

lazy_static! {
    static ref THREAD: Mutex<Option<JoinHandle<()>>> = Mutex::new(None);
    static ref THREAD_SENDER: Mutex<Option<Sender<CommandPiano>>> = Mutex::new(None);
    static ref SYNTHESIZER: Mutex<Option<Synthesizer>> = Mutex::new(None);
}

static VOLUME: Mutex<f32> = Mutex::new(1.0);

// COMMANDS

enum CommandPiano {
    Stop,
}

// FUNCTIONS

pub fn piano_load_and_setup(sound_font_path: &str) -> bool {
    let mut sf2 = File::open(sound_font_path).expect("Could not open sound font file");
    let sound_font = Arc::new(SoundFont::new(&mut sf2).expect("Could not create SoundFont"));

    let sample_rate = *OUTPUT_SAMPLE_RATE
        .lock()
        .expect("Could not lock mutex to OUTPUT_SAMPLE_RATE");
    let settings = SynthesizerSettings::new(sample_rate as i32);

    *SYNTHESIZER
        .lock()
        .expect("Could not lock mutex to SYNTHESIZER") =
        Some(Synthesizer::new(&sound_font, &settings).expect("Could not create Synthesizer"));

    true
}

fn on_audio_callback(buffer_out: &mut [f32], _: &cpal::OutputCallbackInfo) {
    let amp = *VOLUME.lock().expect("Could not lock mutex to VOLUME");

    let samples_per_iteration = 16;
    let mut out_i = 0;

    loop {
        if out_i >= buffer_out.len() {
            break;
        }

        let out_i_end = (out_i + samples_per_iteration).min(buffer_out.len());

        let mut synth_option = SYNTHESIZER
            .lock()
            .expect("Could not lock mutex to SYNTHESIZER");
        match synth_option.as_mut() {
            Some(synth) => {
                let mut left = vec![0.0; out_i_end - out_i];
                let mut right = vec![0.0; left.len()];
                synth.render(&mut left, &mut right);
                // right channel is ignored
                for (i, sample) in left.iter().enumerate() {
                    buffer_out[i + out_i] = *sample * amp;
                }
            }
            None => {
                debug_log("Piano synth is None");
                buffer_out.iter_mut().for_each(|s| *s = 0.0); // set to zero if something goes wrong
                return;
            }
        }
        drop(synth_option);

        out_i += samples_per_iteration;
    }
}

pub fn piano_create_audio_stream() -> bool {
    piano_trigger_destroy_stream();

    let host = cpal::default_host();
    let device = host
        .default_output_device()
        .expect("no output device available");

    let config = get_platform_default_cpal_output_config(&device);
    if config.is_none() {
        debug_log("Could not start piano output stream - Could not get default output config");
        return false;
    }
    let config = config.expect("Could not get default stream output config");

    let (tx, rx): (Sender<CommandPiano>, Receiver<CommandPiano>) = channel();
    let join_handle = thread::spawn(move || {
        let stream_out = device
            .build_output_stream(
                &config,
                on_audio_callback,
                move |_| {
                    debug_log("something went wrong with the audio stream");
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

fn audio_out_thread_handle_command(command: CommandPiano) {
    match command {
        CommandPiano::Stop => {
            let _guard = GLOBAL_AUDIO_LOCK
                .lock()
                .expect("Could not lock global audio lock");
            *THREAD_SENDER.lock().expect("Could not lock mutex") = None;
            *THREAD.lock().expect("Could not lock mutex") = None;
        }
    }
}

pub fn piano_trigger_destroy_stream() -> bool {
    match THREAD_SENDER
        .lock()
        .expect("Could not lock mutex to THREAD_SENDER")
        .deref()
    {
        Some(thread_record_sender) => {
            thread_record_sender
                .send(CommandPiano::Stop)
                .expect("Could not send command");
        }
        None => {
            debug_log("Could not send command to stop piano audio stream");
        }
    }

    true
}

pub fn piano_trigger_note_on(note: i32) -> bool {
    let mut synth_option = SYNTHESIZER
        .lock()
        .expect("Could not lock mutex to SYNTHESIZER");

    match synth_option.as_mut() {
        Some(synth) => {
            synth.note_on(0, note, 100);
            true
        }
        None => {
            debug_log("Failed to trigger note on - Synth is None");
            false
        }
    }
}

pub fn piano_trigger_note_off(note: i32) -> bool {
    let mut synth_option = SYNTHESIZER
        .lock()
        .expect("Could not lock mutex to SYNTHESIZER");

    match synth_option.as_mut() {
        Some(synth) => {
            synth.note_off(0, note);
        }
        None => {
            debug_log("Failed to trigger note off - Synth is None");
            return false;
        }
    }

    true
}

pub fn piano_set_amp(amp: f32) -> bool {
    *VOLUME.lock().expect("Could not lock mutex to VOLUME") = amp;
    true
}
