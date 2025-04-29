#!/bin/bash

set -e

echo "⚙️ Loading build number from latest git tag..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌  Not inside a Git repository" >&2
  exit 1
fi

set +e
TAG=$(git tag --list 'b*' --sort=-creatordate | head -n1)
set -e

if [ -z "$TAG" ]; then
  echo "⚠️️ No Git tag found! Assuming build number 1."
  BUILD_NUMBER=1
else
  BUILD_NUMBER=$(echo "$TAG" | sed -E 's/^b([0-9]+).*/\1/')
  if [ "$BUILD_NUMBER" = "$TAG" ]; then
    echo "⚠️️ No valid build number found in tag! Assuming build number 1."
    BUILD_NUMBER=1
  fi
fi

export BUILD_NUMBER

echo "BUILD_NUMBER=$BUILD_NUMBER"
echo "✅️ Loaded build number from latest git tag."
