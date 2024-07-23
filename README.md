[![image](https://github.com/user-attachments/assets/6b77eb21-df3c-4b65-923f-85df667dd619)](https://www.hfm-nuernberg.de/forschung-innovation/relevel/tio-music)


<a href="https://www.hfm-nuernberg.de/">
    <img align="right" src="https://github.com/user-attachments/assets/88d51e0f-4a03-40b7-8350-7b39c1581594" alt="HfMN"  height="40px" />
</a>

<br/>
<br/>

<a href="https://studiofluffy.de/">
    <img align="right" src="https://github.com/user-attachments/assets/7af2cc77-a3e5-4713-803d-c59cb218c602" alt="HfMN"  height="52px" />
</a>

<br/>

# TIO Music

This repo contains all the source code for the App **TIO Music**.<br/>
**TIO Music** is a notebook for musicians, designed by musicians. It offers a collection of tools for taking musical notes.

For more information on this project check out [the homepage (german)](https://www.hfm-nuernberg.de/forschung-innovation/relevel/tio-music).

<br/>

[<img src="https://github.com/user-attachments/assets/199e575f-cab1-419e-a414-a5316175f7c6" alt="play store" height="58px"/>](https://play.google.com/store/apps/details?id=com.studiofluffy.tonica)
[<img src="https://github.com/user-attachments/assets/e89574f4-32bb-451e-bacd-61f6ba1fbee1" alt="app store" height="58px"/>](https://apps.apple.com/us/app/tio-music/id6477820301?ign-itscg=30200&ign-itsct=apps_box_link)

<br/>

# How does it work?

**TIO** is an cross platform app written in Flutter. Under the hood, it is powered by a rust library handling the signal processing tasks for real time pitch shifting, pitch detection, time stretching and more.
If you are interested in giving feedback or contributing to **TIO**, please leave an issue or open a PR, or head over to [the survey (german)](https://cloud9.evasys.de/hfmn/online.php?p=Q2TYV).

# Installation

### Flutter

-   [Get Flutter.](https://docs.flutter.dev/get-started/install)
-   Call `flutter --version`. Your output should look like:

```
Flutter 3.7.3 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 9944297138 (5 weeks ago) • 2023-02-08 15:46:04 -0800
Engine • revision 248290d6d5
Tools • Dart 2.19.2 • DevTools 2.20.1
```

-   Call `flutter doctor` and resolve all errors. Your output should look like:

```
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, 3.7.3, on Microsoft Windows [Version 10.0.22621.1265], locale de-DE)
[√] Windows Version (Installed version of Windows is version 10 or higher)
[√] Android toolchain - develop for Android devices (Android SDK version 33.0.1)
[√] Chrome - develop for the web
[√] Visual Studio - develop for Windows (Visual Studio Community 2022 17.3.5)
[√] Android Studio (version 2022.1)
[√] VS Code (version 1.76.0)
[√] Connected device (4 available)
[√] HTTP Host Availability

• No issues found!
```

-   If the installation of cocoapods doesn't work, use the approach of [this website.](https://www.rubyonmac.dev/error-error-installing-cocoapods-error-failed-to-build-gem-native-extension)

### Install Flutter dependencies

```
flutter pub get
```

### Android Studio

-   Get [Android Studio](https://developer.android.com/studio/).

### Android NDK

-   Download the [Android NDK](https://developer.android.com/ndk/downloads/).
-   Set environment variable `ANDROID_NDK` to the ndk installation folder.
    -   **If this doesn't work (running flutter app fails because of NDK error), try to install the Android NDK via Android Studio.**

### On MacOS:

```
nano ~/.zshrc
```

Add the line to the bottom:

```
export ANDROID_NDK=/path/to/the/android/ndk
```

Press `Ctrl + X` → `Y` → `Enter`

### Rust

-   [Get Rust.](https://www.rust-lang.org/tools/install)
-   Call `cargo -V`. Your output should look like:

```
cargo 1.68.0 (115f34552 2023-02-26)
```

-   Add rust targets for cross compilation:

```
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android aarch64-apple-ios x86_64-apple-ios
```

-   Install rust binaries:
    -   [`flutter_rust_bridge_codegen`](https://crates.io/crates/flutter_rust_bridge_codegen/1.69.0):
    -   [`cargo-ndk`](https://crates.io/crates/cargo-ndk/3.0.0):

```
cargo install flutter_rust_bridge_codegen cargo-ndk
```

-   `cd` into `native` and try building the Rust library (optional).

```
cd native
cargo build
cd ..
```

----

# Development

### Updating Rust Bridge

```
rustup upgrade
cargo install flutter_rust_bridge_codegen --version 1.82.4
```

in `/native` (update der packages)

```
cargo update
```

Rust Bridge is responsible for generating the code that handles the FFI. All rust functions inside `api.rs` are exposted to Flutter this way. Any change in `api.rs` requires a rebuild with the `flutter_rust_bridge_codegen` to be exposed to Flutter. This can most easily be done via the scripts `generate-bridge.bat`/`generate-bridge.sh`.

```
python3 ./generate.py rust
```

### Auto Generated Files

Use the script `generate.py` to generate files for **rust**, app **splash** screen, app **icon** and **json** serialization - or simply use **all**.

It can be used like:

```python
python3 ./generate.py rust
python3 ./generate.py splash
python3 ./generate.py icon
python3 ./generate.py json
```

```python
python3 ./generate.py all
```

### Json Serialize/Deserialize

We are using the package [json_serializable](https://pub.dev/packages/json_serializable). The package generates the files automatically, which should be named exactly like the class file but using the extension **.g.dart**.

The generation can be done with `generate.py` or a **continuous runner**:

```
flutter pub run build_runner watch --delete-conflicting-outputs
```

----

# Build for iOS

-   make sure you installed all rust targets like described above
-   open the xcode workspace at `ios/Runner.xcworkspace`
    -   press `Cmd + comma` to open the settings
        -   go to accounts
        -   log into the necessary account for codesigning (check the certificates)
-   restart your mac - **don't skip, this is important**
-   run `flutter build ipa`
