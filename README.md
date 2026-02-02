# Quickshell Configuration

A Wayland desktop shell built with Quickshell (Qt/QML). Features a macOS-inspired status bar, application launcher, notification system, and various system controls.

## Features

### Core Components

- **Dynamic Status Bar** - Minimal top bar with workspaces, system indicators, and controls
- **Application Launcher** - Search and launch desktop applications with keyboard navigation
- **Notification System** - Popup notifications with persistent notification center
- **Control Center** - Quick access to volume, brightness, WiFi, Bluetooth, night mode
- **Calendar Widget** - Date/time display with monthly calendar view
- **Lockscreen** - Password-protected lockscreen with media controls and status indicators
- **OSD Popups** - On-screen display for volume, brightness, and microphone changes

### Additional Features

- **Emoji Picker** - Categorized emoji selector with search
- **Wallpaper Selector** - Grid-based wallpaper browser with thumbnails
- **Weather Widget** - Current conditions, hourly and weekly forecasts (Open-Meteo API)
- **Power Menu** - Logout, shutdown, reboot, suspend options
- **Screenshot Tool** - Screen capture with region selection
- **Screen Recording** - Record screen activity
- **Theme Generator** - Matugen color scheme generation via Matugen

### System Integration

- **Volume Control** - PipeWire integration with device detection (speakers/headphones)
- **Brightness Control** - Automatic backlight device detection
- **Battery Monitoring** - Low battery notifications with configurable thresholds
- **Network Status** - WiFi connection monitoring
- **Bluetooth Status** - Bluetooth device tracking
- **Media Controls** - MPRIS integration for media player control
- **Keyboard Layout** - Display current keyboard layout

## Requirements

- **Quickshell** - The shell framework (Wayland)
- **Qt 6** - QML runtime
- **PipeWire** - Audio management
- **brightnessctl** - Brightness control
- **UPower** - Battery information

### Optional Dependencies

- **matugen** - Theme color generation
- **slurp** - Screenshot region selection
- **grim** - Screenshot capture
- **wf-recorder** - Screen recording

## Installation

1. Clone this repository to `~/.config/quickshell/`:

```bash
git clone github.com/sudobytemebaby/shell ~/.config/quickshell
```

2. Install dependencies for your distribution

3. Start Quickshell:

```bash
quickshell
```

## Configuration

### Weather Location

Edit `core/services/WeatherService.qml`:

```qml
property string city: "YourCity"
property real lat: 12.3456
property real lon: 78.9012
```

### Battery Notification Thresholds

Edit `core/services/BatteryNotifier.qml`:

```qml
property real lowBatteryThreshold: 0.20      // 20%
property real criticalBatteryThreshold: 0.10  // 10%
property real emergencyBatteryThreshold: 0.05 // 5%
```

### Theme Colors

The theme uses Material Design 3 tokens defined in `shared/theme/Theme.qml`. Colors can be generated dynamically using the Matugen integration, or edited manually in the theme file.

## IPC Commands

Control the shell from command line or keybindings:

### Bar

```bash
quickshell --ipc bar toggle    # Toggle bar visibility
quickshell --ipc bar show      # Show bar
quickshell --ipc bar hide      # Hide bar
```

### Application Launcher

```bash
quickshell --ipc launcher toggle
quickshell --ipc launcher open
quickshell --ipc launcher close
```

### Control Center

```bash
quickshell --ipc controlcenter toggle
quickshell --ipc controlcenter open
quickshell --ipc controlcenter close
```

### Calendar

```bash
quickshell --ipc calendar toggle
quickshell --ipc calendar open
quickshell --ipc calendar close
```

### Notification Center

```bash
quickshell --ipc notificationcenter toggle
quickshell --ipc notificationcenter open
quickshell --ipc notificationcenter close
```

### Lockscreen

```bash
quickshell --ipc lockscreen lock
quickshell --ipc lockscreen unlock
quickshell --ipc lockscreen toggle
```

### Power Menu

```bash
quickshell --ipc powermenu toggle
quickshell --ipc powermenu open
quickshell --ipc powermenu close
```

### Menu (Sidebar)

```bash
quickshell --ipc menu toggle
quickshell --ipc menu open
quickshell --ipc menu close
```

### Wallpaper Selector

```bash
quickshell --ipc wallpaper toggle
quickshell --ipc wallpaper open
quickshell --ipc wallpaper close
```

### Emoji Picker

