#!/bin/bash

set -e

source ./scripts/load-build-number-from-latest-tag.sh

OLD_BUILD_NUMBER=$BUILD_NUMBER
NEW_BUILD_NUMBER=$((OLD_BUILD_NUMBER + 1))
TAG="b$NEW_BUILD_NUMBER"

echo "⚙️ Bumping build number and creating tag..."

git tag "$TAG"
git push origin "$TAG"

export OLD_BUILD_NUMBER
export NEW_BUILD_NUMBER

echo "OLD_BUILD_NUMBER=$OLD_BUILD_NUMBER"
echo "NEW_BUILD_NUMBER=$NEW_BUILD_NUMBER"
echo "✅️ Bumped build number from $OLD_BUILD_NUMBER to $NEW_BUILD_NUMBER and created tag: $TAG"
