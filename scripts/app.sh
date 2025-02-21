#!/bin/sh

set -e

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

fluttervm() { if command -v fvm >/dev/null 2>&1; then fvm flutter "$@"; else flutter "$@"; fi }
dartvm() { if command -v fvm >/dev/null 2>&1; then fvm dart "$@"; else dart "$@"; fi }

getTestCommand() {
  command="fluttervm test"

  if [ -n "$2" ]; then TEST_PATH="$2"; fi
  if [ "${TEST_PATH#test/}" = "$TEST_PATH" ]; then TEST_PATH="test/$TEST_PATH"; fi
  command="$command $TEST_PATH"

  if [ -n "$3" ]; then command="$command --plain-name '$3'"; fi

  echo "$command"
}

analyze() { fluttervm analyze --no-fatal-infos lib test; }
analyzeFiles() { scripts/analyze-files-with-too-many-lines.sh .; }
analyzeFix() { dartvm fix --apply --code="$2"; }
analyzeFixDryRun() { dartvm fix --dry-run; }
analyzeTodos() { scripts/analyze-todos-and-fixmes.sh .; }

build() {
  if [ "$2" = 'ios' ]; then PLATFORM='ios'; fi
  if [ "$2" = 'android' ]; then PLATFORM='android'; fi

  if [ -z "$PLATFORM" ]; then
    echo "Usage: $0 build <platform> [<mode>]"
    echo "platform  - ios, android"
    echo 'mode      - debug, profile, release'
    exit 1
  fi

  if [ -z "$3" ]; then MODE='debug'; else MODE="$3"; fi

  echo "Building app for platform: '$PLATFORM' with mode: '$MODE' ..."

  if [ "$PLATFORM" = 'ios' ]; then EXPORT_OPTIONS_ARG='--export-options-plist'; fi
  if [ "$PLATFORM" = 'ios' ]; then EXPORT_OPTIONS_VAL='ios/export-options.plist'; fi

  if [ "$PLATFORM" = 'ios' ]; then BUILD_COMMAND='ipa'; fi
  if [ "$PLATFORM" = 'android' ]; then BUILD_COMMAND='appbundle'; fi

  set -x
  fluttervm build "$BUILD_COMMAND" \
    --target lib/main.dart \
    "$EXPORT_OPTIONS_ARG" "$EXPORT_OPTIONS_VAL" \
    "--$MODE"
  set +x
}

clean() {
  fluttervm clean
  if [ -d "android/.gradle" ]; then rm -rf android/.gradle; fi
  if [ -d "android/vendor" ];  then rm -rf android/vendor;  fi
  if [ -d "coverage" ];        then rm -rf coverage;        fi
  if [ -d "ios/.symlinks" ];   then rm -rf ios/.symlinks;   fi
  if [ -d "ios/Pods" ];        then rm -rf ios/Pods;        fi
  if [ -d "ios/vendor" ];      then rm -rf ios/vendor;      fi
  if [ -d "rust/target" ];     then rm -rf rust/target;     fi
}

coverage() { coverageMeasure; coverageGenerate; coverageOpen; }
coverageGenerate() { genhtml --no-function-coverage coverage/lcov.info -o coverage/html; }
coverageMeasure() { fluttervm test --coverage test; }
coverageMeasureRandom() { fluttervm test --coverage --test-randomize-ordering-seed random test; }
coverageOpen() { open coverage/html/index.html; }
coveragePrint() { lcov --summary coverage/lcov.info; }
coverageValidate() {
  result=$(dartvm run test_cov_console --pass="$2")
  echo "$result"
  if echo "$result" | grep -q "PASSED"; then exit 0; else exit 1; fi
}

deleteLockFiles() {
  rm -f pubspec.lock
  rm -f ios/Podfile.lock
  rm -f rust/Cargo.lock
  rm -f rust_builder/cargokit/build_tool/pubspec.lock
}

doctor() { fluttervm doctor; }

format() { dartvm format --line-length=120 lib test; }

generate() { generateRust; generateSplash; generateIcon; generateJson; format; analyze; }
generateIcon() { fluttervm pub run flutter_launcher_icons -f flutter_launcher_icons.yaml; }
generateJson() { dartvm run build_runner build --delete-conflicting-outputs; }
generateRust() { flutter_rust_bridge_codegen generate --no-dart-enums-style; }
generateSplash() { fluttervm pub run flutter_native_splash:create --path=flutter_native_splash.yaml; }

