# Wallpaper State Management

## Overview

The wallpaper system now maintains a state file with the current wallpaper path for easy integration with external tools like matugen and for the lockscreen to display the actual wallpaper.

## State File Location

```
~/.cache/quickshell/current-wallpaper
```

**Format:** Single line containing the absolute path to the current wallpaper
**Example:** `/home/user/.config/hypr/wpapers/nord_space.png`

## How It Works

### 1. Wallpaper Switching

When you switch wallpaper via the picker or wallpaper-switcher script:

1. **wallpaper-switcher** script executes
2. Sets wallpaper via hyprctl
3. Updates `hyprpaper.conf`
4. **Writes path to state file** (`~/.cache/quickshell/current-wallpaper`)

### 2. Lockscreen Integration

The lockscreen now displays your actual wallpaper (blurred) instead of a screenshot:

- Reads from `~/.cache/quickshell/current-wallpaper`
- Loads the image directly
- Applies blur and desaturation for text contrast
- Fallback to solid color if file doesn't exist

**Component:** `lockscreen_components/WallpaperBackground.qml`

### 3. WallpaperManager Properties

**New properties:**
- `currentWallpaperPath: string` - Full path to current wallpaper
- `currentWallpaper: string` - Filename only (existing)

The manager automatically:
- Loads wallpaper path on startup
- Updates path when wallpaper is changed
- Syncs with state file

## Matugen Integration

### Quick Usage

```bash
# Generate theme from current wallpaper
matugen-update

# With custom matugen options
matugen-update --mode dark --contrast 0.5
```

### Manual Usage

```bash
# Read current wallpaper
WALLPAPER=$(cat ~/.cache/quickshell/current-wallpaper)

# Generate theme
matugen image "$WALLPAPER"
```

## Files Modified

### Scripts
- `~/.local/bin/wallpaper-switcher` - Now writes state file
- `~/.local/bin/matugen-update` - New helper script

### QML Components
- `WallpaperManager.qml` - Added state file reading/writing
- `lockscreen_components/WallpaperBackground.qml` - New component
- `LockscreenDisplay.qml` - Uses WallpaperBackground instead of BlurredBackground

## Benefits

✅ **Decoupled:** State file is independent of hyprpaper config format
✅ **Simple:** Single line, easy to parse by any tool
✅ **Fast:** No parsing needed, just read the file
✅ **Reliable:** Written atomically by bash script
✅ **Matugen-ready:** Direct path to image file
✅ **Lockscreen:** Shows actual wallpaper instead of screenshot

## Noctalia Comparison

**Noctalia approach:**
- Uses settings service to store wallpaper path
- Lockscreen reads from settings
- Integrated with their config system

**Your approach:**
- Uses simple state file (more portable)
- Lockscreen reads from state file
- Works independently of any config system
- Easier to integrate with external tools (matugen, scripts, etc.)

Both approaches achieve the same result - your implementation is simpler and more Unix-like!
