#!/bin/bash

set -e

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

if command -v fvm >/dev/null 2>&1; then FLUTTER="fvm flutter"; else FLUTTER="flutter"; fi

help() {
  echo "Usage: $0 run [<mode>]"
  echo 'mode      - debug, profile, release'
}

if [ "$1" = "help" ]; then help; exit 0; fi

if [ -z "$1" ]; then MODE='debug'; else MODE="$1"; fi

echo "Running app ..."
echo "  mode:      $MODE"

$FLUTTER run "--$MODE"
