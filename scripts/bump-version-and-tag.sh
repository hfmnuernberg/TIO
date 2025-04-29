#!/bin/bash

set -e

echo "⚙️ Bumping version and creating tag..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌  Not inside a Git repository" >&2
  exit 1
fi

if [ "$#" -ne 2 ]; then
  echo "📖 Usage: $0 <semantic_version> <build_number>"
  echo 'semantic_version  - current semantic version (e.g., 1.2.3)'
  echo 'build_number      - current build number (e.g., 42)'
  exit 1
fi

CURRENT_SEMVER=$1
CURRENT_BUILD_NUMBER=$2

IFS='.' read -ra PARTS <<< "$CURRENT_SEMVER"
MAJOR=${PARTS[0]}
MINOR=${PARTS[1]}
PATCH=${PARTS[2]}
NEW_PATCH=$((PATCH + 1))

NEW_SEMVER="${MAJOR}.${MINOR}.${NEW_PATCH}"
NEW_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
NEW_VERSION="$NEW_SEMVER+$NEW_BUILD_NUMBER"
NEW_TAG=$NEW_VERSION

echo
echo "Semantic version: $CURRENT_SEMVER -> $NEW_SEMVER"
echo "Build number:     $CURRENT_BUILD_NUMBER -> $NEW_BUILD_NUMBER"

git tag "$NEW_TAG"
git push origin "$NEW_TAG"

export BUILD_NUMBER
export NEW_SEMVER
export NEW_BUILD_NUMBER
export NEW_VERSION
export NEW_TAG

echo
echo "NEW_SEMVER=$NEW_SEMVER"
echo "NEW_BUILD_NUMBER=$NEW_BUILD_NUMBER"
echo "NEW_VERSION=$NEW_VERSION"
echo "NEW_TAG=$NEW_TAG"

echo
echo "✅️ Bumped version and created tag: $NEW_TAG"
