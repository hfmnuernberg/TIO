#!/bin/bash

set -e

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

if command -v fvm >/dev/null 2>&1; then FLUTTER="fvm flutter"; else FLUTTER="flutter"; fi

help() {
  echo "Usage: $0 run [<env>] [<flavor>] [<mode>]"
  echo 'env     - dev, development, prd, prod, production'
  echo 'flavor  - dev, development, prd, prod, production'
  echo 'mode    - debug, profile, release'
}

if [ "$1" = "help" ]; then help; exit 0; fi

if [ "$1" = 'dev' ]; then ENV='dev'; fi
if [ "$1" = 'development' ]; then ENV='dev'; fi
if [ "$1" = 'prd' ]; then ENV='prd'; fi
if [ "$1" = 'prod' ]; then ENV='prd'; fi
if [ "$1" = 'production' ]; then ENV='prd'; fi
if [ -z "$ENV" ]; then ENV='dev'; fi

if [ "$2" = 'dev' ]; then FLAVOR='dev'; fi
if [ "$2" = 'development' ]; then FLAVOR='dev'; fi
if [ "$2" = 'prd' ]; then FLAVOR='prd'; fi
if [ "$2" = 'prod' ]; then FLAVOR='prd'; fi
if [ "$2" = 'production' ]; then FLAVOR='prd'; fi
if [ -z "$FLAVOR" ]; then FLAVOR='dev'; fi

if [ -z "$3" ]; then MODE='debug'; else MODE="$4"; fi

echo "Running app ..."
echo "  env:     $ENV"
echo "  flavor:  $FLAVOR"
echo "  mode:    $MODE"

$FLUTTER run \
    --dart-define=ENVIRONMENT="$ENV" \
    --target lib/main.dart \
    --flavor "$FLAVOR" \
    "--$MODE"
