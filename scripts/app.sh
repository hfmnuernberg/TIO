#!/bin/bash

set -e

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

if command -v fvm >/dev/null 2>&1; then FLUTTER="fvm flutter"; else FLUTTER="flutter"; fi
if command -v fvm >/dev/null 2>&1; then DART="fvm dart"; else DART="dart"; fi

clean() {
  $FLUTTER clean
  if [ -d "android/.gradle" ]; then rm -rf android/.gradle; fi
  if [ -d "android/vendor" ];  then rm -rf android/vendor;  fi
  if [ -d "coverage" ];        then rm -rf coverage;        fi
  if [ -d "ios/.symlinks" ];   then rm -rf ios/.symlinks;   fi
  if [ -d "ios/Pods" ];        then rm -rf ios/Pods;        fi
  if [ -d "ios/vendor" ];      then rm -rf ios/vendor;      fi
  bash "$0" clean:rust
}

cleanRust() {
  bash "$0" rust clean
  if [ -d "rust/target" ];     then rm -rf rust/target;     fi
  if [ -d "lib/src/rust" ];    then rm -rf lib/src/rust;    fi
  if [ ! -d "lib/src/rust" ];  then mkdir lib/src/rust;     fi
}

deleteLockFiles() {
  rm -f pubspec.lock
  rm -f ios/Podfile.lock
  rm -f rust/Cargo.lock
  rm -f rust_builder/cargokit/build_tool/pubspec.lock
}

generate() {
  bash "$0" generate:rust
  bash "$0" generate:splash
  bash "$0" generate:icon
  bash "$0" generate:json
  bash "$0" format
  bash "$0" analyze
}

getTestCommand() {
  command="$FLUTTER test"

  if [ -n "$2" ]; then TEST_PATH="$2"; fi
  if [ "${TEST_PATH#test/}" = "$TEST_PATH" ]; then TEST_PATH="test/$TEST_PATH"; fi
  command="$command $TEST_PATH"

  if [ -n "$3" ]; then command="$command --plain-name '$3'"; fi

  echo "$command"
}

install() {
  bash "$0" install:flutter:packages
  bash "$0" install:cocoa:pods
  bash "$0" install:rust
}

installRust() {
  bash "$0" install:rust:targets
  bash "$0" install:rust:packages
  bash "$0" install:rust:frb
}

