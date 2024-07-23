use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_init(port_: i64) {
    wire_init_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_poll_debug_log_message(port_: i64) {
    wire_poll_debug_log_message_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_tuner_get_frequency(port_: i64) {
    wire_tuner_get_frequency_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_tuner_start(port_: i64) {
    wire_tuner_start_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_tuner_stop(port_: i64) {
    wire_tuner_stop_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_generator_start(port_: i64) {
    wire_generator_start_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_generator_stop(port_: i64) {
    wire_generator_stop_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_generator_note_on(port_: i64, new_freq: f32) {
    wire_generator_note_on_impl(port_, new_freq)
}

#[no_mangle]
pub extern "C" fn wire_generator_note_off(port_: i64) {
    wire_generator_note_off_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_media_player_load_wav(port_: i64, wav_file_path: *mut wire_uint_8_list) {
    wire_media_player_load_wav_impl(port_, wav_file_path)
}

#[no_mangle]
pub extern "C" fn wire_media_player_start(port_: i64) {
    wire_media_player_start_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_media_player_stop(port_: i64) {
    wire_media_player_stop_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_media_player_start_recording(port_: i64) {
    wire_media_player_start_recording_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_media_player_stop_recording(port_: i64) {
    wire_media_player_stop_recording_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_media_player_get_recording_samples(port_: i64) {
    wire_media_player_get_recording_samples_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_media_player_set_pitch_semitones(port_: i64, pitch_semitones: f32) {
    wire_media_player_set_pitch_semitones_impl(port_, pitch_semitones)
}

#[no_mangle]
pub extern "C" fn wire_media_player_set_speed_factor(port_: i64, speed_factor: f32) {
    wire_media_player_set_speed_factor_impl(port_, speed_factor)
}

#[no_mangle]
pub extern "C" fn wire_media_player_set_trim(port_: i64, start_factor: f32, end_factor: f32) {
    wire_media_player_set_trim_impl(port_, start_factor, end_factor)
}

#[no_mangle]
pub extern "C" fn wire_media_player_get_rms(port_: i64, n_bins: usize) {
    wire_media_player_get_rms_impl(port_, n_bins)
}

#[no_mangle]
pub extern "C" fn wire_media_player_set_loop(port_: i64, looping: bool) {
    wire_media_player_set_loop_impl(port_, looping)
}

#[no_mangle]
pub extern "C" fn wire_media_player_get_state(port_: i64) {
    wire_media_player_get_state_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_media_player_set_playback_pos_factor(port_: i64, pos_factor: f32) {
    wire_media_player_set_playback_pos_factor_impl(port_, pos_factor)
}

#[no_mangle]
pub extern "C" fn wire_media_player_set_volume(port_: i64, volume: f32) {
    wire_media_player_set_volume_impl(port_, volume)
}

#[no_mangle]
pub extern "C" fn wire_metronome_start(port_: i64) {
    wire_metronome_start_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_metronome_stop(port_: i64) {
    wire_metronome_stop_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_metronome_set_bpm(port_: i64, bpm: f32) {
    wire_metronome_set_bpm_impl(port_, bpm)
}

#[no_mangle]
pub extern "C" fn wire_metronome_load_file(
    port_: i64,
    beat_type: i32,
    wav_file_path: *mut wire_uint_8_list,
) {
    wire_metronome_load_file_impl(port_, beat_type, wav_file_path)
}

#[no_mangle]
pub extern "C" fn wire_metronome_set_rhythm(
    port_: i64,
    bars: *mut wire_list_metro_bar,
    bars_2: *mut wire_list_metro_bar,
) {
    wire_metronome_set_rhythm_impl(port_, bars, bars_2)
}

#[no_mangle]
pub extern "C" fn wire_metronome_poll_beat_event_happened(port_: i64) {
    wire_metronome_poll_beat_event_happened_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_metronome_set_muted(port_: i64, muted: bool) {
    wire_metronome_set_muted_impl(port_, muted)
}

#[no_mangle]
pub extern "C" fn wire_metronome_set_beat_mute_chance(port_: i64, mute_chance: f32) {
    wire_metronome_set_beat_mute_chance_impl(port_, mute_chance)
}

#[no_mangle]
pub extern "C" fn wire_metronome_set_volume(port_: i64, volume: f32) {
    wire_metronome_set_volume_impl(port_, volume)
}

#[no_mangle]
pub extern "C" fn wire_piano_setup(port_: i64, sound_font_path: *mut wire_uint_8_list) {
    wire_piano_setup_impl(port_, sound_font_path)
}

#[no_mangle]
pub extern "C" fn wire_piano_start(port_: i64) {
    wire_piano_start_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_piano_stop(port_: i64) {
    wire_piano_stop_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_piano_note_on(port_: i64, note: i32) {
    wire_piano_note_on_impl(port_, note)
}

#[no_mangle]
pub extern "C" fn wire_piano_note_off(port_: i64, note: i32) {
    wire_piano_note_off_impl(port_, note)
}

#[no_mangle]
pub extern "C" fn wire_piano_set_volume(port_: i64, volume: f32) {
    wire_piano_set_volume_impl(port_, volume)
}

#[no_mangle]
pub extern "C" fn wire_get_sample_rate(port_: i64) {
    wire_get_sample_rate_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_debug_test_function(port_: i64) {
    wire_debug_test_function_impl(port_)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_list_beat_type_0(len: i32) -> *mut wire_list_beat_type {
    let wrap = wire_list_beat_type {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_list_beat_type_poly_0(len: i32) -> *mut wire_list_beat_type_poly {
    let wrap = wire_list_beat_type_poly {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_list_metro_bar_0(len: i32) -> *mut wire_list_metro_bar {
    let wrap = wire_list_metro_bar {
        ptr: support::new_leak_vec_ptr(<wire_MetroBar>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<Vec<BeatType>> for *mut wire_list_beat_type {
    fn wire2api(self) -> Vec<BeatType> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<Vec<BeatTypePoly>> for *mut wire_list_beat_type_poly {
    fn wire2api(self) -> Vec<BeatTypePoly> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<Vec<MetroBar>> for *mut wire_list_metro_bar {
    fn wire2api(self) -> Vec<MetroBar> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<MetroBar> for wire_MetroBar {
    fn wire2api(self) -> MetroBar {
        MetroBar {
            id: self.id.wire2api(),
            beats: self.beats.wire2api(),
            poly_beats: self.poly_beats.wire2api(),
            beat_len: self.beat_len.wire2api(),
        }
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}

// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_beat_type {
    ptr: *mut i32,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_beat_type_poly {
    ptr: *mut i32,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_metro_bar {
    ptr: *mut wire_MetroBar,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_MetroBar {
    id: i32,
    beats: *mut wire_list_beat_type,
    poly_beats: *mut wire_list_beat_type_poly,
    beat_len: f32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_MetroBar {
    fn new_with_null_ptr() -> Self {
        Self {
            id: Default::default(),
            beats: core::ptr::null_mut(),
            poly_beats: core::ptr::null_mut(),
            beat_len: Default::default(),
        }
    }
}

impl Default for wire_MetroBar {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
