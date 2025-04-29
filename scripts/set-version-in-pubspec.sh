#!/bin/bash

set -e

PUBSPEC_FILE=pubspec.yaml

if [ "$#" -ne 2 ]; then
  echo "📖 Usage: $0 <semantic_version> <build_number>"
  echo 'semantic_version  - the semantic version to set (e.g., 1.2.3)'
  echo 'build_number      - the build number to set (e.g., 42)'
  exit 1
fi

SEMVER=$1
BUILD_NUMBER=$2
VERSION="$SEMVER+$BUILD_NUMBER"

echo "⚙️ Setting version in $PUBSPEC_FILE to: $VERSION..."

# Update pubspec safely considering if current OS is macOS or not
if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "s/^version: .*/version: $VERSION/" "$PUBSPEC_FILE"
else
    sed -i "s/^version: .*/version: $VERSION/" "$PUBSPEC_FILE"
fi

echo "✅️ Set version in $PUBSPEC_FILE to: $VERSION"
