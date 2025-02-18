#!/bin/bash

set -e

# ===== arguments and variables =====

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

# ===== configuration =====

MIN_BUILD_NUMBER=100000000

# ===== business logic =====

echo "⚙️ Updating version and build number in pubspec.yaml..."

# Extract version from pubspec.yaml
CURRENT_VERSION=$(awk -F'[: ]+' '/^version:/ {print $2}' pubspec.yaml | cut -d'+' -f1)

# Extract current build number from pubspec.yaml
CURRENT_BUILD_NUMBER=$(awk -F'[:+]' '/^version:/ {print $3}' pubspec.yaml | tr -d ' ')

echo "ℹ️️ Current version and build number in pubspec.yaml: $CURRENT_VERSION ($CURRENT_BUILD_NUMBER)"

# Get latest Git tag (without "v" prefix)
GIT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')

# Ensure a valid version is always used
if [ -z "$GIT_VERSION" ]; then
    echo "⚠️ No Git tags found! Using pubspec.yaml version: $CURRENT_VERSION"
    VERSION="$CURRENT_VERSION"
else
    VERSION="$GIT_VERSION"
fi

# Get the number of commits since that tag
COMMITS_SINCE_LAST_TAG=$(git rev-list --count HEAD 2>/dev/null || echo "1")

# Ensure build number is always increasing
BUILD_NUMBER=$((MIN_BUILD_NUMBER + COMMITS_SINCE_LAST_TAG))
if [ "$BUILD_NUMBER" -le "$CURRENT_BUILD_NUMBER" ]; then
    BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
fi

echo "ℹ️️ New version and build number in pubspec.yaml: $VERSION ($BUILD_NUMBER)"

# Detect OS (macOS or Linux)
OS=$(uname)
if [ "$OS" = "Darwin" ]; then SED_I="sed -i ''"; else SED_I="sed -i"; fi

# Update pubspec.yaml safely using cross-platform `sed`
$SED_I "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml

# ===== print results =====

echo "✅️ Updated version and build number in pubspec.yaml to: $VERSION ($BUILD_NUMBER)."
