#!/bin/bash

set -e

# ===== arguments and variables =====

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

# ===== business logic =====

echo "⚙️ Committing new version and build number in pubspec.yaml..."

git config --global user.email "github-actions@github.com"
git config --global user.name "GitHub Actions"

git add pubspec.yaml
git commit -m "ci: update version to $VERSION ($BUILD_NUMBER)"
git push origin "$(git rev-parse --abbrev-ref HEAD)"

# ===== print results =====

echo "✅️ Committed new version and build number in pubspec.yaml."