install() {
  installFlutterPackages
  installCocoaPods
  installRustTargets
  installRustPackages
  installFlutterRustBridgeCodegen
  installFastlane
}
installCocoaPods() { fluttervm precache --ios; cd ios; pod install --repo-update; cd ..; }
installFastlane() { cd android; bundle install; cd ..; cd ios; bundle install; cd ..; }
installFlutterPackages() { fluttervm pub get; }
installFlutterRustBridgeCodegen() { cargo install flutter_rust_bridge_codegen --version 2.7.1; }
installRustPackages() {
  cd rust;
  cargo build;
  cd ..;
  rm -rf rust_builder/linux rust_builder/macos rust_builder/windows;
  }

installRustTargets() {
  rustup target add \
    aarch64-apple-ios \
    aarch64-apple-ios-sim \
    aarch64-linux-android \
    armv7-linux-androideabi \
    i686-linux-android \
    x86_64-apple-ios \
    x86_64-linux-android
}

outdated() { fluttervm pub outdated; }

reset() {
  doctor
  clean
  deleteLockFiles
  install
  outdated
  generate
  format
  analyze
  coverage
  run ios
}

run() {
  if [ "$2" = 'ios' ]; then PLATFORM='ios'; fi
  if [ "$2" = 'android' ]; then PLATFORM='android'; fi

  if [ -z "$PLATFORM" ]; then
    echo "Usage: $0 run <platform> [<mode>]"
    echo "platform  - ios, android"
    echo 'mode      - debug, profile, release'
    exit 1
  fi

  if [ -z "$5" ]; then MODE='debug'; else MODE="$5"; fi

  echo "Running app on platform: '$PLATFORM' with mode: '$MODE' ..."

  if [ "$PLATFORM" = 'ios' ]; then
    fluttervm run
  fi

  if [ "$PLATFORM" = 'android' ]; then
    fluttervm run
      "--$MODE"
  fi
}

simulator() { open -a Simulator; }

tests() { eval "$(getTestCommand "$@")"; }
testsRandom() { fluttervm test --test-randomize-ordering-seed random test; }
testsWatch() { command=$(getTestCommand "$@"); watchexec -e dart "$command"; }

upload() {
  if [ "$2" = 'ios' ]; then PLATFORM='ios'; fi
  if [ "$2" = 'android' ]; then PLATFORM='android'; fi

  if [ -z "$PLATFORM" ]; then
    echo "Usage: $0 upload <platform>"
    echo "platform  - ios, android"
    exit 1
  fi

  echo "Uploading '$PLATFORM' app..."

  cd "$PLATFORM"
  fastlane "$PLATFORM" push_to_store
  cd ..
}

help() {
  echo "Usage: $0 <command> [args]"
  echo
  echo 'Commands:'
  echo
  echo 'analyze                                       - run static code analysis (lint)'
  echo 'analyze:files                                 - analyze files with too many lines of code'
  echo 'analyze:fix <rule>                            - fix static code analysis rule violations'
  echo 'analyze:fix:dry                               - simulates fixing static code analysis rule violations'
  echo 'build <platform> [<mode>]                     - build app for ios or android'
  echo 'clean                                         - clean build'
  echo 'coverage                                      - measure and open test coverage report'
  echo 'coverage:generate                             - generate test coverage report from previous test run'
  echo 'coverage:measure                              - run all tests and measure test coverage'
  echo 'coverage:measure:random                       - run all tests in random order and measure test coverage'
  echo 'coverage:open                                 - open test coverage report from previous test run'
  echo 'coverage:print                                - print test coverage report from previous test run to console'
  echo 'coverage:validate <integer>                   - validates the total test coverage against the given threshold'
  echo 'delete:lock                                   - delete lock files'
  echo 'doctor                                        - run flutter doctor'
  echo 'format                                        - format code'
  echo 'generate                                      - update generated code'
  echo 'generate:icon                                 - update generated launcher icons'
  echo 'generate:json                                 - update generated json *.g.dart files'
  echo 'generate:rust                                 - update generated rust TIO music library'
  echo 'generate:splash                               - update generated splash image assets'
  echo 'help                                          - print this help'
  echo 'install                                       - install dependencies'
  echo 'install:cocoa:pods                            - install Cocoapods'
  echo 'install:fastlane                              - install Fastlane'
  echo 'install:flutter:packages                      - install Flutter packages'
  echo 'install:rust:flutter-rust-bridge-codegen      - install Flutter/Dart<->Rust binding generator'
  echo 'install:rust:packages                         - install Rust packages'
  echo 'install:rust:targets                          - install Rust targets'
  echo 'lint                                          - synonym for analyze'
  echo 'lint:fix <rule>                               - synonym for analyze:fix'
  echo 'lint:fix:dry                                  - synonym for analyze:fix:dry'
  echo 'outdated                                      - list outdated dependencies'
  echo 'reset                                         - re-installs dependencies, re-generates code, runs tests, builds app and more'
  echo 'run [<mode>]                                  - run app'
  echo 'simulator                                     - open iOS simulator'
  echo 'start                                         - synonym for run'
  echo 'test [<path>] [<name>]                        - run tests'
  echo 'test:random                                   - run all tests in random order'
  echo 'test:watch [<path>] [<name>]                  - run tests in watch mode'
  echo 'upload <platform>                             - upload ios or android app to app store'
}

