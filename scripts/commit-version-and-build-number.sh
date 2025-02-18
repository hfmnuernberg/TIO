#!/bin/bash

set -e

# ===== arguments and variables =====

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

# ===== business logic =====

echo "⚙️ Committing new version and build number in pubspec.yaml..."

# Get the latest Git tag (version) and remove the "v" prefix
VERSION=$(git describe --tags --abbrev=0 | sed 's/^v//')

# Extract current build number from pubspec.yaml
BUILD_NUMBER=$(awk -F'[:+]' '/^version:/ {print $3}' pubspec.yaml | tr -d ' ')

git config --global user.email "github-actions@github.com"
git config --global user.name "GitHub Actions"

git add pubspec.yaml
git commit -m "ci: update version to $VERSION ($BUILD_NUMBER) [skip ci]"
git push origin "$(git rev-parse --abbrev-ref HEAD)"

# ===== print results =====

echo "✅️ Committed new version and build number in pubspec.yaml."
