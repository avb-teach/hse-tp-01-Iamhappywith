#!/bin/bash

copy_files() {
    local source=$(realpath "$1")
    local target=$(realpath "$2")
    local max_depth="$3"

    mkdir -p "$target"
    
    local base_depth=$(echo "$source" | tr -cd '/' | wc -c)
    
    # Обработка файлов
    while IFS= read -r -d '' file; do
        local dir_path=$(dirname "$file")
        local current_depth=$(echo "$dir_path" | tr -cd '/' | wc -c)
        current_depth=$((current_depth - base_depth))

        # Файлы копируем, если глубина их директории < max_depth
        if [ -n "$max_depth" ] && [ "$current_depth" -ge "$max_depth" ]; then
            continue
        fi
        
        local filename=$(basename "$file")
        local base="${filename%.*}"
        local ext="${filename##*.}"
        local original_name="$filename"
        
        # Разрешение конфликтов имен
        while [[ -n "${total[$filename]}" ]]; do
            reps[$original_name]=$((reps[$original_name] + 1))
            filename="${base}_${reps[$original_name]}.$ext"
        done
        
        total[$filename]=1
        
        # Копирование файла
        local relative_path="${file#$source/}"
        mkdir -p "$target/$(dirname "$relative_path")"
        cp -n "$file" "$target/$relative_path"
    done < <(find "$source" -type f -print0)
    
    # Создание директорий до max_depth включительно
    if [ -n "$max_depth" ]; then
        while IFS= read -r -d '' dir; do
            [ "$dir" = "$source" ] && continue
            
            local parent_dir=$(dirname "$dir")
            local current_depth=$(echo "$parent_dir" | tr -cd '/' | wc -c)
            current_depth=$((current_depth - base_depth))
            
            # Создаем директории, если их глубина < max_depth
            if [ "$current_depth" -lt "$max_depth" ]; then
                local relative_path="${dir#$source/}"
                mkdir -p "$target/$relative_path"
            fi
        done < <(find "$source" -type d -print0)
    fi
}

declare -A total
declare -A reps

# Парсинг аргументов
source=""
target=""
max_depth=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -=max_depth)
            max_depth="$2"
            shift 2
            ;;
        *)
            if [ -z "$source" ]; then
                source="$1"
            else
                target="$1"
            fi
            shift
            ;;
    esac
done

[ -z "$source" ] || [ -z "$target" ] && {
    echo "Usage: $0 input_dir output_dir [-=max_depth depth]"
    exit 1
}

copy_files "$source" "$target" "$max_depth"
