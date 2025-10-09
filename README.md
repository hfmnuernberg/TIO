# TIO Music

[![image](https://www.hfm-nuernberg.de/fileadmin/_processed_/2/1/csm_RELEVEL_TIO_Music_App_3125e78a17.webp)](https://www.hfm-nuernberg.de/forschung-innovation/relevel/tio-music)

<h2 style='display: flex; justify-content: end; align-items: center; margin: 0'>
  by
  &nbsp;
  <a href="https://www.hfm-nuernberg.de/">
    <img
        src="https://www.hfm-nuernberg.de/typo3conf/ext/threeme/Resources/Public/Images/Logo/HFM-Logo.svg"
        alt="Hochschule für Musik Nürnberg"
        height="40px" />
  </a>
</h2>

<h3 style='display: flex; justify-content: end; align-items: center; margin: 12px 0;'>
  developed by
  &nbsp; 
  <a href="https://cultivate.software" style='display: flex; align-items: center;'>
    <img
        src="https://cultivate.software/wp-content/uploads/2022/11/icon-primary-transparent_500.png" 
        alt="cultivate GmbH"
        height="24px"
    />
    &nbsp;
    cultivate(software)
  </a>
</h3>

<h3 style='display: flex; justify-content: end; align-items: center; margin: 12px 0 48px;'>
  and
  &nbsp;
  <a href="https://studiofluffy.de/" style='display: flex; align-items: center;'>
    <img
        src="https://i0.wp.com/studiofluffy.de/wp-content/uploads/2022/11/fluffy-logo-o.png?fit=200%2C200&ssl=1" 
        alt="Studio Fluffy"
        height="24px"
    />
    &nbsp;
    Studio Fluffy
  </a>
</h3>

This repo contains all the source code for the App **TIO Music**.

**TIO Music** is a notebook for musicians, designed by musicians. It offers a collection of tools for taking musical notes.

For more information on this project check out the (german) [Homepage](https://www.hfm-nuernberg.de/forschung-innovation/relevel/tio-music).

<br/>

[<img src="https://github.com/user-attachments/assets/d36e9c5a-84cf-4e23-a5b0-a30f45bf6a06" alt="play store" height="58px"/>](https://play.google.com/store/apps/details?id=com.studiofluffy.tonica)
[<img src="https://github.com/user-attachments/assets/5be14e4f-078e-4ea4-b560-56b3be98d72f" alt="app store" height="58px"/>](https://apps.apple.com/us/app/tio-music/id6477820301?ign-itscg=30200&ign-itsct=apps_box_link)

## Table of Contents

- [Setup](docs/setup.md)
- [App Script – a helper script for regularly used commands](docs/app-script.md)
- [Upgrade Flutter & Dart](docs/upgrade-flutter-dart.md)
- [Upgrade Fastlane](docs/upgrade-fastlane.md)
- [Upgrade iOS and Android SDKs](docs/upgrade-ios-android-sdks.md)
- Upgrade Rust
  - [Upgrade Rust](docs/update-rust.md)
  - [Update cargo dependencies for Rust code](docs/update-rust-dependencies.md)
  - [Update flutter-rust-bridge](docs/update-flutter-rust-bridge.md)
- [Publish apps to app store](docs/publish-apps-to-app-stores.md)
- [Unpublish apps from app stores](docs/unpublish-apps-from-app-stores.md)
- [Troubleshooting](docs/troubleshooting.md)
- [SoundFont Files (.sf2)](docs/soundfont.md)
- [How does it work?](#how-does-it-work)
- [Development](#development)
- [Build for iOS](#build-for-ios)
- [Build for Android](#build-for-android)
- [Dependabot](docs/dependabot.md)

## How does it work?

**TIO** is a [Flutter](https://flutter.dev/) cross-platform app with Android and iOS as target platforms.

Under the hood, it is powered by a [Rust](https://www.rust-lang.org/) library handling the signal processing tasks for
real time pitch shifting, pitch detection, time stretching and more.

If you are interested in giving feedback or contributing to **TIO**, please leave an issue or open a PR, or head over
to [the survey (german)](https://cloud9.evasys.de/hfmn/online.php?p=Q2TYV).

## Development

This project has an [app script](scripts/app.sh) that can be used for daily tasks, e.g. starting the app, running tests,
linting, format code, (re-)generating code, etc.
To get an overview about available commands run `app help` in the apps root directory.

## Build for iOS

To build the iOS app, check the build command in the [app script](scripts/app.sh) and the [iOS build pipeline](.github/workflows/reusable-build-ios-app.yaml)
to get an idea what parameters and variables need to be used and set first.

From root directory, run:

```shell
app build ios
``` 


## Build for Android

To build the Android app, check the build command in the [app script](scripts/app.sh) and the [Android build pipeline](.github/workflows/reusable-build-android-app.yaml)
to get an idea what parameters and variables need to be used and set first.

From root directory, run:

```shell
app build android prd prd release
```
