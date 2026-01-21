#!/usr/bin/env bash
# wallpaper-switcher - Switch wallpaper using hyprpaper
# Usage: wallpaper-switcher <filename>

set -euo pipefail

# Configuration
WALLPAPER_DIR="$HOME/.config/hypr/wpapers"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

# Get filename from argument
FILENAME="${1:-}"

# Validate input
if [[ -z "$FILENAME" ]]; then
    echo "Error: No filename provided" >&2
    echo "Usage: wallpaper-switcher <filename>" >&2
    exit 1
fi

# Construct full path
WALLPAPER_PATH="$WALLPAPER_DIR/$FILENAME"

# Check if file exists
if [[ ! -f "$WALLPAPER_PATH" ]]; then
    echo "Error: Wallpaper not found: $WALLPAPER_PATH" >&2
    exit 1
fi

# Check if hyprpaper is running
if ! pgrep -x hyprpaper >/dev/null 2>&1; then
    echo "Error: hyprpaper is not running" >&2
    exit 1
fi

# Get all monitors
MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

if [[ -z "$MONITORS" ]]; then
    echo "Error: No monitors found" >&2
    exit 1
fi

echo "Switching wallpaper to: $FILENAME"

# Preload the new wallpaper
echo "Preloading wallpaper..."
hyprctl hyprpaper preload "$WALLPAPER_PATH" 2>/dev/null || {
    echo "Warning: Failed to preload wallpaper, it may already be loaded"
}

# Set wallpaper for all monitors
for MONITOR in $MONITORS; do
    echo "Setting wallpaper for monitor: $MONITOR"
    hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER_PATH" 2>/dev/null || {
        echo "Warning: Failed to set wallpaper for $MONITOR" >&2
    }
done

# Update hyprpaper.conf to persist the change
echo "Updating hyprpaper.conf..."
if [[ -f "$HYPRPAPER_CONF" ]]; then
    # Backup the config
    cp "$HYPRPAPER_CONF" "$HYPRPAPER_CONF.bak"
    
    # Update the path line for all monitors
    sed -i "s|path = .*|path = $WALLPAPER_PATH|g" "$HYPRPAPER_CONF"
    
    echo "Wallpaper changed successfully!"
else
    echo "Warning: hyprpaper.conf not found, wallpaper will not persist" >&2
fi

exit 0
