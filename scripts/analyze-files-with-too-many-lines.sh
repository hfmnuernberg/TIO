#!/bin/bash

set -e

# ===== arguments and variables =====

# Check if a directory was provided as an argument
if [ -z "$1" ]; then
  echo "📖 Usage: $0 <directory>"
  exit 1
fi

DIRECTORY="$1"

# ===== configuration =====

FILE_TYPES="*.js *.mjs *.jsx *.ts *.tsx *.dart *.java *.kt *.sh"

IGNORED_FOLDERS="node_modules .dart_tool .fvm .git .idea build coverage android/.gradle ios/.symlinks ios/Pods"

MAX_LINES=200

# ===== business logic =====

echo "⚙️ Analyzing files that exceed max-line threshold of $MAX_LINES..."

# Build the find command to exclude multiple ignored folders
IGNORED_PATHS=""
for folder in $IGNORED_FOLDERS; do
  IGNORED_PATHS="$IGNORED_PATHS -not -path '*/$folder/*'"
done

# Initialize counters
total_count=0
file_count_over_threshold=0
total_lines_over_threshold=0

# Find and count the files, excluding ignored folders
for pattern in $FILE_TYPES; do
  files=$(eval find "$DIRECTORY" -type f -name "$pattern" $IGNORED_PATHS)

  for file in $files; do
    total_count=$((total_count + 1))

    # Check the number of lines in the file
    line_count=$(wc -l < "$file")

    if [ "$line_count" -gt $MAX_LINES ]; then
      file_count_over_threshold=$((file_count_over_threshold + 1))
      total_lines_over_threshold=$((total_lines_over_threshold + line_count))
    fi
  done
done

# Calculate the average length of files that exceed the max-line threshold
if [ "$file_count_over_threshold" -gt 0 ]; then
  avg_length_over_threshold=$((total_lines_over_threshold / file_count_over_threshold))
else
  avg_length_over_threshold=0
fi

# Calculate the percentage of files that exceed the max-line threshold
if [ "$total_count" -gt 0 ]; then
  percentage_over_threshold=$(echo "scale=2; ($file_count_over_threshold / $total_count) * 200" | bc)
else
  percentage_over_threshold=0
fi

# ===== print results =====

echo "ℹ️ Total number of files: $total_count files"

if [ "$file_count_over_threshold" -gt 0 ]; then
  echo "⚠️ Number of files with more than $MAX_LINES lines: $file_count_over_threshold files ($percentage_over_threshold%)"
  echo "⚠️ Average length of files with more than $MAX_LINES lines: $avg_length_over_threshold lines"
  exit 1
else
  echo "✅️ No files exceed the max-line threshold of $MAX_LINES lines."
fi