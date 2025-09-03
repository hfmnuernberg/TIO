# Upgrade Flutter & Dart

*Note: Dart SDK and Dart version refer to the same thing.*

The Flutter version that is installed and used by the Flutter Version Manager (fvm) also specifies which related Dart SDK is used.
Example: Flutter 3.22.0 uses Dart SDK/Dart Version 3.4.0.

Check what is the latest available fvm version ([available fvm versions](https://pub.dev/packages/fvm/versions)) and check if your installed fvm is up-to-date:

```shell
fvm --version
```

Check what is the latest available Flutter version ([available Flutter versions](https://docs.flutter.dev/install/archive)) and check which Flutter versions are already installed:

```shell
fvm list
```

For breaking changes and release notes see here: [Flutter Release Notes](https://docs.flutter.dev/release/release-notes).

If you want to install a new available Flutter version you need to change the Flutter version in the `.fvmrc` and the Flutter SDK version in the `pubspec.yaml` first.

Flutter SDK version in the `pubspec.yaml`:

```yaml
environment:
  sdk: X.X.X
```

Flutter version in the `.fvmrc`:

```yaml
"flutter": "X.X.X",
```

Switch to an already installed Flutter version or install a new Flutter version:

```shell
fvm use <version>
```

*Note: Do not use/install the `stable` channel using `fvm use stable`. The stable channel covers a range of multiple valid versions that can use different Dart SDK versions. Instead, install a specific version!*

If needed, accept pinning dependencies and/or update them in the `pubspec.yaml`.

Update the IDE path to the new Flutter SDK, e.g. `/Users/username/fvm/versions/3.X.X/bin/cache/dart-sdk`.

Start the app with iOS and Android simulator to check if everything is working as expected.

## Clean FVM cache and remove all Flutter versions

To clean the fvm cache and remove all installed Flutter versions, use the following command:

```shell
fvm destroy
```

_Note: After running this command, Install a new version (`fvm install {version}`) and manually switch
to the version (`fvm use {version}`) to complete the re-installation._
