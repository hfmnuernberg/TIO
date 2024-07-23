use std::{ops::DerefMut, sync::Mutex};

use queues::{IsQueue, Queue};

lazy_static! {
    pub static ref DEBUG_MESSAGE: Mutex<Queue<String>> = Mutex::new(Queue::new());
}

#[allow(dead_code)]
pub fn debug_log(message: &str) {
    if cfg!(debug_assertions) {
        DEBUG_MESSAGE
            .lock()
            .expect("Could not lock mutex")
            .add(message.to_owned())
            .expect("Could not euqueue debug log message");
    }
}

// for using the debug_log method with type String instead of type &str
#[allow(dead_code)]
pub fn debug_log_string(message: String) {
    debug_log(&message[..]);
}

pub fn dequeue_log_message() -> Option<String> {
    if cfg!(debug_assertions) {
        match DEBUG_MESSAGE
            .lock()
            .expect("Could not lock mutex")
            .deref_mut()
            .remove()
        {
            Ok(message) => Some(message),
            Err(_) => None,
        }
    } else {
        None
    }
}
