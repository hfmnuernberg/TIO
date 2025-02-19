#!/bin/bash

set -e

PUBSPEC_FILE=pubspec.yaml

echo "⚙️ Loading version and build number from $PUBSPEC_FILE..."

if [ ! -f "./$PUBSPEC_FILE" ]; then
  echo "❌  Unable to find $PUBSPEC_FILE"
  exit 1
fi

VERSION=$(awk -F'[: ]+' '/^version:/ {print $2}' $PUBSPEC_FILE | cut -d'+' -f1)
BUILD_NUMBER=$(awk -F'[:+]' '/^version:/ {print $3}' $PUBSPEC_FILE | tr -d ' ')

export VERSION
export BUILD_NUMBER

echo "✅️ Loaded version and build number from $PUBSPEC_FILE: $VERSION+$BUILD_NUMBER"
