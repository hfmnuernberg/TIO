#!/bin/bash

set -e

files=$(git status -s | wc -l)

if [ "$files" -le 0 ]; then
    echo "✅ No local changes detected."
else
  echo "❌ Local changes detected!"
  git status
  exit 1
fi
