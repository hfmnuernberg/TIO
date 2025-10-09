#!/bin/bash

# ===== arguments and variables =====

if [ -z "$1" ]; then
  echo "📖 Usage: $0 <directory>"
  exit 1
fi

DIRECTORY="$1"

CURRENT_SCRIPT=$(basename "$0")  # Get the name of the current script

# ===== configuration =====

FILE_TYPES="*.txt *.md *.html *.js *.mjs *.jsx *.ts *.tsx *.dart *.java *.kt *.css *.scss *.json *.yml *.yaml *.sh"

IGNORED_FOLDERS=".dart_tool .fvm .git .idea .expo android/.gradle build coverage ios/.symlinks ios/Pods node_modules"

# ===== business logic =====

echo "⚙️ Analyzing TODOs and FIXMEs..."

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

# ===== print results =====

if [ -n "$todos" ]; then
  echo "TODOs found:"
  echo "$todos"
fi

if [ -n "$fixmes" ]; then
  echo "FIXMEs found:"
  echo "$fixmes"
fi

if [ -n "$todos" ]; then
  echo "⚠️ TODOs: $todo_count"
else
  echo "✅  No TODOs found."
fi

if [ -n "$fixmes" ]; then
  echo "⚠️ FIXMEs: $fixme_count"
else
  echo "✅  No FIXMEs found."
fi

if [ -n "$todos" ] || [ -n "$fixmes" ]; then
  exit 1
fi
