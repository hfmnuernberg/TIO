#!/bin/bash

set -e

PUBSPEC_FILE=pubspec.yaml

if [ "$#" -ne 1 ]; then
  echo "📖 Usage: $0 <version>"
  echo 'version  - the semantic version to set (e.g., 1.2.3+42)'
  exit 1
fi

VERSION=$1

echo "⚙️ Setting version in $PUBSPEC_FILE to: $VERSION..."

# Update pubspec safely considering if current OS is macOS or not
if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "s/^version: .*/version: $VERSION/" "$PUBSPEC_FILE"
else
    sed -i "s/^version: .*/version: $VERSION/" "$PUBSPEC_FILE"
fi

echo "✅️ Set version in $PUBSPEC_FILE to: $VERSION"
