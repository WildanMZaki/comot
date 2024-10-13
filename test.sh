#!/bin/bash

# Directory where the test files will be created
SOURCE_DIR="$HOME/Downloads/comot-test"
TARGET_DIR="target"

# Create test directories if they don't exist
mkdir -p "$SOURCE_DIR"
mkdir -p "$TARGET_DIR/assets/images"
mkdir -p "$TARGET_DIR/assets/videos"
mkdir -p "$TARGET_DIR/audios"
mkdir -p "$TARGET_DIR/docs"

# Create various test files for images, videos, audio, and PDFs
echo "Creating test files in $SOURCE_DIR..."
touch "$SOURCE_DIR/cat.png" "$SOURCE_DIR/cat-1.jpg" "$SOURCE_DIR/cat-2.webp"
touch "$SOURCE_DIR/vid-1.mp4" "$SOURCE_DIR/vid-2.avi"
touch "$SOURCE_DIR/music-1.mp3" "$SOURCE_DIR/music-2.wav"
touch "$SOURCE_DIR/report-1.pdf" "$SOURCE_DIR/report-2.txt"
echo "Test files created!"

# Test case 1: Move an exact file match
echo "Test 1: Moving an exact file match"
comot "comot-test/cat.png" "$TARGET_DIR/assets/images"
echo "----------------------------------"

# Test case 2: Move all image files matching 'cat*'
echo "Test 2: Moving all image files matching 'cat*'"
comot -i "comot-test/cat*" -c "$TARGET_DIR/assets/images"
echo "----------------------------------"

# Test case 3: Move all video files matching 'vid*'
echo "Test 3: Moving all video files matching 'vid*'"
comot -v "comot-test/vid*" "$TARGET_DIR/assets/videos"
echo "----------------------------------"

# Test case 4: Copy all audio files matching 'music*'
echo "Test 4: Copying all audio files matching 'music*'"
comot -c -a "comot-test/music*" "$TARGET_DIR/audios"
echo "----------------------------------"

# Test case 5: Copy all PDF files matching 'report*'
echo "Test 5: Copying all PDF files matching 'report*'"
comot -c "comot-test/report*" "$TARGET_DIR/docs" -e pdf
echo "----------------------------------"

# Test case 6: Move files with a similar name (prompt selection)
echo "Test 6: Prompt selection for files with similar names"
comot "comot-test/cat" "$TARGET_DIR/assets/images"
echo "----------------------------------"

