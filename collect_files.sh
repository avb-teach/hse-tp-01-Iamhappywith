#!/bin/bash
if [ "$1" = "--python" ]; then
    exec python3 - "$@" <<'EOF_PYTHON'
import argparse
import os
import shutil
from collections import defaultdict

def copy_files(source, target, max_depth=None):
    if not os.path.exists(target):
        os.makedirs(target)
    total = set()
    reps = defaultdict(int)

    source = os.path.abspath(source)
    target = os.path.abspath(target)
    base_depth = source.rstrip(os.sep).count(os.sep)

    for ap, dirs, files in os.walk(source):
        current_depth = ap.rstrip(os.sep).count(os.sep) - base_depth
        if max_depth is not None and current_depth >= max_depth:
            dirs[:] = []

        for file in files:
            source_file = os.path.join(ap, file)
            base, ext = os.path.splitext(file)
            original_name = file
            while file in total:
                reps[original_name] += 1
                file = f"{base}_{reps[original_name]}{ext}"

            total.add(file)
            target_file = os.path.join(target, file)
            shutil.copy2(source_file, target_file)
            print(f"Copied: {source_file} -> {target_file}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="File copy tool")
    parser.add_argument("source", help="Source directory")
    parser.add_argument("target", help="Target directory")
    parser.add_argument("--max_depth", type=int, help="Maximum depth")
    args = parser.parse_args()
    copy_files(args.source, args.target, args.max_depth)
EOF_PYTHON
else
    if [ "$#" -lt 2 ]; then
        echo "Usage: $0 source_dir target_dir [--max_depth N]"
        exit 1
    fi

    if ! command -v python3 &> /dev/null; then
        echo "Error: Python 3 is required" >&2
        exit 1
    fi

    exec "$0" --python "$@"
fi
