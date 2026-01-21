#!/usr/bin/env bash
# Emoji Picker Script
# Copies emoji to clipboard and shows notification
set -euo pipefail

# Get emoji from argument
EMOJI="${1:-}"

# Check if emoji provided
if [[ -z "$EMOJI" ]]; then
    echo "Usage: emoji-picker <emoji>" >&2
    exit 1
fi

# Check dependencies
if ! command -v wl-copy >/dev/null 2>&1; then
    notify-send -u critical "Emoji Picker" "wl-copy not found. Please install wl-clipboard."
    exit 1
fi

# Copy to clipboard
echo -n "$EMOJI" | wl-copy

# Show notification
if command -v notify-send >/dev/null 2>&1; then
    notify-send -u low "Emoji Copied" "$EMOJI"
fi

exit 0
