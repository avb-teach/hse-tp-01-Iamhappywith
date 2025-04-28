#!/bin/bash

copy_files() {
    source="$1"
    target="$2"
    max_depth="$3"

    mkdir -p "$target"
    
    base_depth=$(echo "$source" | tr -cd '/' | wc -c)
    
    while IFS= read -r -d '' file; do
        ap=$(dirname "$file")
        current_depth=$(echo "$ap" | tr -cd '/' | wc -c)
        current_depth=$((current_depth - base_depth))
        
        if [ -n "$max_depth" ] && [ "$current_depth" -ge "$max_depth" ]; then
            continue
        fi
        
        filename=$(basename "$file")
        base="${filename%.*}"
        ext="${filename##*.}"
        original_name="$filename"
        
        while [[ -n "${total[$filename]}" ]]; do
            reps[$original_name]=$((reps[$original_name] + 1))
            filename="${base}_${reps[$original_name]}.$ext"
        done
        
        total[$filename]=1
        cp "$file" "$target/$filename"
    done < <(find "$source" -type f -print0)
}

declare -A total
declare -A reps

source="$1"
target="$2"
max_depth="$4"

copy_files "$source" "$target" "$max_depth"
