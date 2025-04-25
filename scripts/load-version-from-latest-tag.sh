#!/bin/bash

set -e

echo "⚙️ Loading version from last git tag..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌  Not inside a Git repository" >&2
  exit 1
fi

set +e
TAG=$(git tag --list 'v*' --sort=-creatordate | head -n 1)
set -e

if [ -z "$TAG" ]; then
  echo "⚠️️ No Git tag found! Assuming version 0.0.1."
  VERSION="0.0.1"
else
  VERSION=$(echo "$TAG" | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
  if [ "$VERSION" = "$TAG" ]; then
    echo "⚠️️ No version found! Assuming version 0.0.1."
    VERSION="0.0.1"
  fi
fi

export VERSION

echo "VERSION=$VERSION"
echo "✅️ Loaded version from last git tag."
