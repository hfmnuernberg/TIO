#!/bin/bash

set -e

# ===== configuration =====

PUBSPEC_FILE=pubspec.yaml

# ===== business logic =====

echo "⚙️ Committing new version and build number in $PUBSPEC_FILE..."

if [ ! -f "./$PUBSPEC_FILE" ]; then echo "❌  Unable to find $PUBSPEC_FILE"; exit 1; fi

# Extract version from pubspec file
CURRENT_VERSION=$(awk -F'[: ]+' '/^version:/ {print $2}' $PUBSPEC_FILE | cut -d'+' -f1)

# Extract current build number from pubspec file
CURRENT_BUILD_NUMBER=$(awk -F'[:+]' '/^version:/ {print $3}' $PUBSPEC_FILE | tr -d ' ')

echo "ℹ️️ Version and build number in $PUBSPEC_FILE: $CURRENT_VERSION ($CURRENT_BUILD_NUMBER)"

git config --global user.email "github-actions@github.com"
git config --global user.name "GitHub Actions"

git add $PUBSPEC_FILE
git commit -m "ci: update version to $VERSION ($BUILD_NUMBER) [skip ci]"
git push origin "$(git rev-parse --abbrev-ref HEAD)"

# ===== print results =====

echo "✅️ Committed new version and build number in $PUBSPEC_FILE: $CURRENT_VERSION ($CURRENT_BUILD_NUMBER)."
