#!/bin/bash

set -e

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

if command -v fvm >/dev/null 2>&1; then FLUTTER="fvm flutter"; else FLUTTER="flutter"; fi
if command -v fvm >/dev/null 2>&1; then DART="fvm dart"; else DART="dart"; fi

clean() {
  $FLUTTER clean
  if [ -d "android/.gradle" ]; then rm -rf android/.gradle; fi
  if [ -d "ios/.symlinks" ];   then rm -rf ios/.symlinks;   fi
  if [ -d "ios/Pods" ];        then rm -rf ios/Pods;        fi
}

deleteLockFiles() {
  rm -f pubspec.lock
  rm -f ios/Podfile.lock
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
  bash "$0" run
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
  echo 'analyze                                   - analyze code'
  echo 'analyze:dart                              - run static code analysis (lint)'
  echo 'analyze:fix <rule>                        - fix static code analysis rule violations'
  echo 'analyze:fix:dry                           - simulates fixing static code analysis rule violations'
  echo 'clean                                     - clean build'
  echo 'delete:lock                               - delete lock files'
  echo 'dev                                       - build and run widgetbook'
  echo 'doctor                                    - run flutter doctor'
  echo 'format                                    - format code'
  echo 'generate                                  - update generated code'
  echo 'generate:json                             - update generated json *.g.dart files'
  echo 'help                                      - print this help'
  echo 'install                                   - install dependencies'
  echo 'install:cocoa:pods                        - install Cocoa Pods'
  echo 'install:flutter:packages                  - install Flutter packages'
  echo 'lint*                                     - synonym for analyze'
  echo 'outdated                                  - list outdated dependencies'
  echo 'refresh                                   - clean, install, generate, run'
  echo 'reset                                     - clean, delete lock files, install, generate, analyze, run'
  echo 'run                                       - run widgetbook'
  echo 'simulator                                 - open iOS simulator'
  echo 'start*                                    - synonym for run'
}

case "$1" in
  analyze)                   bash "$0" analyze:dart; ;;
  analyze:dart)              $FLUTTER analyze lib; ;;
  analyze:fix)               $DART fix --apply --code="$2"; ;;
  analyze:fix:dry)           $DART fix --dry-run; ;;
  clean)                     clean; ;;
  delete:lock)               deleteLockFiles; ;;
  dev)                       bash "$0" generate; bash "$0" run; ;;
  doctor)                    $FLUTTER doctor; ;;
  format)                    $DART format --line-length=120 lib; ;;
  generate)                  bash "$0" generate:json; bash "$0" format; bash "$0" analyze; ;;
  generate:json)             $DART run build_runner build --delete-conflicting-outputs; ;;
  install)                   bash "$0" install:flutter:packages; bash "$0" install:cocoa:pods; ;;
  install:cocoa:pods)        $FLUTTER precache --ios; cd ios; pod install --repo-update; cd ..; ;;
  install:flutter:packages)  $FLUTTER pub get; ;;
  outdated)                  $FLUTTER pub outdated; ;;
  refresh)                   bash "$0" clean; bash "$0" install; bash "$0" generate; bash "$0" run; ;;
  reset)                     reset; ;;
  run)                       $FLUTTER run; ;;
  simulator)                 open -a Simulator; ;;
  *)                         help; exit 1 ;;
esac
