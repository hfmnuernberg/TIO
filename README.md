[![image](https://github.com/user-attachments/assets/6b77eb21-df3c-4b65-923f-85df667dd619)](https://www.hfm-nuernberg.de/forschung-innovation/relevel/tio-music)

<a href="https://www.hfm-nuernberg.de/">
    <img align="right" src="https://github.com/user-attachments/assets/e132d231-fb98-4210-9041-23bfc35cf519" alt="HfMN"  height="45px" />
</a>

<br/>
<br/>

<a href="https://studiofluffy.de/">
    <img align="right" src="https://github.com/user-attachments/assets/a63c2f9a-6dc5-4b3a-b849-a95a47ffca27" alt="HfMN"  height="55px" />
</a>

<br/>

# TIO Music

This repo contains all the source code for the App **TIO Music**.<br/>
**TIO Music** is a notebook for musicians, designed by musicians. It offers a collection of tools for taking musical notes.

For more information on this project check out [the homepage (german)](https://www.hfm-nuernberg.de/forschung-innovation/relevel/tio-music).

<br/>

[<img src="https://github.com/user-attachments/assets/d36e9c5a-84cf-4e23-a5b0-a30f45bf6a06" alt="play store" height="58px"/>](https://play.google.com/store/apps/details?id=com.studiofluffy.tonica)
[<img src="https://github.com/user-attachments/assets/5be14e4f-078e-4ea4-b560-56b3be98d72f" alt="app store" height="58px"/>](https://apps.apple.com/us/app/tio-music/id6477820301?ign-itscg=30200&ign-itsct=apps_box_link)

<br/>

# How does it work?

**TIO** is a cross platform app written in Flutter. Under the hood, it is powered by a rust library handling the signal processing tasks for real time pitch shifting, pitch detection, time stretching and more.
If you are interested in giving feedback or contributing to **TIO**, please leave an issue or open a PR, or head over to [the survey (german)](https://cloud9.evasys.de/hfmn/online.php?p=Q2TYV).

# Installation

## Flutter

### FVM

Install the flutter version manager to easily switch between flutter versions in different projects.
If installed all flutter commands have to be prefixed with `fvm` (e.g. `fvm flutter doctor`).


1. Install [FVM](https://fvm.app/docs/getting_started/installation/)
   - From now on `fvm flutter doctor` will suggest what to do next to get started, but the following steps outline what to do next.
   - List all available flutter versions: `fvm list`
   - Install a specific flutter version: `fvm install 3.22.1` (if installed use version with `fvm use 3.22.1`)

### Without FVM

-   [Get Flutter.](https://docs.flutter.dev/get-started/install)
-   Call `flutter --version`. Your output should look like:

```
Flutter 3.22.1 • channel stable • https://github.com/flutter/flutter.git
Framework • revision a14f74ff3a (4 months ago) • 2024-05-22 11:08:21 -0500
Engine • revision 55eae6864b
Tools • Dart 3.4.1 • DevTools 2.34.3
```

-   Call `fvm flutter doctor` and resolve all errors. Your output should look like:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.22.1, on macOS 14.4.1 23E224 darwin-arm64, locale de-DE)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 15.4)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2024.1)
[✓] VS Code (version 1.93.1)
[✓] Connected device (5 available)
[✓] Network resources

• No issues found!
```

-   If the installation of cocoapods doesn't work, use the approach of [this website.](https://www.rubyonmac.dev/error-error-installing-cocoapods-error-failed-to-build-gem-native-extension)

### Install Flutter dependencies

```
fvm flutter pub get
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
cargo 1.81.0 (2dbb1af80 2024-08-20)
```

-   Add rust targets for cross compilation:

```
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android aarch64-apple-ios x86_64-apple-ios
```
_Note:_ If no version of rustup could be choosen, use `rustup default stable` to download the latest stable release of Rust and set it as your default toolchain.


-   Install rust binaries using `cargo install flutter_rust_bridge_codegen cargo-ndk`
    -   [flutter_rust_bridge_codegen](https://crates.io/crates/flutter_rust_bridge_codegen/1.69.0)
    -   [cargo-ndk](https://crates.io/crates/cargo-ndk/3.0.0)

    
-   `cd` into `rust` and try building the Rust library (optional).

```
cd rust
cargo build
cd ..
```

---

# Development

### Updating Rust Bridge

```
rustup upgrade
cargo install flutter_rust_bridge_codegen --version 2.4.0
```

in `/rust` (update der packages)

```
cargo update
```

Rust Bridge is responsible for generating the code that handles the FFI. All public rust functions inside `rust/src/api` are exposted to Flutter this way. If you have a public function, that should not be exposed, add `#[flutter_rust_bridge::frb(ignore)]` above the function. Any change of the rust functions in this folder requires a rebuild with the `flutter_rust_bridge_codegen` to be exposed to Flutter. This can most easily be done via:

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
fvm flutter pub run build_runner watch --delete-conflicting-outputs
```

---

# Build for iOS

-   make sure you installed all rust targets like described above
-   open the xcode workspace at `ios/Runner.xcworkspace`
    -   press `Cmd + comma` to open the settings
        -   go to accounts
        -   log into the necessary account for codesigning (check the certificates)
-   restart your mac - **don't skip, this is important**
-   run `fvm flutter build ipa`

# Build for Android

-   make sure you installed all rust targets like described above
-   generate or get your personal upload key ready (see https://developer.android.com/studio/publish/app-signing#generate-key)
    -   doing this you should get a `key.jks` file and a `key.properties` file. (If you choose other names for those files, adjust the names in `android/app/build.gradle`)
    -   put those two files in your android folder (Don't check them into source control!!!)
-   run `fvm flutter build appbundle`
