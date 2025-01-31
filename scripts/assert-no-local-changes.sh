#!/bin/bash

set -e

files=`git status -s | wc -l`

if [ $files -le 0 ]; then
    echo "Nice, no local changes detected! 😎"
    exit 0
fi

echo "Warning, local changes detected! 🛑"
git status
exit 1