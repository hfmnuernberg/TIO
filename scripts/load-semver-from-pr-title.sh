#!/usr/bin/env bash

set -e

echo "⚙️ Extracting semantic versions from PR title..."

PR_TITLE="$1"

OLD_VERSION=$(echo "$PR_TITLE" | sed -n 's/.* from \([^ ]*\) to.*/\1/p')
IFS='.' read -r OLD_MAJOR OLD_MINOR OLD_PATCH <<< "$OLD_VERSION"
echo
echo "OLD_VERSION=$OLD_VERSION"; export OLD_VERSION
echo "OLD_MAJOR=$OLD_MAJOR";     export OLD_MAJOR
echo "OLD_MINOR=$OLD_MINOR";     export OLD_MINOR
echo "OLD_PATCH=$OLD_PATCH";     export OLD_PATCH

NEW_VERSION=$(echo "$PR_TITLE" | sed -n 's/.* to \([^ ]*\).*/\1/p')
IFS='.' read -r NEW_MAJOR NEW_MINOR NEW_PATCH <<< "$NEW_VERSION"
echo
echo "NEW_VERSION=$NEW_VERSION"; export NEW_VERSION
echo "NEW_MAJOR=$NEW_MAJOR";     export NEW_MAJOR
echo "NEW_MINOR=$NEW_MINOR";     export NEW_MINOR
echo "NEW_PATCH=$NEW_PATCH";     export NEW_PATCH

if [ "$NEW_MAJOR" != "$OLD_MAJOR" ]; then
  BUMP_TYPE="major"
elif [ "$NEW_MINOR" != "$OLD_MINOR" ]; then
  BUMP_TYPE="minor"
elif [ "$NEW_PATCH" != "$OLD_PATCH" ]; then
  BUMP_TYPE="patch"
else
  BUMP_TYPE="unknown"
fi
echo
echo "BUMP_TYPE=$BUMP_TYPE";     export BUMP_TYPE

echo
echo "✅️ Extracted semantic versions from PR title."
