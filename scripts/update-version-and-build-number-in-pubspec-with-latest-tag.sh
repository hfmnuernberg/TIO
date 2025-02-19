#!/bin/bash

set -e

PUBSPEC_FILE=pubspec.yaml

echo "⚙️ Updating version in $PUBSPEC_FILE with latest Git tag..."

source ./scripts/load-version-and-build-number-from-latest-tag.sh

# Update pubspec safely considering if current OS is macOS or not
if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" "$PUBSPEC_FILE"
else
    sed -i "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" "$PUBSPEC_FILE"
fi

echo "✅️ Updated version in $PUBSPEC_FILE to: $VERSION+$BUILD_NUMBER"
