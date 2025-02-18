#!/bin/bash

set -e

# ===== configuration =====

PUBSPEC_FILE=pubspec.yaml

# ===== business logic =====

echo "⚙️ Bumping build number in $PUBSPEC_FILE..."

source ./scripts/versioning/load.sh

NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

echo "ℹ️️ New build number in $PUBSPEC_FILE: $BUILD_NUMBER"

# Update pubspec safely considering if current OS is macOS or not
if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "s/^version: .*/version: $VERSION+$NEW_BUILD_NUMBER/" "$PUBSPEC_FILE"
else
    sed -i "s/^version: .*/version: $VERSION+$NEW_BUILD_NUMBER/" "$PUBSPEC_FILE"
fi

# ===== print results =====

echo "✅️ Bumped build number in $PUBSPEC_FILE to: $NEW_BUILD_NUMBER"
