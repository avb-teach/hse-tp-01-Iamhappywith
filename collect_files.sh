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

        relative_path="${file#$source/}"
        relative_dir=$(dirname "$relative_path")
        mkdir -p "$target/$relative_dir"
        
        cp "$file" "$target/$relative_path"
    done < <(find "$source" -type f -print0)
    
    if [ -n "$max_depth" ]; then
        while IFS= read -r -d '' dir; do
            [ "$dir" = "$source" ] && continue
            
            ap=$(dirname "$dir")
            current_depth=$(echo "$dir" | tr -cd '/' | wc -c)
            current_depth=$((current_depth - base_depth))
            
            if [ "$current_depth" -lt "$max_depth" ]; then
                relative_path="${dir#$source/}"
                mkdir -p "$target/$relative_path"
            fi
        done < <(find "$source" -type d -print0)
    fi
}

declare -A total
declare -A reps

source="$1"
target="$2"

max_depth=""
for arg in "$@"; do
    if [[ "$arg" == "-=max_depth"* ]]; then
        max_depth="${arg#*=}"
    fi
done

copy_files "$source" "$target" "$max_depth"

