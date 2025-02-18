#!/bin/bash

set -e

# ===== arguments and variables =====

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

# ===== business logic =====

echo "⚙️ Committing new version and build number in pubspec.yaml..."

# Extract version from pubspec.yaml
CURRENT_VERSION=$(awk -F'[: ]+' '/^version:/ {print $2}' pubspec.yaml | cut -d'+' -f1)

# Extract current build number from pubspec.yaml
CURRENT_BUILD_NUMBER=$(awk -F'[:+]' '/^version:/ {print $3}' pubspec.yaml | tr -d ' ')

echo "ℹ️️ Version and build number in pubspec.yaml: $CURRENT_VERSION ($CURRENT_BUILD_NUMBER)"

git config --global user.email "github-actions@github.com"
git config --global user.name "GitHub Actions"

git add pubspec.yaml
git commit -m "ci: update version to $VERSION ($BUILD_NUMBER) [skip ci]"
git push origin "$(git rev-parse --abbrev-ref HEAD)"

# ===== print results =====

echo "✅️ Committed new version and build number in pubspec.yaml: $CURRENT_VERSION ($CURRENT_BUILD_NUMBER)."
