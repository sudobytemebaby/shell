#!/usr/bin/env bash

# Get active keymaps from all keyboards
layouts=$(hyprctl -j devices 2>/dev/null | jq -r '.keyboards[]?.active_keymap' | grep -v '^null$')

if [ -z "$layouts" ]; then
    echo "KB|Unknown"
    exit 0
fi

# Prefer Russian if present (useful with kanata remapping)
if echo "$layouts" | grep -qi "Russian"; then
    current="Russian"
elif echo "$layouts" | grep -qi "English"; then
    current="English (US)"
else
    # Take first available layout if we don't recognize it
    current=$(echo "$layouts" | head -n 1)
fi

case "$current" in
    *Russian*|*russian*)
        lang="Русский"
        ;;
    *English*|*english*|*US*)
        lang="English(US)"
        ;;
    *)
        lang="${current:0:12}"  # limit length + cut strange long names
        ;;
esac

echo "KB|$lang"
