#!/bin/bash
# wallpaper-thumbgen - Generate thumbnails for wallpaper picker
# This script creates optimized thumbnails to improve loading performance

WALLPAPER_DIR="$HOME/.config/hypr/wpapers"
THUMB_DIR="$HOME/.cache/quickshell/wallpaper-thumbs"
THUMB_WIDTH=280
THUMB_HEIGHT=200

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick (convert) is not installed${NC}" >&2
    echo "Install with: sudo pacman -S imagemagick" >&2
    exit 1
fi

# Create thumbnail directory if it doesn't exist
mkdir -p "$THUMB_DIR"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo -e "${RED}Error: Wallpaper directory not found: $WALLPAPER_DIR${NC}" >&2
    exit 1
fi

echo -e "${BLUE}[Thumbnail Generator]${NC} Starting..."
echo -e "${BLUE}[Thumbnail Generator]${NC} Source: $WALLPAPER_DIR"
echo -e "${BLUE}[Thumbnail Generator]${NC} Output: $THUMB_DIR"
echo -e "${BLUE}[Thumbnail Generator]${NC} Size: ${THUMB_WIDTH}x${THUMB_HEIGHT}"

# Count wallpapers
TOTAL_IMAGES=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | wc -l)

if [ "$TOTAL_IMAGES" -eq 0 ]; then
    echo -e "${YELLOW}[Thumbnail Generator]${NC} No wallpapers found"
    exit 0
fi

echo -e "${BLUE}[Thumbnail Generator]${NC} Found $TOTAL_IMAGES wallpapers"

# Generate thumbnails
GENERATED=0
SKIPPED=0
FAILED=0

for img in "$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp}; do
    # Skip if glob didn't match
    [ -f "$img" ] || continue
    
    # Get filename and create thumbnail path
    filename=$(basename "$img")
    base_name="${filename%.*}"
    thumb="$THUMB_DIR/${base_name}.jpg"
    
    # Check if thumbnail already exists and is newer than source
    if [ -f "$thumb" ] && [ "$thumb" -nt "$img" ]; then
        ((SKIPPED++))
        continue
    fi
    
    # Generate thumbnail
    echo -e "${BLUE}[Thumbnail Generator]${NC} Generating: $filename"
    
    if convert "$img" \
        -resize "${THUMB_WIDTH}x${THUMB_HEIGHT}^" \
        -gravity center \
        -extent "${THUMB_WIDTH}x${THUMB_HEIGHT}" \
        -quality 85 \
        -strip \
        "$thumb" 2>/dev/null; then
        ((GENERATED++))
    else
        echo -e "${RED}[Thumbnail Generator]${NC} Failed: $filename" >&2
        ((FAILED++))
    fi
done

# Summary
echo ""
echo -e "${GREEN}[Thumbnail Generator]${NC} Complete!"
echo -e "${GREEN}[Thumbnail Generator]${NC} Generated: $GENERATED"
echo -e "${YELLOW}[Thumbnail Generator]${NC} Skipped: $SKIPPED (already up-to-date)"

if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}[Thumbnail Generator]${NC} Failed: $FAILED"
fi

exit 0
