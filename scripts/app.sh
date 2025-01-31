#!/bin/sh

set -e

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

getVariable() {
  name=$1
  value=$(eval "echo \$$1")
  default=$2
  if [ -z "$value" ]; then value=$default; fi
  if [ -z "$value" ]; then echo "$name: " >&2; read -r value; fi
  if [ -z "$value" ]; then echo "❌  No $1 specified!" >&2; exit 1; fi
  echo "$value"
}

getTestCommand() {
  command="fvm flutter test"

  if [ -n "$2" ]; then TEST_PATH="$2"; fi
  if [ "${TEST_PATH#test/}" = "$TEST_PATH" ]; then TEST_PATH="test/$TEST_PATH"; fi
  command="$command $TEST_PATH"

  if [ -n "$3" ]; then command="$command --plain-name '$3'"; fi

  echo "$command"
}

analyze() { fvm flutter analyze lib test; }

analyzeFix() { fvm dart fix --apply --code="$2"; }

analyzeFixDryRun() { fvm dart fix --dry-run; }

build() {
  if [ "$2" = 'ios' ]; then PLATFORM='ios'; fi
  if [ "$2" = 'android' ]; then PLATFORM='android'; fi

  if [ -z "$PLATFORM" ]; then
    echo "Usage: $0 build <platform> [<flavor>] [<mode>]"
    echo "platform  - ios, android"
    echo 'flavor    - dev, tst, prd'
    echo 'mode      - debug, profile, release'
    exit 1
  fi

  if [ -z "$4" ]; then FLAVOR='dev'; else FLAVOR="$4"; fi
  if [ -z "$5" ]; then MODE='debug'; else MODE="$5"; fi

  echo "Building app for platform: '$PLATFORM' with flavor: '$FLAVOR' and mode: '$MODE' ..."

  if [ "$PLATFORM" = 'ios' ]; then
    set -x
    fvm flutter build ipa \
        --flavor "$FLAVOR" \
        --target lib/main.dart \
        --build-number 1
    set +x
  fi

  if [ "$PLATFORM" = 'android' ]; then
    set -x
    fvm flutter build appbundle \
        --flavor "$FLAVOR" \
        --target lib/main.dart \
        --build-number 1 \
        "--$MODE"
    set +x
  fi
}

clean() {
  fvm flutter clean
  if [ -d "coverage" ];        then rm -rf coverage; fi
  if [ -d "android/.gradle" ]; then rm -rf android/.gradle; fi
  if [ -d "ios/.symlinks" ];   then rm -rf ios/.symlinks;   fi
  if [ -d "ios/Pods" ];        then rm -rf ios/Pods;        fi
  if [ -d "rust/target" ];     then rm -rf rust/target;     fi
}

coverage() { coverageMeasure; coverageGenerate; coverageOpen; }

coverageGenerate() { genhtml --no-function-coverage coverage/lcov.info -o coverage/html; }
coverageMeasure() { fvm flutter test --coverage test; }
coverageOpen() { open coverage/html/index.html; }

deleteLockFiles() {
  rm pubspec.lock
  rm ios/Podfile.lock
  rm rust/Cargo.lock
  rm rust_builder/cargokit/build_tool/pubspec.lock

}

doctor() { fvm flutter doctor; }

format() { fvm dart format --line-length=120 --set-exit-if-changed lib test; }

generate() {
  generateRust
  generateSplash
  generateIcon
  generateJson
  format
  analyze
}

generateIcon() { fvm flutter pub run flutter_launcher_icons -f flutter_launcher_icons.yaml; }
generateJson() { fvm dart run build_runner build --delete-conflicting-outputs; }
generateRust() { flutter_rust_bridge_codegen generate --no-dart-enums-style; }
generateSplash() { fvm flutter pub run flutter_native_splash:create --path=flutter_native_splash.yaml; }

install() { installFlutterPackages; installCocoaPods; installRustTargets; installRustPackages; }

installCocoaPods() {
  fvm flutter precache --ios
  cd ios
  pod install --repo-update
  cd ..
}

installFlutterPackages() { fvm flutter pub get; }

installRustPackages() {
  cd rust
  cargo build
  cd ..
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

outdated() { fvm flutter pub outdated; }

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
  run
}

