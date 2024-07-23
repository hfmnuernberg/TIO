#[allow(unused)]
use crate::util::util_functions::load_audio_file;
#[allow(unused)]
use std::path::PathBuf;
#[allow(unused)]
use std::time::Instant;

#[test]
fn load_wav_441() -> Result<(), anyhow::Error> {
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("sweep_1s_441.wav");

    let file_path = resource
        .to_str()
        .expect("Could not convert path to string")
        .to_owned();

    let start = Instant::now();
    let mixed_down_buffer = load_audio_file(file_path)?;
    let duration = start.elapsed();

    println!("load_audio_file took: {:?}", duration);
    assert_eq!(mixed_down_buffer.len(), 44100, "buffer length is not 44100");

    Ok(())
}

#[test]
fn load_mp3() -> Result<(), anyhow::Error> {
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("sweep_1s_441.wav.mp3");

    let file_path = resource
        .to_str()
        .expect("Could not convert path to string")
        .to_owned();

    let start = Instant::now();
    let mixed_down_buffer_441 = load_audio_file(file_path)?;
    let duration = start.elapsed();

    println!("load_audio_file took: {:?}", duration);

    assert!(!mixed_down_buffer_441.is_empty());
    Ok(())
}

#[test]
fn load_mp3_long() -> Result<(), anyhow::Error> {
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("long.mp3");

    let file_path = resource
        .to_str()
        .expect("Could not convert path to string")
        .to_owned();

    let start = Instant::now();
    let mixed_down_buffer = load_audio_file(file_path)?;
    let duration = start.elapsed();

    println!("load_audio_file took: {:?}", duration);

    assert!(mixed_down_buffer.len() > 44100 * 15);
    assert!(mixed_down_buffer.len() < 44100 * 16);

    Ok(())
}

#[test]
fn load_wav_48() -> Result<(), anyhow::Error> {
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("sweep_1s_48.wav");

    let file_path = resource
        .to_str()
        .expect("Could not convert path to string")
        .to_owned();
    let mixed_down_buffer = load_audio_file(file_path)?;

    assert!((mixed_down_buffer.len() as i32 - 44100_i32).abs() < 10);

    Ok(())
}

#[test]
fn load_wav_stereo_441() -> Result<(), anyhow::Error> {
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("sweep_stereo_1s_441.wav");

    let file_path = resource
        .to_str()
        .expect("Could not convert path to string")
        .to_owned();
    let mixed_down_buffer = load_audio_file(file_path)?;

    assert_eq!(mixed_down_buffer.len(), 44100);

    Ok(())
}

#[test]
fn load_wav_compare_stereo() -> Result<(), anyhow::Error> {
    // mono
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("sweep_1s_441.wav");

    let file_path = resource
        .to_str()
        .expect("Could not convert path to string")
        .to_owned();
    let mixed_down_buffer_mono = load_audio_file(file_path)?;

    assert_eq!(mixed_down_buffer_mono.len(), 44100);

    // stereo
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("sweep_stereo_1s_441.wav");

    let file_path = resource
        .to_str()
        .expect("Could not convert path to string")
        .to_owned();
    let mixed_down_buffer_stereo = load_audio_file(file_path)?;

    assert_eq!(mixed_down_buffer_stereo.len(), 44100);
    assert_eq!(mixed_down_buffer_stereo.len(), mixed_down_buffer_mono.len());

    // make sure mono and stereo are the same
    for (mono, stereo) in mixed_down_buffer_mono
        .iter()
        .zip(mixed_down_buffer_stereo.iter())
    {
        assert!((mono - stereo).abs() < 0.001);
    }

    Ok(())
}

#[test]
fn load_wav_compare_bit_formats() -> Result<(), anyhow::Error> {
    // signed 16bit
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("sweep_1s_48.wav");
    let buffer_i16 = load_audio_file(
        resource
            .to_str()
            .expect("Could not convert path to string")
            .to_owned(),
    )?;

    // signed 24 bit
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("sweep_1s_48_signed24bit.wav");
    let buffer_i24 = load_audio_file(
        resource
            .to_str()
            .expect("Could not convert path to string")
            .to_owned(),
    )?;

    // 32 bit float
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources");
    resource.push("sweep_1s_48_f32.wav");
    let buffer_f32 = load_audio_file(
        resource
            .to_str()
            .expect("Could not convert path to string")
            .to_owned(),
    )?;

    assert_eq!(buffer_i16.len(), buffer_i24.len());
    assert_eq!(buffer_i16.len(), buffer_f32.len());

    // make sure mono and stereo are the same
    for ((s_i16, s_i24), s_f32) in buffer_i16
        .iter()
        .zip(buffer_i24.iter())
        .zip(buffer_f32.iter())
    {
        assert!((s_i16 - s_i24).abs() < 0.001);
        assert!((s_i16 - s_f32).abs() < 0.001);
    }

    Ok(())
}

#[test]
fn load_formats() -> Result<(), anyhow::Error> {
    let mut resource = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    resource.push("src/test/resources/formats");

    // iterate all files in dir
    for entry in std::fs::read_dir(resource)? {
        let entry = entry?;
        let path = entry.path();
        let file_path = path
            .to_str()
            .expect("Could not convert path to string")
            .to_owned();
        if path.is_dir() {
            continue;
        }
        if path
            .file_name()
            .expect("Could not get file name")
            .to_str()
            .expect("Could not convert file name to string")
            .starts_with(".")
        {
            continue;
        }

        println!("loading: {}", file_path);

        let mixed_down_buffer = load_audio_file(file_path)?;

        assert!(!mixed_down_buffer.is_empty());
    }

    Ok(())
}
