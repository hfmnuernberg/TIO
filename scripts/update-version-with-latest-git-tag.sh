#!/bin/bash

set -e

# ===== configuration =====

PUBSPEC_FILE=pubspec.yaml

if [ ! -f "./$PUBSPEC_FILE" ]; then echo "❌  Unable to find $PUBSPEC_FILE"; exit 1; fi

# ===== business logic =====

echo "⚙️ Updating version in $PUBSPEC_FILE..."

# Extract version from pubspec file
CURRENT_VERSION=$(awk -F'[: ]+' '/^version:/ {print $2}' $PUBSPEC_FILE | cut -d'+' -f1)

# Extract current build number from pubspec.yaml
CURRENT_BUILD_NUMBER=$(awk -F'[:+]' '/^version:/ {print $3}' pubspec.yaml | tr -d ' ')

echo "ℹ️️Current version: $CURRENT_VERSION"

# Get latest Git tag (without "v" prefix)
GIT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')

if [ -z "$GIT_VERSION" ]; then
    echo "⚠️ No Git tags found! Using $PUBSPEC_FILE version: $CURRENT_VERSION"
    VERSION="$CURRENT_VERSION"
else
    VERSION="$GIT_VERSION"
fi

echo "ℹ️️New version: $VERSION"

# Determine cross-platform `sed`
if [ "$(uname)" = "Darwin" ]; then SED_I="sed -i ''"; else SED_I="sed -i"; fi

# Update pubspec.yaml safely using cross-platform `sed`
$SED_I "s/^version: .*/version: $VERSION+$CURRENT_BUILD_NUMBER/" $PUBSPEC_FILE

# ===== print results =====

echo "✅️ Updated version in $PUBSPEC_FILE to: $VERSION"
