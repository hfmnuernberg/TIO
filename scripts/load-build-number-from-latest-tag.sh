#!/bin/bash

set -e

echo "⚙️ Loading semantic version from latest Git tag..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌  Not inside a Git repository" >&2
  exit 1
fi

set +e
TAG=$(git tag --list 'v*' --sort=-creatordate | head -n 1)
set -e

if [ -z "$TAG" ]; then
  echo "⚠️️ No Git tag found! Assuming semantic version 0.0.1."
  SEMVER="0.0.1"
else
  SEMVER=$(echo "$TAG" | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
  if [ "$SEMVER" = "$TAG" ]; then
    echo "⚠️️ No semantic version found in Git tag! Assuming semantic version 0.0.1."
    SEMVER="0.0.1"
  fi
fi

export SEMVER

echo "SEMVER=$SEMVER"
echo "✅️ Loaded semantic version from latest Git tag."
