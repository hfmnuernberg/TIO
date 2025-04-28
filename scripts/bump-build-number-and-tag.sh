#!/bin/bash

set -e

echo "⚙️ Bumping build number and creating tag..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌  Not inside a Git repository" >&2
  exit 1
fi

if [ -z "$1" ]; then
  echo "📖 Usage: $0 <current_build_number>"
  exit 1
fi

CURRENT_BUILD_NUMBER=$1
NEW_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
TAG="b$NEW_BUILD_NUMBER"

echo "   - Current build number: $CURRENT_BUILD_NUMBER"
echo "   - New build number: $NEW_BUILD_NUMBER"

git tag "$TAG"
git push origin "$TAG"

echo "✅️ Bumped build number and created tag: $TAG"
