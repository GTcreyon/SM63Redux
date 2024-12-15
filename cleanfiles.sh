#!/bin/bash

# Check if a directory is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Assign the provided directory to a variable
TARGET_DIR="$1"

# Find and remove all files with the .import extension
find "$TARGET_DIR" -type f -name "*.import" -exec rm -v {} \;

echo "All .import files have been removed from $TARGET_DIR."
