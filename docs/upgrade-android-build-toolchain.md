# Upgrade the Android build toolchain

This covers Gradle, the Android Gradle Plugin (AGP) and the Kotlin Gradle Plugin (KGP). For the SDK
levels (`compileSdk`, `targetSdk`, `minSdk`) see [Upgrade iOS & Android SDKs](upgrade-ios-android-sdks.md).

## Where the versions live

| Version | File |
|---------|------|
| Gradle | [gradle-wrapper.properties](../android/gradle/wrapper/gradle-wrapper.properties) |
| AGP | [settings.gradle](../android/settings.gradle) |
| KGP | [settings.gradle](../android/settings.gradle) |
| AGP + KGP of the Rust plugin | [rust_builder/android/build.gradle](../rust_builder/android/build.gradle) |
| NDK | [android/app/build.gradle](../android/app/build.gradle) and the `setup-ndk` step in [the Android build job](../.github/workflows/reusable-build-android-app.yaml) |

Keep the Rust plugin's versions in sync with the app's, and keep the NDK version in the workflow in
sync with `ndkVersion`. The NDK release names map to package revisions, e.g. `r28c` is
`28.2.13676358`.

## Which versions Flutter supports

Flutter fails the build below its "error" version and prints a warning below its "warn" version. The
thresholds are defined in `DependencyVersionChecker.kt` inside the Flutter SDK:

```shell
sed -n '/support policy for Gradle/,/warnMinSdkVersion/p' \
  "$(dirname "$(readlink -f "$(command -v flutter)")")/../packages/flutter_tools/gradle/src/main/kotlin/DependencyVersionChecker.kt"
```

For Flutter 3.44 the warn thresholds are Gradle 8.14.0, AGP 8.11.1, KGP 2.2.20 and Java 17.

## AGP 9 is blocked until Flutter 3.47

Do not upgrade to AGP 9 yet. It fails on Flutter 3.44 for two independent reasons:

1. **Flutter applies the Kotlin plugin itself.** `FlutterPluginUtils.kt` calls
   `pluginManager.apply("kotlin-android")` for plugin subprojects. AGP 9 rejects this with
   *"The 'org.jetbrains.kotlin.android' plugin is no longer required for Kotlin support since AGP 9.0"*.
   Removing the plugin from our own `build.gradle` does not help, because Flutter re-applies it.
2. **Flutter's Gradle plugin still uses the old AGP DSL.** AGP 9 only reads the new DSL, so applying
   `dev.flutter.flutter-gradle-plugin` fails with a `NullPointerException` unless
   `android.newDsl=false` is set.

Flutter recognises both situations and its own advice is to update Flutter. Enabling
`android.builtInKotlin=true`, which the
[migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)
requires, needs **Flutter 3.47 or later**.

### When Flutter 3.47 is available

1. Upgrade Flutter first, see [Upgrade Flutter & Dart](upgrade-flutter-dart.md)
2. Add to [android/gradle.properties](../android/gradle.properties):
   ```properties
   android.builtInKotlin=true
   ```
3. Remove the `org.jetbrains.kotlin.android` plugin from [settings.gradle](../android/settings.gradle)
   and the `kotlin-android` plugin from [android/app/build.gradle](../android/app/build.gradle)
4. Replace the `kotlinOptions` block in `android/app/build.gradle` with a top level `kotlin` block:
   ```groovy
   kotlin {
       compilerOptions {
           jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
       }
   }
   ```
5. Do the same for [rust_builder/android/build.gradle](../rust_builder/android/build.gradle)
6. Bump AGP and Gradle in the same change
7. Build the Android app and test it on a physical device. The pull request pipeline does not build
   the Android app, so a broken toolchain only shows up after merging to `main`.
