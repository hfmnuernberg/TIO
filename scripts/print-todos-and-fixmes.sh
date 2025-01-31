#!/bin/bash

# Check if a directory was provided as an argument
if [ -z "$1" ]; then
  echo "📖 Usage: $0 <directory>"
  exit 1
fi

DIRECTORY="$1"
CURRENT_SCRIPT=$(basename "$0")  # Get the name of the current script

# Define the patterns for the files to search (all text files)
FILE_TYPES="*.txt *.md *.html *.js *.mjs *.jsx *.ts *.tsx *.dart *.java *.kt *.css *.scss *.json *.yml *.yaml *.sh"

# Define the folders to ignore
IGNORED_FOLDERS=".dart_tool .fvm .git .idea build coverage android/.gradle ios/.symlinks ios/Pods"

# Build the find command to exclude multiple ignored folders
IGNORED_PATHS=""
for folder in $IGNORED_FOLDERS; do
  IGNORED_PATHS="$IGNORED_PATHS -not -path '*/$folder/*'"
done

# Initialize counters for TODO and FIXME occurrences
todo_count=0
fixme_count=0

# Initialize lists to store TODOs and FIXMEs
todos=""
fixmes=""

# Search for TODO and FIXME occurrences
for pattern in $FILE_TYPES; do
  files=$(eval find "$DIRECTORY" -type f -name "$pattern" $IGNORED_PATHS -not -name "$CURRENT_SCRIPT")

  for file in $files; do
    # Print and count TODO occurrences
    todos_in_file=$(grep -n "TODO" "$file" 2>/dev/null)
    if [ -n "$todos_in_file" ]; then
      todos+="$todos_in_file"$'\n'
      todo_count=$((todo_count + $(echo "$todos_in_file" | wc -l)))
    fi

    # Print and count FIXME occurrences
    fixmes_in_file=$(grep -n "FIXME" "$file" 2>/dev/null)
    if [ -n "$fixmes_in_file" ]; then
      fixmes+="$fixmes_in_file"$'\n'
      fixme_count=$((fixme_count + $(echo "$fixmes_in_file" | wc -l)))
    fi
  done
done

# Print TODOs and FIXMEs
if [ -n "$todos" ]; then
  echo "🔖 TODOs found:"
  echo "$todos"
else
  echo "No TODOs found."
fi

if [ -n "$fixmes" ]; then
  echo "🔧 FIXMEs found:"
  echo "$fixmes"
else
  echo "No FIXMEs found."
fi

# Print the total counts
echo "Total number of TODO occurrences: $todo_count"
echo "Total number of FIXME occurrences: $fixme_count"
