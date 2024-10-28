#!/bin/bash

# Tool Version
VERSION="1.0.0"

# Source the installation path from ~/.comot.sh
if [ -f "$HOME/.comot.sh" ]; then
    source "$HOME/.comot.sh"
else
    echo "Installation path not found. Please reinstall or check your setup."
    exit 1
fi

# Check for special commands and ensure $2 is empty (no other arguments)
if [[ ( "$1" == "-v" || "$1" == "--version" ) && -z "$2" ]]; then
    echo "comot version: $VERSION"
    exit 0
fi

if [[ ( "$1" == "-h" || "$1" == "--help" ) && -z "$2" ]]; then
    echo ""
    cat "$INSTALLATION_PATH/info/help.txt"
    exit 0
fi

if [[ ( "$1" == "-a" || "$1" == "--author" ) && -z "$2" ]]; then
    echo ""
    cat "$INSTALLATION_PATH/info/author.txt"
    exit 0
fi

# Current working directory
TARGET_DIR=$(pwd)

# Supported file types for filtering
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "gif" "bmp" "webp")
VIDEO_EXTENSIONS=("mp4" "avi" "mov" "mkv" "flv" "webm")
AUDIO_EXTENSIONS=("mp3" "wav" "ogg" "flac" "m4a")

# Initialize default variables
COPY_MODE=false
FILE_TYPE="all"
EXT_FILTER=""

# Function to check if the argument is a flag
is_flag() {
    case "$1" in
        -c|-i|-v|-a|-e) return 0 ;;
        *) return 1 ;;
    esac
}

# Parse arguments to handle flags flexibly
args=()  # To collect positional arguments like filenames
while [ "$#" -gt 0 ]; do
    if is_flag "$1"; then
        case "$1" in
            -c)
                COPY_MODE=true
                ;;
            -i)
                FILE_TYPE="images"
                ;;
            -v)
                FILE_TYPE="videos"
                ;;
            -a)
                FILE_TYPE="audio"
                ;;
            -e)
                shift
                EXT_FILTER="$1"
                FILE_TYPE="ext"
                ;;
        esac
    else
        args+=("$1")
    fi
    shift
done

# Extract the positional arguments from the collected 'args' array
FILE_PATTERN="${args[0]}"
TARGET_PATH="${args[1]}"

# Function to search for files matching the pattern and optionally filter by type or extension
search_files() {
    local pattern="$1"
    local file_type="$2"
    local ext_filter="$3"

    case "$file_type" in
        images)
            find "$DOWNLOADS_DIR" -type f -iname "$pattern" \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" \)
            ;;
        videos)
            find "$DOWNLOADS_DIR" -type f -iname "$pattern" \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.mkv" -o -iname "*.flv" -o -iname "*.webm" \)
            ;;
        audio)
            find "$DOWNLOADS_DIR" -type f -iname "$pattern" \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.flac" -o -iname "*.m4a" \)
            ;;
        ext)
            find "$DOWNLOADS_DIR" -type f -iname "$pattern" -iname "*.$ext_filter"
            ;;
        *)
            find "$DOWNLOADS_DIR" -type f -iname "$pattern"
            ;;
    esac
}

# Function to display selection if no wildcard is used
select_file() {
    local pattern="$1"
    local file_type="$2"
    local ext_filter="$3"

    mapfile -t matches < <(search_files "*$pattern*" "$file_type" "$ext_filter")
    
    if [ ${#matches[@]} -eq 0 ]; then
        echo "No matches item found."
        exit 1
    fi

    # Single match found, ask for confirmation
    if [ ${#matches[@]} -eq 1 ]; then
        local single_file="${matches[0]#$DOWNLOADS_DIR/}"  # Strip the Downloads path prefix for display

        # Ask user to confirm the file
        echo "Is this the file you want '$single_file'? (Y/n): "
        read -p '> ' -r confirm
        if [[ "$confirm" =~ ^[Yy]$ || -z "$confirm" ]]; then
            FULL_PATH="${matches[0]}"
            return 0
        else
            echo "Selection canceled."
            exit 1
        fi
    fi

    # Create a relative paths list to display only the path after "Downloads/"
    relative_paths=()
    for file in "${matches[@]}"; do
        relative_paths+=("${file#$DOWNLOADS_DIR/}") # Strip the Downloads path prefix
    done

    echo "Select the file you want (1-${#matches[@]}):"

    PS3="Select file number: "
    select file in "${relative_paths[@]}"; do
        if [ -n "$file" ]; then
            FULL_PATH="$DOWNLOADS_DIR/$file"
            return 0
        else
            echo "Invalid selection."
        fi
    done

    return 1
}

# Ensure a filename or pattern is provided
if [ -z "$FILE_PATTERN" ]; then
    echo "Usage: $0 [-c] [-i|-v|-a|-e <extension>] <filename> [target]"
    exit 1
fi

# Split FILE_PATTERN if it contains '/'
if [[ "$FILE_PATTERN" == */* ]]; then
    IFS='/' read -r -a path_array <<< "$FILE_PATTERN"
    FILE_PATTERN="${path_array[-1]}"  # Last element (the filename)
    
    # Concatenate the directory path with DOWNLOADS_DIR
    for ((i=0; i < ${#path_array[@]}-1; i++)); do
        DOWNLOADS_DIR="$DOWNLOADS_DIR/${path_array[i]}"
    done
fi

# Full path of the file in Downloads directory
FULL_PATH="$DOWNLOADS_DIR/$FILE_PATTERN"

# Check if the exact file exists
if [ -f "$FULL_PATH" ]; then
    matched_files=("$FULL_PATH")
else
    # If wildcard is used, get all matching files
    if [[ "$FILE_PATTERN" == *"*"* ]]; then
        mapfile -t matched_files < <(search_files "$FILE_PATTERN" "$FILE_TYPE" "$EXT_FILTER")

        if [ ${#matched_files[@]} -eq 0 ]; then
            echo "No files found matching the pattern '$FILE_PATTERN' with the filter '$FILE_TYPE'."
            exit 1
        fi
    else
        # No wildcard: prompt user to select a file if none is exactly found
        select_file "$FILE_PATTERN" "$FILE_TYPE" "$EXT_FILTER"
        if [ $? -ne 0 ]; then
            echo "File not found."
            exit 1
        fi
        matched_files=("$FULL_PATH")
    fi
fi

# Determine target directory or file name
for FULL_PATH in "${matched_files[@]}"; do
    if [ -n "$TARGET_PATH" ]; then
        if [[ "$TARGET_PATH" == *.* ]]; then
            # Target is a filename (has an extension), use it as the new name
            FINAL_TARGET="$TARGET_DIR/$TARGET_PATH"
        else
            # Target is a directory (no extension), use the original filename
            FINAL_TARGET="$TARGET_DIR/$TARGET_PATH/$(basename "$FULL_PATH")"
        fi
    else
        # No target provided, move to the current directory with the same name
        FINAL_TARGET="$TARGET_DIR/$(basename "$FULL_PATH")"
    fi

    # Ensure target directory exists
    mkdir -p "$(dirname "$FINAL_TARGET")"

    # Perform the move or copy operation
    if [ "$COPY_MODE" = true ]; then
        cp "$FULL_PATH" "$FINAL_TARGET"
        echo "Copied $(basename "$FULL_PATH") to $FINAL_TARGET"
    else
        mv "$FULL_PATH" "$FINAL_TARGET"
        echo "Moved $(basename "$FULL_PATH") to $FINAL_TARGET"
    fi
done
