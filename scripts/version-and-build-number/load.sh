#!/bin/bash

set -e

# ===== configuration =====

PUBSPEC_FILE=pubspec.yaml

# ===== business logic =====

echo "⚙️ Loading current version and build number from $PUBSPEC_FILE..."

if [ ! -f "./$PUBSPEC_FILE" ]; then echo "❌  Unable to find $PUBSPEC_FILE"; exit 1; fi

# Extract version from pubspec file
VERSION=$(awk -F'[: ]+' '/^version:/ {print $2}' $PUBSPEC_FILE | cut -d'+' -f1)
export VERSION

# Extract current build number from pubspec file
BUILD_NUMBER=$(awk -F'[:+]' '/^version:/ {print $3}' $PUBSPEC_FILE | tr -d ' ')
export BUILD_NUMBER

# ===== print results =====

echo "✅️ Loaded current version and build number from $PUBSPEC_FILE: $VERSION ($BUILD_NUMBER)."