installRustPackages() {
  bash "$0" rust build;
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

reset() {
  bash "$0" doctor
  bash "$0" clean
  bash "$0" delete:lock
  bash "$0" install
  bash "$0" outdated
  bash "$0" generate
  bash "$0" format
  bash "$0" analyze
  bash "$0" coverage
  bash "$0" run
}

validateCoverage() {
  total=$(lcov --summary coverage/lcov.info | awk '/lines[ .]*:/{print $2}' | tr -d '%')
  threshold=$2
  echo "Coverage:  $total%"
  echo "Threshold: $threshold%"
  awk -v cov="$total" -v th="$threshold" 'BEGIN {exit (cov >= th) ? 0 : 1}'
}

aliases=(
  "lint:analyze"
  "start:run"
  "wb:widgetbook"
)

# Alias expansion
for alias_pair in "${aliases[@]}"; do
  short="${alias_pair%%:*}"
  full="${alias_pair##*:}"

  if [[ "$1" == "$short" ]]; then
    set -- "$full" "${@:2}"
    break
  elif [[ "$1" == "$short:"* ]]; then
    suffix="${1#"$short:"}"
    set -- "$full:$suffix" "${@:2}"
    break
  fi
done

help() {
  echo "Usage: $0 <command> [args]"
  echo
  echo 'Commands:'
  echo
  echo 'analyze                                       - analyze code and yaml files'
  echo 'analyze:dart                                  - run static code analysis (lint)'
  echo 'analyze:files                                 - analyze files with too many lines of code'
  echo 'analyze:files:validate <max_count> <max_avg>  - validate count and avg length of overlong files'
  echo 'analyze:fix <rule>                            - fix static code analysis rule violations'
  echo 'analyze:fix:dry                               - simulates fixing static code analysis rule violations'
  echo 'analyze:todos                                 - analyze TODOs and FIXMEs in code'
  echo 'analyze:yaml                                  - analyze yaml files'
  echo 'build <platform> [<env>] [<flavor>] [<mode>]  - build app for ios or android'
  echo 'clean                                         - clean build (deletes coverage, generated iOS, Android, and Rust files)'
  echo 'clean:rust                                    - clean but without storybook'
  echo 'coverage                                      - measure and open test coverage report'
  echo 'coverage:generate                             - generate test coverage report from previous test run'
  echo 'coverage:measure                              - run all tests and measure test coverage'
  echo 'coverage:measure:random                       - run all tests in random order and measure test coverage'
  echo 'coverage:open                                 - open test coverage report from previous test run'
  echo 'coverage:print                                - print test coverage report from previous test run to console'
  echo 'coverage:validate <decimal>                   - validates the total test coverage against the given threshold'
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
  echo 'install:cocoa:pods                            - install Cocoa Pods'
  echo 'install:fastlane                              - install Fastlane'
  echo 'install:flutter:packages                      - install Flutter packages'
  echo 'install:rust                                  - install Flutter/Dart<->Rust binding generator, and Rust toolchain, targets, and packages'
  echo 'install:rust:frb                              - install Flutter/Dart<->Rust binding generator'
  echo 'install:rust:packages                         - install Rust packages'
  echo 'install:rust:targets                          - install Rust targets'
  echo 'lint*                                         - synonym for analyze'
  echo 'outdated                                      - list outdated dependencies'
  echo 'refresh                                       - clean, install, generate, run'
  echo 'refresh:rust                                  - Rust clean, install, generate, format, analyze, run'
  echo 'reset                                         - clean, delete lock files, install, generate, analyze, test, build, run'
  echo 'run [<env>] [<flavor>] [<mode>]               - run app'
  echo 'simulator                                     - open iOS simulator'
  echo 'start*                                        - synonym for run'
  echo 'test [<path>] [<name>]                        - run tests'
  echo 'test:random                                   - run all tests in random order'
  echo 'test:watch [<path>] [<name>]                  - run tests in watch mode'
  echo 'upload <platform> <env>                       - upload ios or android app to app store'
}

case "$1" in
  analyze)                   bash "$0" analyze:dart; bash "$0" analyze:yaml; bash "$0" widgetbook analyze; bash "$0" rust analyze; ;;
  analyze:dart)              $FLUTTER analyze lib test; ;;
  analyze:files)             scripts/analyze-files-with-too-many-lines.sh .; ;;
  analyze:files:validate)    scripts/analyze-files-with-too-many-lines.sh . validate "$2" "$3"; ;;
  analyze:fix)               $DART fix --apply --code="$2"; ;;
  analyze:fix:dry)           $DART fix --dry-run; ;;
  analyze:todos)             scripts/analyze-todos-and-fixmes.sh .; ;;
  analyze:yaml)              yamllint .; ;;
  build)                     shift; scripts/build.sh "$@"; ;;
  clean)                     clean; bash "$0" widgetbook clean; ;;
  clean:rust)                cleanRust; ;;
  coverage)                  bash "$0" coverage:measure; bash "$0" coverage:generate; bash "$0" coverage:open; ;;
  coverage:generate)         genhtml --no-function-coverage coverage/lcov.info -o coverage/html; ;;
  coverage:measure)          $FLUTTER test --coverage test; ;;
  coverage:measure:random)   $FLUTTER test --coverage --test-randomize-ordering-seed random test; ;;
  coverage:open)             open coverage/html/index.html; ;;
  coverage:print)            lcov --summary coverage/lcov.info; ;;
  coverage:validate)         validateCoverage "$@"; ;;
  delete:lock)               deleteLockFiles; ;;
  doctor)                    $FLUTTER doctor; ;;
  format)                    $DART format --line-length=120 lib test; bash "$0" widgetbook format; bash "$0" rust format; ;;
  generate)                  generate; bash "$0" widgetbook generate; ;;
  generate:icon)             $FLUTTER pub run flutter_launcher_icons -f flutter_launcher_icons.yaml; ;;
  generate:json)             $DART run build_runner build --delete-conflicting-outputs; ;;
  generate:rust)             bash "$0" rust generate; ;;
  generate:splash)           $FLUTTER pub run flutter_native_splash:create --path=flutter_native_splash.yaml; ;;
  install)                   install; bash "$0" widgetbook install; ;;
  install:cocoa:pods)        $FLUTTER precache --ios; cd ios; pod install --repo-update; cd ..; ;;
  install:fastlane)          cd android; bundle install; cd ..; cd ios; bundle install; cd ..; ;;
  install:flutter:packages)  $FLUTTER pub get; ;;
  install:rust)              installRust; ;;
  install:rust:frb)          bash "$0" rust install:frb; ;;
  install:rust:packages)     installRustPackages; ;;
  install:rust:targets)      installRustTargets; ;;
  outdated)                  $FLUTTER pub outdated; bash "$0" widgetbook outdated; bash "$0" rust outdated:root; ;;
  refresh)                   bash "$0" clean; bash "$0" install; bash "$0" generate; bash "$0" run; ;;
  refresh:rust)              bash "$0" clean:rust; bash "$0" install:rust; bash "$0" generate:rust; bash "$0" format; bash "$0" analyze; bash "$0" run; ;;
  reset)                     reset; ;;
  run)                       shift; scripts/run.sh "$@"; ;;
  simulator)                 open -a Simulator; ;;
  test)                      eval "$(getTestCommand "$@")"; ;;
  test:random)               $FLUTTER test --test-randomize-ordering-seed random test; ;;
  test:watch)                command=$(getTestCommand "$@"); watchexec -e dart "$command"; ;;
  upload)                    shift; scripts/upload.sh "$@"; ;;
  widgetbook)                shift; cd widgetbook; scripts/app.sh "$@"; cd ..; ;;
  rust)                      shift; cd rust; scripts/app.sh "$@"; cd ..; ;;
  *)                         help; exit 1 ;;
esac
