#!/bin/bash

set -e

echo "⚙️ Bumping build number and creating tag..."

source ./scripts/load-version-and-build-number-from-latest-tag.sh

NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

TAG="b$VERSION+$NEW_BUILD_NUMBER"
git tag "$TAG"
git push origin "$TAG"

echo "✅️ Bumped build number and created tag: $TAG"