```bash
quickshell --ipc emoji toggle
quickshell --ipc emoji open
quickshell --ipc emoji close
```

### Weather Widget

```bash
quickshell --ipc weather toggle
quickshell --ipc weather show
quickshell --ipc weather hide
quickshell --ipc weather refresh  # Fetch fresh data
```

### Screenshot

```bash
quickshell --ipc screenshot region    # Capture selected region
quickshell --ipc screenshot full      # Capture full screen
```

### Screen Recording

```bash
quickshell --ipc screenrec start
quickshell --ipc screenrec stop
quickshell --ipc screenrec toggle
```

### Matugen Theme

```bash
quickshell --ipc matugen toggle
quickshell --ipc matugen open
quickshell --ipc matugen close
```

## Keyboard Navigation

Most interfaces support keyboard navigation:

- **Arrow Keys** - Navigate through items
- **Ctrl+P / Ctrl+N** - Navigate up/down (Emacs-style)
- **Tab / Shift+Tab** - Navigate forward/backward
- **Home / End** - Jump to first/last item
- **Enter** - Select current item
- **Escape** - Close interface
- **Type to search** - Filter items in real-time

### Grid Navigation

For grid-based interfaces (wallpaper, emoji):

- **Arrow Keys** - Navigate in all directions
- **Left/Right** - Move between columns
- **Up/Down** - Move between rows

## Project Structure

```
.
├── shell.qml                    # Main entry point
├── core/                        # System-level services
│   ├── services/               # Singleton services
│   │   ├── BatteryNotifier.qml
│   │   ├── WeatherService.qml
│   │   └── ImageCacheService.qml
│   ├── system_state/           # Centralized state management
│   │   ├── SystemStateManager.qml
│   │   └── system_state/       # Individual state modules
│   │       ├── Battery.qml
│   │       ├── Volume.qml
│   │       ├── Brightness.qml
│   │       ├── Network.qml
│   │       ├── Bluetooth.qml
│   │       ├── KeyboardLayout.qml
│   │       └── Mpris.qml
│   ├── scripts/                # Shell integration scripts
│   └── helpers/                # Utility functions
├── features/                    # User-facing features
│   ├── shell_chrome/           # Status bar and OSD
│   │   ├── bar/
│   │   └── osd/
│   ├── launchers/              # Application launcher, wallpaper, emoji
│   │   ├── launcher/
│   │   ├── wallpaper/
│   │   ├── emoji/
│   │   └── menu/
│   ├── system_panels/          # Control center and calendar
│   │   ├── controlcenter/
│   │   └── calendar/
│   ├── notifications/          # Notification system
│   ├── session/                # Session management
│   │   ├── lockscreen/
│   │   ├── powermenu/
│   │   ├── screenshot/
│   │   ├── screenrec/
│   │   └── matugen/
│   └── weather/                # Weather widget
└── shared/                      # Reusable components
    ├── components/             # UI component library
    │   ├── Buttons/
    │   ├── Cards/
    │   ├── Display/
    │   ├── Input/
    │   ├── Lists/
    │   ├── Modals/
    │   ├── Navigation/
    │   ├── Sliders/
    │   └── Utils/
    ├── shaders/                # GLSL shaders
    └── theme/                  # Material Design 3 theme
```

## Architecture

### Manager-Display Pattern

Each feature is split into two components:

- **Manager** - Handles state, logic, and IPC interface
- **Display** - Handles UI presentation and user interaction

This separation keeps code clean and makes it easy to modify UI without touching business logic.

### System State Management

`SystemStateManager` serves as a single source of truth for system state. All modules (Battery, Volume, Brightness, etc.) are centralized here and referenced throughout the application. This prevents duplicate state and eliminates race conditions.

### Lazy Loading

Heavy components use Qt's `Loader` with conditional activation. They're only instantiated when visible and destroyed when closed, keeping memory usage low.

## Theme System

Uses Material Design 3 with:

- Semantic color tokens (primary, secondary, tertiary, surface)
- 5-level elevation system
- Transparent variants for blur effects
- Consistent spacing and typography scales
- Component-specific design tokens

Colors can be generated dynamically from wallpapers using Matugen integration.

## Contributing

This is a personal configuration, but feel free to fork and adapt it for your own use. If you find bugs or have suggestions, open an issue.

## License

MIT

## Credits

Built with [Quickshell](https://github.com/outfoxxed/quickshell) - a QtQuick-based Wayland compositor toolkit.
