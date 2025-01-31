#!/bin/bash

# Check if a directory was provided as an argument
if [ -z "$1" ]; then
  echo "📖 Usage: $0 <directory>"
  exit 1
fi

DIRECTORY="$1"

# Define the patterns for the files to count
FILE_TYPES="*.js *.mjs *.jsx *.ts *.tsx *.dart *.java *.kt *.sh"

# Define the folders to ignore
IGNORED_FOLDERS="node_modules .dart_tool .fvm .git .idea build coverage android/.gradle ios/.symlinks ios/Pods"

# Build the find command to exclude multiple ignored folders
IGNORED_PATHS=""
for folder in $IGNORED_FOLDERS; do
  IGNORED_PATHS="$IGNORED_PATHS -not -path '*/$folder/*'"
done

# Initialize counters
total_count=0
count_over_100=0
total_lines_over_100=0

# Find and count the files, excluding ignored folders
for pattern in $FILE_TYPES; do
  files=$(eval find "$DIRECTORY" -type f -name "$pattern" $IGNORED_PATHS)

  for file in $files; do
    total_count=$((total_count + 1))

    # Check the number of lines in the file
    line_count=$(wc -l < "$file")

    if [ "$line_count" -gt 100 ]; then
      count_over_100=$((count_over_100 + 1))
      total_lines_over_100=$((total_lines_over_100 + line_count))
    fi
  done
done

# Calculate the average length of files with more than 100 lines
if [ "$count_over_100" -gt 0 ]; then
  avg_length_over_100=$((total_lines_over_100 / count_over_100))
else
  avg_length_over_100=0
fi

# Calculate the percentage of files with more than 100 lines
if [ "$total_count" -gt 0 ]; then
  percentage_over_100=$(echo "scale=2; ($count_over_100 / $total_count) * 100" | bc)
else
  percentage_over_100=0
fi

# Print the results
echo "Total number of files: $total_count"
echo "Number of files with more than 100 lines: $count_over_100 ($percentage_over_100%)"
echo "Average length of files with more than 100 lines: $avg_length_over_100 lines"
