#!/bin/bash

set -e

# ===== configuration =====

PUBSPEC_FILE=pubspec.yaml

# ===== business logic =====

echo "⚙️ Updating version in $PUBSPEC_FILE with latest Git tag..."

source ./scripts/versioning/load.sh

echo "ℹ️️Current version: $VERSION"

# Get latest Git tag (without "v" prefix)
NEW_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')

if [ -z "$NEW_VERSION" ]; then echo "❌️ No Git tags found!"; exit 1; fi

echo "ℹ️️New version: $NEW_VERSION"

# Update pubspec safely considering if current OS is macOS or not
if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "s/^version: .*/version: $NEW_VERSION+$BUILD_NUMBER/" "$PUBSPEC_FILE"
else
    sed -i "s/^version: .*/version: $NEW_VERSION+$BUILD_NUMBER/" "$PUBSPEC_FILE"
fi

# ===== print results =====

echo "✅️ Updated version in $PUBSPEC_FILE to: $NEW_VERSION"
