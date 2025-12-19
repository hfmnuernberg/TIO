use std::sync::Arc;

#[flutter_rust_bridge::frb(ignore)]
pub struct AudioBufferReader {
    buffer: Arc<Vec<f32>>,
    read_head: i32,

    looping: bool,
    pub is_done: bool,
}

impl AudioBufferReader {
    #[flutter_rust_bridge::frb(ignore)]
    pub fn new(buffer: Arc<Vec<f32>>, looping: bool, read_head: i32) -> Self {
        Self {
            buffer,
            read_head,
            looping,
            is_done: false,
        }
    }

    #[flutter_rust_bridge::frb(ignore)]
    pub fn add_samples_to_buffer(&mut self, buffer_to_write_to: &mut [f32], volume: f32) {
        if self.buffer.is_empty() || self.is_done {
            return;
        }

        if self.looping {
            for sample_to_write in buffer_to_write_to.iter_mut() {
                self.read_head = (self.read_head + 1) % (self.buffer.len() as i32);
                if self.read_head >= 0 {
                    *sample_to_write += self.buffer[self.read_head as usize] * volume;
                }
            }
        } else {
            for sample_to_write in buffer_to_write_to.iter_mut() {
                self.read_head += 1;
                if self.read_head >= 0 {
                    if self.read_head >= (self.buffer.len() as i32) {
                        self.is_done = true;
                        return;
                    }
                    *sample_to_write += self.buffer[self.read_head as usize] * volume;
                }
            }
        }
    }
}