run() {
  if [ "$2" = 'ios' ]; then PLATFORM='ios'; fi
  if [ "$2" = 'android' ]; then PLATFORM='android'; fi

  if [ -z "$PLATFORM" ]; then
    echo "Usage: $0 run <platform> [<flavor>] [<mode>]"
    echo "platform  - ios, android"
    echo 'flavor    - dev, tst, prd'
    echo 'mode      - debug, profile, release'
    exit 1
  fi

  if [ -z "$4" ]; then FLAVOR='dev'; else FLAVOR="$4"; fi
  if [ -z "$5" ]; then MODE='debug'; else MODE="$5"; fi

  echo "Running app on platform: '$PLATFORM' with flavor: '$FLAVOR' and mode: '$MODE' ..."

  if [ "$PLATFORM" = 'ios' ]; then
    fvm flutter run \
      --flavor "$FLAVOR"
  fi

  if [ "$PLATFORM" = 'android' ]; then
    fvm flutter run \
      --flavor "$FLAVOR" \
      "--$MODE"
  fi
}

simulator() { open -a Simulator; }

tests() {
  eval "$(getTestCommand "$@")"
}

testsRandom() {
  fvm flutter test --test-randomize-ordering-seed random test
}

testsWatch() {
  command=$(getTestCommand "$@")
  watchexec -e dart "$command"
}

upload() {
  if [ "$2" = 'ios' ]; then PLATFORM='ios'; fi
  if [ "$2" = 'android' ]; then PLATFORM='android'; fi

  if [ -z "$PLATFORM" ]; then
    echo "Usage: $0 upload <platform> [<env>]"
    echo "platform  - ios, android"
    echo 'env       - tst, prd'
    exit 1
  fi

  if [ -z "$3" ]; then ENV='tst'; else ENV="$3"; fi

  echo "Uploading '$PLATFORM' app to environment: '$ENV' ..."

  cd "$PLATFORM"
  fastlane "$PLATFORM" "$ENV"_push_to_store
  cd ..
}

help() {
  echo "Usage: $0 <command> [args]"
  echo
  echo 'Commands:'
  echo
  echo 'analyze                                       - run static code analysis (lint)'
  echo 'analyze:fix <rule>                            - fix static code analysis rule violations'
  echo 'analyze:fix:dry                               - simulates fixing static code analysis rule violations'
  echo 'build <platform> [<flavor>] [<mode>]          - build app for ios or android'
  echo 'clean                                         - clean build'
  echo 'coverage                                      - measure and open test coverage report'
  echo 'coverage:generate                             - generate test coverage report from previous test run'
  echo 'coverage:measure                              - run all tests and measure test coverage'
  echo 'coverage:open                                 - open test coverage report from previous test run'
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
  echo 'install:flutter:package                       - install Flutter packages'
  echo 'install:rust:packages                         - install Rust packages'
  echo 'install:rust:targets                          - install Rust targets'
  echo 'lint                                          - synonym for analyze'
  echo 'lint:fix <rule>                               - synonym for analyze:fix'
  echo 'lint:fix:dry                                  - synonym for analyze:fix:dry'
  echo 'outdated                                      - list outdated dependencies'
  echo 'reset                                         - re-installs dependencies, re-generates code, runs tests, builds app and more'
  echo 'run [<flavor>] [<mode>]                       - run app'
  echo 'simulator                                     - open iOS simulator'
  echo 'start                                         - synonym for run'
  echo 'test [<path>] [<name>]                        - run tests'
  echo 'test:random                                   - run all tests in random order'
  echo 'test:watch [<path>] [<name>]                  - run tests in watch mode'
  echo 'upload <platform>                             - upload ios or android app to app store'
}

if [ "$1" = 'analyze' ]; then analyze; exit; fi
if [ "$1" = 'analyze:fix' ]; then analyzeFix "$@"; exit; fi
if [ "$1" = 'analyze:fix:dry' ]; then analyzeFixDryRun; exit; fi
if [ "$1" = 'build' ]; then build "$@"; exit; fi
if [ "$1" = 'clean' ]; then clean; exit; fi
if [ "$1" = 'coverage' ]; then coverage; exit; fi
if [ "$1" = 'coverage:generate' ]; then coverageGenerate; exit; fi
if [ "$1" = 'coverage:measure' ]; then coverageMeasure; exit; fi
if [ "$1" = 'coverage:open' ]; then coverageOpen; exit; fi
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
if [ "$1" = 'install:flutter:package' ]; then installFlutterPackages; exit; fi
if [ "$1" = 'install:rust:packages' ]; then installRustPackages; exit; fi
if [ "$1" = 'install:rust:targets' ]; then installRustTargets; exit; fi
if [ "$1" = 'lint' ]; then analyze; exit; fi
if [ "$1" = 'lint:fix' ]; then analyzeFix "$@"; exit; fi
if [ "$1" = 'lint:fix:dry' ]; then analyzeFixDryRun; exit; fi
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
