#!/bin/bash

set -e

# ===== configuration =====

PUBSPEC_FILE=pubspec.yaml

# ===== business logic =====

echo "⚙️ Committing new version and build number in $PUBSPEC_FILE..."

source ./scripts/versioning/load.sh

git config --global user.email "github-actions@github.com"
git config --global user.name "GitHub Actions"

git add $PUBSPEC_FILE
git commit -m "ci: update version to $VERSION ($BUILD_NUMBER)"
git push origin "$(git rev-parse --abbrev-ref HEAD)"

# ===== print results =====

echo "✅️ Committed new version and build number in $PUBSPEC_FILE: $VERSION ($BUILD_NUMBER)."
