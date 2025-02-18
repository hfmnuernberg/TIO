#!/bin/bash

set -e

# ===== arguments and variables =====

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

# ===== configuration =====

MIN_BUILD_NUMBER=100000000

# ===== business logic =====

echo "⚙️ Bumping version and build number in pubspec.yaml..."

# Get the latest Git tag (version) and remove the "v" prefix
VERSION=$(git describe --tags --abbrev=0 | sed 's/^v//')

# Get the number of commits since that tag (build number)
COMMITS_SINCE_LAST_TAG=$(git rev-list --count HEAD)

# Extract current build number from pubspec.yaml
CURRENT_BUILD_NUMBER=$(grep -oP '^version: [0-9]+\.[0-9]+\.[0-9]+\+\K[0-9]+' pubspec.yaml)

# Ensure build number is always increasing
BUILD_NUMBER=$((MIN_BUILD_NUMBER + COMMITS_SINCE_LAST_TAG))
if [ "$BUILD_NUMBER" -le "$CURRENT_BUILD_NUMBER" ]; then
    BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
fi

# Update pubspec.yaml
sed -i '' "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml

# ===== print results =====

echo "✅️ Bumped version and build number in pubspec.yaml to $VERSION ($BUILD_NUMBER)."
