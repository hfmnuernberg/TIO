#!/bin/bash

set -e

echo "⚙️ Loading version and build number from last git tag..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌  Not inside a Git repository" >&2
  exit 1
fi

set +e
TAG=$(git tag --sort=-creatordate | head -n 1)
set -e

if [ -z "$TAG" ]; then
  echo "⚠️️ No Git tag found!"
  exit 2
else
  VERSION=$(echo "$TAG" | sed -E 's/^[v|b|r]?([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
  BUILD_NUMBER=$(echo "$TAG" | sed -E 's/^[v|b|r]?[0-9]+\.[0-9]+\.[0-9]+\+([0-9]+).*/\1/')
  if [ "$BUILD_NUMBER" = "$TAG" ]; then
    echo "⚠️️ No build number found!"
    exit 3
  fi
fi

export VERSION
export BUILD_NUMBER

echo "✅️ Loaded version and build number from last git tag: $VERSION+$BUILD_NUMBER"
