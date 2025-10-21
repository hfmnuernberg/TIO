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

IGNORED_FOLDERS="node_modules .dart_tool .expo .fvm .git .idea build coverage android/.gradle ios/.symlinks ios/Pods"

MAX_LINES=200

IGNORE_FILES=(
  "lib/l10n/app_localization.dart"
  "lib/l10n/de.dart"
  "lib/l10n/en.dart"
  "lib/util/constants.dart"
  "lib/services/decorators/audio_system_log_decorator.dart"
  "lib/src/rust/frb_generated*.dart"   # generated
  "rust/scripts/app.sh"
  "scripts/app.sh"
)

IGNORE_DIRS=(
  "rust_builder"       # not real app code
)

# Helper: returns 0 (true) if $1 should be ignored
should_ignore() {
  local f="$1"
  # normalize path by removing leading ./ if present
  local p="${f#./}"

  # directory prefixes (either at start or somewhere in path)
  for d in "${IGNORE_DIRS[@]}"; do
    if [[ "$p" == "$d/"* || "$p" == *"/$d/"* ]]; then
      return 0
    fi
  done

  # file globs (support exact or pattern matches)
  for g in "${IGNORE_FILES[@]}"; do
    if [[ "$p" == $g ]]; then
      return 0
    fi
  done
  return 1
}

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
too_long_files=()
ignored_count=0
# ignored_list=()  # uncomment if you want to list ignored files

# Find and count the files, excluding ignored folders
for pattern in $FILE_TYPES; do
  files=$(eval find "$DIRECTORY" -type f -name "$pattern" $IGNORED_PATHS)

  for file in $files; do
    # Skip ignored files early
    if should_ignore "$file"; then
      ignored_count=$((ignored_count + 1))
      # ignored_list+=("$file")
      continue
    fi

    total_count=$((total_count + 1))

    # Check the number of lines in the file
    line_count=$(wc -l < "$file")

    if [ "$line_count" -gt $MAX_LINES ]; then
      file_count_over_threshold=$((file_count_over_threshold + 1))
      total_lines_over_threshold=$((total_lines_over_threshold + line_count))
      too_long_files+=("$file ($line_count lines)")
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
  percentage_over_threshold=$(echo "scale=2; ($file_count_over_threshold / $total_count) * 100" | bc)
else
  percentage_over_threshold=0
fi

# ===== print results =====

echo "ℹ️ Total number of files: $total_count files"
echo "ℹ️ Ignored files: $ignored_count"
# To print ignored file paths, uncomment:
# printf '%s\n' "${ignored_list[@]}"

if [ "$file_count_over_threshold" -gt 0 ]; then
  echo "⚠️ Number of files with more than $MAX_LINES lines: $file_count_over_threshold files ($percentage_over_threshold%)"
  echo "⚠️ Average length of files over threshold: $avg_length_over_threshold lines"
  echo
  echo "📜 List of too long files:"
  printf '%s\n' "${too_long_files[@]}"
  exit 1
else
  echo "✅️ No files exceed the max-line threshold of $MAX_LINES lines."
fi
