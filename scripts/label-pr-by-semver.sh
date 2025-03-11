#!/usr/bin/env bash

echo "⚙️ Extract versions from PR title, determine semver type, and add corresponding label..."

set -euo pipefail

PR_TITLE="$1"
PR_NUMBER="$2"

echo "PR title: $PR_TITLE"
echo "PR number: $PR_PR_NUMBER"

echo "Extract OLD_VERSION and NEW_VERSION..."
OLD_VERSION=$(echo "$PR_TITLE" | sed -n 's/.* from \([^ ]*\) to.*/\1/p')
NEW_VERSION=$(echo "$PR_TITLE" | sed -n 's/.* to \([^ ]]*\).*/\1/p')

echo "OLD_VERSION: $OLD_VERSION"
echo "NEW_VERSION: $NEW_VERSION"

echo "Split each version into major, minor, patch..."
IFS='.' read -r old_major old_minor old_patch <<< "$OLD_VERSION"
IFS='.' read -r new_major new_minor new_patch <<< "$NEW_VERSION"

echo "Compare major, minor, and patch parts..."
if [ "$new_major" != "$old_major" ]; then
  BUMP_TYPE="semver: major"
elif [ "$new_minor" != "$old_minor" ]; then
  BUMP_TYPE="semver: minor"
elif [ "$new_patch" != "$old_patch" ]; then
  BUMP_TYPE="semver: patch"
else
  BUMP_TYPE="semver: unknown"
fi

echo "Apply $BUMP_TYPE bump type to label"
gh pr edit "$PR_NUMBER" --add-label "$BUMP_TYPE"

echo "✅️ Label applied!"
