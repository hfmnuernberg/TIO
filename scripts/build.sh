#!/bin/bash

set -e

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

if command -v fvm >/dev/null 2>&1; then FLUTTER="fvm flutter"; else FLUTTER="flutter"; fi

help() {
  echo "Usage: $0 build <platform> [<env>] [<flavor>] [<mode>]"
  echo "platform  - ios, android"
  echo 'env       - dev, development, prd, prod, production'
  echo 'flavor    - dev, development, prd, prod, production'
  echo 'mode      - debug, profile, release'
}

if [ "$1" = "help" ]; then help; exit 0; fi

if [ "$1" = "ios" ]; then PLATFORM="ios"; fi
if [ "$1" = "android" ]; then PLATFORM="android"; fi

if [ -z "$PLATFORM" ]; then help; exit 1; fi

if [ "$2" = 'dev' ]; then ENV='dev'; fi
if [ "$2" = 'development' ]; then ENV='dev'; fi
if [ "$2" = 'prd' ]; then ENV='prd'; fi
if [ "$2" = 'prod' ]; then ENV='prd'; fi
if [ "$2" = 'production' ]; then ENV='prd'; fi
if [ -z "$ENV" ]; then ENV='dev'; fi

if [ "$3" = 'dev' ]; then FLAVOR='dev'; fi
if [ "$3" = 'development' ]; then FLAVOR='dev'; fi
if [ "$3" = 'prd' ]; then FLAVOR='prd'; fi
if [ "$3" = 'prod' ]; then FLAVOR='prd'; fi
if [ "$3" = 'production' ]; then FLAVOR='prd'; fi
if [ -z "$FLAVOR" ]; then FLAVOR='dev'; fi

if [ -z "$4" ]; then MODE='debug'; else MODE="$4"; fi

echo "Building app ..."
echo "  platform:  $PLATFORM"
echo "  env:       $ENV"
echo "  flavor:    $FLAVOR"
echo "  mode:      $MODE"

if [ "$PLATFORM" = 'ios' ]; then EXPORT_OPTIONS_ARG='--export-options-plist'; fi
if [ "$PLATFORM" = 'ios' ]; then EXPORT_OPTIONS_VAL="ios/export-options-$ENV.plist"; fi

if [ "$PLATFORM" = 'ios' ]; then BUILD_COMMAND='ipa'; fi
if [ "$PLATFORM" = 'android' ]; then BUILD_COMMAND='appbundle'; fi

set -x
$FLUTTER build \
  "$BUILD_COMMAND" \
  --dart-define=ENVIRONMENT="$ENV" \
  --target lib/main.dart \
  --flavor "$FLAVOR" \
  "$EXPORT_OPTIONS_ARG" "$EXPORT_OPTIONS_VAL" \
  "--$MODE"
set +x
