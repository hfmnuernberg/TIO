#!/bin/bash

set -e

DEFAULT_SEMVER="0.0.1"
DEFAULT_BUILD_NUMBER="1"

echo "⚙️ Loading version from latest git tag..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌  Not inside a Git repository" >&2
  exit 1
fi

set +e
TAG=$(git tag --list '*.*.*' --sort=-creatordate | head -n1)
set -e

if [ -z "$TAG" ]; then
  echo "⚠️️ No Git tag found! Assuming version $DEFAULT_SEMVER+$DEFAULT_BUILD_NUMBER."
else
  SEMVER=$(echo "$TAG" | sed -E 's/^v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
  if [ "$SEMVER" = "$TAG" ]; then
    echo "⚠️️ No valid semantic version found in tag! Assuming semantic version $DEFAULT_SEMVER."
    SEMVER=$DEFAULT_SEMVER
  fi
  BUILD_NUMBER=$(echo "$TAG" | sed -E 's/^v?[0-9]+\.[0-9]+\.[0-9]+\+([0-9]+).*/\1/')
  if [ "$BUILD_NUMBER" = "$TAG" ]; then
    echo "⚠️️ No valid build number found in tag! Assuming build number $DEFAULT_BUILD_NUMBER."
    BUILD_NUMBER=$DEFAULT_BUILD_NUMBER
  fi
fi

VERSION="$SEMVER+$BUILD_NUMBER"

export TAG
export SEMVER
export BUILD_NUMBER
export VERSION

echo "TAG=$TAG"
echo "SEMVER=$SEMVER"
echo "BUILD_NUMBER=$BUILD_NUMBER"
echo "VERSION=$VERSION"

echo "✅️ Loaded version from latest git tag: $VERSION"
