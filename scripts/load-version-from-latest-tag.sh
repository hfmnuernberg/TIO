#!/bin/bash

set -e

DEFAULT_SEMVER="0.0.1"
DEFAULT_BUILD_NUMBER="1"

echo "⚙️ Loading version from latest Git tag..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌  Not inside a Git repository" >&2
  exit 1
fi

set +e
SEMVER_TAG=$(git tag --list '[0-9]*.[0-9]*.[0-9]*+*' | sort -V | tail -n1)
BUILD_NUMBER_TAG=$(git tag --list '[0-9]*.[0-9]*.[0-9]*+*' | sort -V | tail -n1)
set -e

if [ -z "$SEMVER_TAG" ]; then
  echo "⚠️️ No Git tag with semantic version found! Assuming semantic version $DEFAULT_SEMVER."
  SEMVER=$DEFAULT_SEMVER
else
  SEMVER=$(echo "$SEMVER_TAG" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
  if [ "$SEMVER" = "$SEMVER_TAG" ]; then
    echo "⚠️️ No valid semantic version found in tag! Assuming semantic version $DEFAULT_SEMVER."
    SEMVER=$DEFAULT_SEMVER
  fi
fi

if [ -z "$BUILD_NUMBER_TAG" ]; then
  echo "⚠️️ No Git tag with build number found! Assuming build number $DEFAULT_BUILD_NUMBER."
  BUILD_NUMBER=$DEFAULT_BUILD_NUMBER
else
  BUILD_NUMBER=$(echo "$BUILD_NUMBER_TAG" | sed -E 's/^[0-9]+\.[0-9]+\.[0-9]+\+([0-9]+).*/\1/')
  if [ "$BUILD_NUMBER" = "$BUILD_NUMBER_TAG" ]; then
    echo "⚠️️ No valid build number found in tag! Assuming build number $DEFAULT_BUILD_NUMBER."
    BUILD_NUMBER=$DEFAULT_BUILD_NUMBER
  fi
fi

VERSION="$SEMVER+$BUILD_NUMBER"

export SEMVER_TAG
export BUILD_NUMBER_TAG
export SEMVER
export BUILD_NUMBER
export VERSION

echo "SEMVER_TAG=$SEMVER_TAG"
echo "BUILD_NUMBER_TAG=$BUILD_NUMBER_TAG"
echo "SEMVER=$SEMVER"
echo "BUILD_NUMBER=$BUILD_NUMBER"
echo "VERSION=$VERSION"

echo "✅️ Loaded version from latest Git tag: $VERSION"
