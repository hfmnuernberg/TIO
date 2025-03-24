#!/bin/bash

set -e

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

if command -v fvm >/dev/null 2>&1; then FLUTTER="fvm flutter"; else FLUTTER="flutter"; fi

help() {
  echo "Usage: $0 build <platform> [<mode>]"
  echo "  platform     - ios, android"
  echo "  mode         - debug, profile, release"
}

if [ "$1" = "help" ]; then help; exit 0; fi

if [ "$1" = "ios" ]; then PLATFORM="ios"; fi
if [ "$1" = "android" ]; then PLATFORM="android"; fi

if [ -z "$PLATFORM" ]; then help; exit 1; fi

if [ -z "$2" ]; then MODE="debug"; else MODE="$2"; fi

echo "Building app ..."
echo "  platform:     $PLATFORM"
echo "  mode:         $MODE"

if [ "$PLATFORM" = 'ios' ]; then EXPORT_OPTIONS_ARG='--export-options-plist'; fi
if [ "$PLATFORM" = 'ios' ]; then EXPORT_OPTIONS_VAL='ios/export-options.plist'; fi

if [ "$PLATFORM" = 'ios' ]; then BUILD_COMMAND='ipa'; fi
if [ "$PLATFORM" = 'android' ]; then BUILD_COMMAND='appbundle'; fi

set -x
$FLUTTER build \
  "$BUILD_COMMAND" \
  --target lib/main.dart \
  "$EXPORT_OPTIONS_ARG" "$EXPORT_OPTIONS_VAL" \
  "--$MODE"
set +x
