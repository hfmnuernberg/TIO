#!/bin/bash

set -e

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

help() {
  echo "Usage: $0 upload <platform> <env>"
  echo "platform  - ios, android"
  echo 'env       - prd, prod, production'
}

if [ "$1" = "help" ]; then help; exit 0; fi

if [ "$1" = 'ios' ]; then PLATFORM='ios'; fi
if [ "$1" = 'android' ]; then PLATFORM='android'; fi

if [ "$2" = 'prd' ]; then ENV='prd'; fi
if [ "$2" = 'prod' ]; then ENV='prd'; fi
if [ "$2" = 'production' ]; then ENV='prd'; fi

if [ -z "$PLATFORM" ]; then help; exit 1; fi

if [ "$PLATFORM" = 'ios' ]; then STORE='Apple'; fi
if [ "$PLATFORM" = 'android' ]; then STORE='Google'; fi

echo "Uploading app ..."
echo "  platform:  $PLATFORM"
echo "  env:       $ENV"
echo "  store:     $STORE"

cd "$PLATFORM"
set -x
fastlane "$PLATFORM" "$ENV"_push_to_store
set +x
cd ..
