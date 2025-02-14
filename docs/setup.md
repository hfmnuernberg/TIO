# Setup

## Table of Contents

1. [Flutter Version Management (FVM)](#flutter-version-management--fvm-)
2. [Xcode](#xcode)
3. [Command Line Tools for Xcode](#command-line-tools-for-xcode)
4. [CocoaPods](#cocoapods)
5. [Android Studio](#android-studio)
6. [Android NDK](#android-ndk)
7. [Rust](#rust) 
8. [App Script](#android-ndk)
9. [Exclude folders](#exclude-folders)

## [Flutter Version Management (FVM)](https://fvm.app/)

Using `fvm`, install and activate the desired Flutter version
 
```shell
fvm install
```

```shell
fvm use
```

_Note: Automatically uses the version in this repository's `.fvmrc` file._

_Note: The VSCode fvm settings are checking in. Therefore, they don't need to be adjusted any further._
 
_Note: From now on `fvm flutter doctor` will suggest what to do next to get started, but the following steps outline what to do._

## [Xcode](https://developer.apple.com/xcode/)

Follow the [Install Instructions](https://developer.apple.com/documentation/safari-developer-tools/installing-xcode-and-simulators).

## Command Line Tools for Xcode

```shell
xcode-select --install
```

## [CocoaPods](https://guides.cocoapods.org/using/getting-started.html)

Install CocoaPods – e.g., with [Brew](https://formulae.brew.sh/formula/cocoapods):

```shell
brew install cocoapods
```

or

```shell
sudo gem install cocoapods
```

## Android Studio

Follow the [Android Studio](https://developer.android.com/studio/) instructions.

## Android NDK

### With Android Studio

1. go to the IDE settings and search for `Android SDK`
2. go to the SDK tools tab and activate or deactivate the NDK that is references in the gradle files
3. besides the NDK also activate the `CMake` SDK tool

### Directly

1. Download the [Android NDK](https://developer.android.com/ndk/downloads/).
2. In your e.g. `.zshrc` file set the environment variable `ANDROID_NDK_HOME` to the ndk installation folder.

   _Note: If this doesn't work (running flutter app fails because of NDK error), try to install the Android NDK via Android Studio._

3. Add the following line to the end of your shell initialization script (e.g., `.zshrc`):

   ```
   # ...
  
   export ANDROID_NDK_HOME=/path/to/the/android/ndk
   ```

4. Save the file and open a new terminal.

   _Note: The path `echo $PATH` should now look something like: `export ANDROID_NDK_HOME=/Users/<your username>/Library/Android/sdk/ndk/28.0.12916984`._

## Rust

1. Install [Rust](https://www.rust-lang.org/tools/install) (Note: As of 28/01/2025 installing Rust using brew does not work!)
2. Verify installation with `cargo -V`. Your output should look something like:

   ```
   cargo 1.81.0 (2dbb1af80 2024-08-20)
   ```

3. Add rust targets for cross compilation:

   ```
   rustup target add \
     aarch64-apple-ios \
     aarch64-apple-ios-sim \
     aarch64-linux-android \
     armv7-linux-androideabi \
     i686-linux-android \
     x86_64-apple-ios \
     x86_64-linux-android
   ```

4. Install rust binaries using `cargo install flutter_rust_bridge_codegen cargo-ndk`
5. [flutter_rust_bridge_codegen](https://crates.io/crates/flutter_rust_bridge_codegen/1.69.0)
6. [cargo-ndk](https://crates.io/crates/cargo-ndk/3.0.0)
7. Build the Rust library:

   ```
   cd rust
   cargo build
   cd ..
   ```

## App Script

We recommended installing the [App Script](app-script.md) – a helper script for regularly used commands.

## Exclude folders

If not done automatically, manually exclude the following folders from the project in your IDE settings (as they slow down searching the project):

- `.dart_tool`
- `.fvm`
- `build`
- `android/.gradle`
- `ios/.symlink`
- `ios/Pods`