if [ "$1" = 'analyze' ]; then analyze; exit; fi
if [ "$1" = 'analyze:files' ]; then analyzeFiles; exit; fi
if [ "$1" = 'analyze:fix' ]; then analyzeFix "$@"; exit; fi
if [ "$1" = 'analyze:fix:dry' ]; then analyzeFixDryRun; exit; fi
if [ "$1" = 'analyze:todos' ]; then analyzeTodos; exit; fi
if [ "$1" = 'build' ]; then build "$@"; exit; fi
if [ "$1" = 'clean' ]; then clean; exit; fi
if [ "$1" = 'coverage' ]; then coverage; exit; fi
if [ "$1" = 'coverage:generate' ]; then coverageGenerate; exit; fi
if [ "$1" = 'coverage:measure' ]; then coverageMeasure; exit; fi
if [ "$1" = 'coverage:measure:random' ]; then coverageMeasureRandom; exit; fi
if [ "$1" = 'coverage:open' ]; then coverageOpen; exit; fi
if [ "$1" = 'coverage:print' ]; then coveragePrint; exit; fi
if [ "$1" = 'coverage:validate' ]; then coverageValidate "$@"; exit; fi
if [ "$1" = 'delete:lock' ]; then deleteLockFiles; exit; fi
if [ "$1" = 'doctor' ]; then doctor; exit; fi
if [ "$1" = 'format' ]; then format; exit; fi
if [ "$1" = 'generate' ]; then generate; exit; fi
if [ "$1" = 'generate:icon' ]; then generateIcon; exit; fi
if [ "$1" = 'generate:json' ]; then generateJson; exit; fi
if [ "$1" = 'generate:rust' ]; then generateRust; exit; fi
if [ "$1" = 'generate:splash' ]; then generateSplash; exit; fi
if [ "$1" = 'help' ]; then help; exit; fi
if [ "$1" = 'install' ]; then install; exit; fi
if [ "$1" = 'install:cocoa:pods' ]; then installCocoaPods; exit; fi
if [ "$1" = 'install:fastlane' ]; then installFastlane; exit; fi
if [ "$1" = 'install:flutter:packages' ]; then installFlutterPackages; exit; fi
if [ "$1" = 'install:rust:flutter-rust-bridge-codegen' ]; then installFlutterRustBridgeCodegen; exit; fi
if [ "$1" = 'install:rust:packages' ]; then installRustPackages; exit; fi
if [ "$1" = 'install:rust:targets' ]; then installRustTargets; exit; fi
if [ "$1" = 'lint' ]; then analyze; exit; fi
if [ "$1" = 'lint:files' ]; then analyzeFiles; exit; fi
if [ "$1" = 'lint:fix' ]; then analyzeFix "$@"; exit; fi
if [ "$1" = 'lint:fix:dry' ]; then analyzeFixDryRun; exit; fi
if [ "$1" = 'lint:todos' ]; then analyzeTodos; exit; fi
if [ "$1" = 'outdated' ]; then outdated; exit; fi
if [ "$1" = 'reset' ]; then reset; exit; fi
if [ "$1" = 'run' ]; then run "$@"; exit; fi
if [ "$1" = 'simulator' ]; then simulator; exit; fi
if [ "$1" = 'start' ]; then run "$@"; exit; fi
if [ "$1" = 'test' ]; then tests "$@"; exit; fi
if [ "$1" = 'test:random' ]; then testsRandom "$@"; exit; fi
if [ "$1" = 'test:watch' ]; then testsWatch "$@"; exit; fi
if [ "$1" = 'upload' ]; then upload "$@"; exit; fi

help
exit 1
