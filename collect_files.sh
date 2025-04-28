#!/bin/bash
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 /path/to/source /path/to/target [--max_depth N]"
  exit 1
fi
SOURCE="$1"
TARGET="$2"
shift 2
python3 copy_files.py "$SOURCE" "$TARGET" "$@"
