#!/bin/bash

set -e

echo "⚙️ Bumping dev version and creating tag..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌  Not inside a Git repository" >&2
  exit 1
fi

if [ -z "$1" ]; then
  echo "📖 Usage: $0 <current_version>"
  exit 1
fi

CURRENT_VERSION=$1
IFS='.' read -ra PARTS <<< "$CURRENT_VERSION"
MAJOR=${PARTS[0]}
MINOR=${PARTS[1]}
NEW_MINOR=$((MINOR + 1))
NEW_VERSION="${MAJOR}.${NEW_MINOR}.0-dev"
TAG="v$NEW_VERSION"

echo "   - Current version: $CURRENT_VERSION"
echo "   - New dev version: $NEW_VERSION"

git tag "$TAG"
git push origin "$TAG"

echo "✅️ Bumped dev version and created tag: $TAG"
