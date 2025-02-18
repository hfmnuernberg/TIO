#!/bin/bash

set -e

# ===== configuration =====

PUBSPEC_FILE=pubspec.yaml

# ===== business logic =====

echo "⚙️ Creating git tag based on version and build number in $PUBSPEC_FILE..."

source ./scripts/versioning/load.sh

TAG="v$VERSION+$BUILD_NUMBER"

git tag "$TAG"
git push origin "$TAG"

# ===== print results =====

echo "✅️ Created and pushed git tag: $TAG"
