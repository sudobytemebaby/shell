# Matugen Color Scheme Menu

A QuickShell component for applying Material 3 color schemes from your current wallpaper using [matugen](https://github.com/InioX/matugen).

## Features

- 🎨 **9 Color Schemes**: Choose from Content, Expressive, Fidelity, Fruit Salad, Monochrome, Neutral, Rainbow, Tonal Spot, and Vibrant
- 🖼️ **Auto Wallpaper Detection**: Automatically reads current wallpaper from cache
- 🌓 **Light/Dark Mode Toggle**: Switch between light and dark themes with a single click
- 🔔 **Smart Notifications**: Get instant feedback on successful applications or errors
- ⌨️ **Keyboard Navigation**: Navigate with arrow keys, Tab, and Shift+Tab
- 🎯 **Simple Controls**: Enter to apply, Escape to close
- 🎭 **Material 3 Design**: Follows your existing design patterns with smooth animations
- 🔌 **IPC Interface**: Control via hyprctl or quickshell CLI

## Architecture

Follows the **Manager-Display Pattern**:
- `MatugenManager.qml` - State management and business logic
- `MatugenDisplay.qml` - UI presentation layer

### Components

#### MatugenManager.qml
- Reads current wallpaper path from `~/.cache/quickshell/current-wallpaper`
- Defines 9 color scheme options
- Executes matugen commands via ProcessUtils
- Provides IPC interface

#### MatugenDisplay.qml
- Full-screen overlay with 3x3 grid layout
- Keyboard navigation and shortcuts
- Material 3 styling with tertiary color highlighting
- LazyLoader for performance

## Usage

### Via IPC

```bash
# Toggle menu
quickshell --ipc matugen toggle
hyprctl dispatch ipc matugen:toggle

# Open menu
quickshell --ipc matugen open

# Close menu
quickshell --ipc matugen close

# Toggle light/dark mode
quickshell --ipc matugen toggleMode
hyprctl dispatch ipc matugen:toggleMode
```

### Via Central Menu

Open the menu picker and select **"Matugen Colors"**

### Keyboard Shortcuts

When the menu is open:
- **Arrow Keys** - Navigate between schemes (Up/Down/Left/Right)
- **Tab** - Move to next scheme
- **Shift+Tab** - Move to previous scheme
- **Enter** - Apply selected scheme
- **Escape** - Close menu

## Color Schemes

Each scheme provides different color extraction characteristics:

| Scheme | Description |
|--------|-------------|
| **Content** | Content-based color extraction from the wallpaper |
| **Expressive** | Vibrant and expressive colors with high saturation |
| **Fidelity** | High color fidelity to the source image |
| **Fruit Salad** | Playful mix of colors across the spectrum |
| **Monochrome** | Grayscale palette for minimal aesthetics |
| **Neutral** | Balanced neutral colors for subtle themes |
| **Rainbow** | Full spectrum colors with variety |
| **Tonal Spot** | Subtle tonal variations from key colors |
| **Vibrant** | Bold and vibrant colors with energy |

## Light/Dark Mode Toggle

The menu includes a built-in light/dark mode toggle at the top. This feature works seamlessly with matugen templates that use "default" values.

### How It Works

- **Dark Mode** (default): Generates colors for dark themes
- **Light Mode**: Adds the `-light` flag to matugen, generating colors for light themes

The toggle button is a pill-shaped switcher with moon (󰖔) and sun (󰖙) icons. Click either side to switch modes, then apply any color scheme.

### Command Difference

```bash
# Dark mode (default)
matugen image <wallpaper> -t <scheme> -v

# Light mode
matugen image <wallpaper> -t <scheme> -v -light
```

### Via IPC

You can toggle the mode programmatically:
```bash
quickshell --ipc matugen toggleMode
```

This is useful for binding to hotkeys or creating automation scripts.

### Template Compatibility

This feature requires your matugen templates to use "default" color values rather than hardcoded light/dark variants. The `-light` flag tells matugen to generate the appropriate color variants automatically.

## Notifications

The component sends desktop notifications to provide feedback on color scheme applications:

### Success Notifications

When a color scheme is successfully applied:
- **Title**: "Matugen Color Scheme"
- **Message**: "{Scheme Name} scheme applied ({Light/Dark} mode)"
- **Icon**: Color preferences icon
- **Urgency**: Normal

Example: *"Neutral scheme applied (Dark mode)"*

### Error Notifications

When a color scheme fails to apply:
- **Title**: "Matugen Error"
- **Message**: "Failed to apply {Scheme Name} scheme"
- **Icon**: Error dialog icon
- **Urgency**: Critical

Example: *"Failed to apply Vibrant scheme"*

### Requirements

Notifications use the standard `notify-send` command, which is typically available on most Linux distributions with a desktop environment.

## Integration

The component is integrated into the shell via `shell.qml`:

```qml
// Manager instantiation
MatugenManager {
  id: matugenManager
}

MatugenDisplay {
  manager: matugenManager
}

// Menu integration
MenuManager {
  id: menuManager
  // ... other managers
  matugenManager: matugenManager
}
```

## Dependencies

- **matugen**: Must be installed and available in PATH
- **wallpaper-switcher**: Must maintain wallpaper path in `~/.cache/quickshell/current-wallpaper`
- **notify-send**: Required for desktop notifications (typically pre-installed)

## Command Format

The component executes matugen with the following format:

```bash
# Dark mode (default)
matugen image <wallpaper_path> -t <scheme> -v

# Light mode
matugen image <wallpaper_path> -t <scheme> -v -light
```

Examples:
```bash
# Dark mode
matugen image ~/.config/hypr/wpapers/nord_space.png -t scheme-neutral -v

# Light mode
matugen image ~/.config/hypr/wpapers/nord_space.png -t scheme-neutral -v -light
```

## Error Handling

- Validates wallpaper path exists before execution
- Refreshes wallpaper path when menu opens
- Logs all operations to console with `[MatugenManager]` prefix
- Gracefully handles missing wallpaper cache file

## File Structure

```
features/session/matugen/
├── MatugenManager.qml    # State and logic (363 lines)
├── MatugenDisplay.qml    # UI presentation (528 lines)
└── README.md             # This file
```

## Customization

### Adding New Schemes

To add a new color scheme:

1. Add entry to `colorSchemes` array in `MatugenManager.qml`:
```qml
{
  icon: "󰏘",
  name: "My Scheme",
  description: "Custom description",
  scheme: "scheme-custom"
}
```

2. The scheme will automatically be available for navigation via arrow keys and Tab

### Changing Grid Layout

The current layout is 3x3 (9 schemes). To change:

1. Update `columns` in GridLayout in `MatugenDisplay.qml`
2. Adjust container dimensions (width/height)
3. Update arrow key navigation logic for new row count

## Best Practices

- **Wallpaper First**: Set your wallpaper before applying color schemes
- **Test Schemes**: Different schemes work better with different wallpapers
- **System Reload**: Some applications may need restart to apply new colors
- **Consistent Source**: Always uses current wallpaper, ensuring color consistency

## Troubleshooting

### Menu doesn't open
- Check matugen is installed: `which matugen`
- Verify IPC is working: `quickshell --ipc matugen toggle`

### Colors not applying
- Check wallpaper cache exists: `cat ~/.cache/quickshell/current-wallpaper`
- Verify matugen executes: `matugen image <path> -t scheme-neutral -v`
- Check logs: Look for `[MatugenManager]` console messages

### Wrong wallpaper used
- Wallpaper cache may be stale
- Set wallpaper again using wallpaper-switcher
- Check cache file updates: `ls -la ~/.cache/quickshell/current-wallpaper`

## Future Enhancements

Potential improvements:
- [ ] Preview mode showing color palette before applying
- [ ] Recently used schemes quick access
- [ ] Live wallpaper preview in menu
- [ ] Scheme comparison view
- [ ] Undo/redo scheme changes
- [ ] Favorite schemes bookmarking
