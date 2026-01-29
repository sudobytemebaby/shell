import QtQuick
import Quickshell
import Quickshell.Io

/**
 * MenuManager
 *
 * Central state and logic manager for the menu picker system.
 *
 * ARCHITECTURE:
 * This component implements the Manager pattern, separating state management
 * and business logic from UI presentation (handled by MenuDisplay.qml).
 *
 * RESPONSIBILITIES:
 * - Maintains visibility state and search text
 * - Defines menu items and their commands
 * - Dispatches commands (both shell commands and special picker commands)
 * - Provides IPC interface for external control
 *
 * USAGE:
 * Menu items can have two types of commands:
 * 1. Shell commands: Executed via Quickshell.execDetached
 * 2. Special commands: Trigger other pickers (launcher, emoji, wallpapers, etc.)
 *
 * IPC INTERFACE:
 * - quickshell --ipc menu toggle  # Toggle menu visibility
 * - quickshell --ipc menu open    # Open menu
 * - quickshell --ipc menu close   # Close menu
 */
Scope {
  id: manager

  // ========== VISIBILITY STATE ==========

  // Controls whether the menu picker is visible
  property bool visible: false

  // ========== SEARCH STATE ==========

  // Current search filter text
  property string searchText: ""

  // ========== MANAGER REFERENCES ==========

  // Reference to launcher manager (for the Applications item)
  required property var launcherManager

  // Reference to wallpaper manager (for the Wallpapers item)
  required property var wallpaperManager

  // Reference to power menu manager (for the Power item)
  required property var powerMenuManager

  // Reference to emoji manager (for the Emoji item)
  required property var emojiManager

  // Reference to lockscreen manager (for the Lock item)
  required property var lockscreenManager

  // Reference to theme manager (for the Themes item)
  property var themeManager: null

  // Reference to screenshot manager (for the Screenshot item)
  required property var screenshotManager

  // Reference to screen recording manager (for the Screen Recording item)
  required property var screenRecordingManager

  // Reference to weather manager (for the Weather item)
  required property var weatherManager

  // Reference to matugen manager (for the Matugen item)
  required property var matugenManager

  // ========== ERROR STATE ==========

  // Error message from last failed operation (empty if no error)
  property string errorMessage: ""

  onVisibleChanged: {
    if (visible) {
      searchText = "" // Reset search when opening
      errorMessage = "" // Clear any previous errors
    }
  }

  // ========== MENU ITEMS ==========

  // Menu items with icons, descriptions, and commands
  // Commands can be either shell commands or special picker triggers
  property var menuItems: [
    {
      icon: "󰂯",
      name: "Bluetooth",
      description: "Manage Bluetooth devices",
      command: "foot --app-id floating_term_s -e bluetui"
    },
    {
      icon: "󰤥",
      name: "WiFi",
      description: "Manage WiFi connections",
      command: "foot --app-id floating_term_m -e impala"
    },
    {
      icon: "󱡫",
      name: "Audio",
      description: "Audio mixer and settings",
      command: "foot --app-id floating_term_s -e wiremix"
    },
    {
      icon: "󰀻",
      name: "Applications",
      description: "Launch applications",
      command: "launcher"  // Special command to trigger launcher
    },
    {
      icon: "󱚣",
      name: "Emoji Picker",
      description: "Pick and copy emojis",
      command: "emoji"  // Special command to trigger emoji picker
    },
    {
      icon: "󰸉",
      name: "Wallpapers",
      description: "Change wallpaper",
      command: "wallpapers"  // Special command to trigger wallpaper picker
    },
    {
      icon: "󰏘",
      name: "Themes",
      description: "Apply color scheme from wallpaper",
      command: "matugen"  // Special command to trigger matugen menu
    },
    {
      icon: "󰊕",
      name: "Calculator",
      description: "Calc nums and not only them",
      command: "foot --app-id floating_term_s -e numbat"
    },
    {
      icon: "󰗊",
      name: "Translate",
      description: "Translate using shell",
      command: "foot --app-id floating_term_s"
    },
    {
      icon: "󰹑",
      name: "Screenshot",
      description: "Capture your screen",
      command: "screenshot"  // Special command to trigger screenshot menu
    },
    {
      icon: "󰻂",
      name: "Screen Recording",
      description: "Record your screen",
      command: "screenrec"  // Special command to trigger screen recording menu
    },
    {
      icon: "󰖐",
      name: "Weather",
      description: "View weather information",
      command: "weather"  // Special command to trigger weather overlay
    },
    {
      icon: "󰌾",
      name: "Lock Screen",
      description: "Lock your screen",
      command: "lock"  // Special command to trigger lockscreen
    },
    {
      icon: "󰐥",
      name: "Power",
      description: "Shutdown, reboot, logout...",
      command: "power"  // Special command to trigger power menu
    },
    {
      icon: "",
      name: "Files",
      description: "Browse files with Yazi",
      command: "foot --app-id floating_term_l -e yazi"
    },
    {
      icon: "󱙣",
      name: "System Monitor",
      description: "View system resources",
      command: "foot --app-id floating_term_l -e btop"
    }
  ]

  // ========== COMMAND DISPATCH ==========

  /**
   * Command handlers for special menu items that trigger other pickers
   * instead of executing shell commands.
   *
   * This map-based approach is more maintainable than a long if-else chain
   * and makes it easy to add new special commands.
   *
   * Each handler closes the menu and opens the appropriate picker/manager.
   */
  readonly property var commandHandlers: ({
    "launcher": () => {
      manager.visible = false
      launcherManager.visible = true
    },
    "emoji": () => {
      manager.visible = false
      emojiManager.visible = true
    },
    "wallpapers": () => {
      manager.visible = false
      wallpaperManager.visible = true
    },
    "themes": () => {
      manager.visible = false
      themeManager.visible = true
    },
    "lock": () => {
      manager.visible = false
      lockscreenManager.lock()
    },
    "power": () => {
      manager.visible = false
      powerMenuManager.visible = true
    },
    "screenshot": () => {
      manager.visible = false
      screenshotManager.visible = true
    },
    "screenrec": () => {
      manager.visible = false
      screenRecordingManager.visible = true
    },
    "weather": () => {
      manager.visible = false
      weatherManager.visible = true
    },
    "matugen": () => {
      manager.visible = false
      matugenManager.visible = true
    }
  })

  /**
   * Execute a menu item's command.
   *
   * Checks if the command is a special picker command first (using the
   * commandHandlers map), otherwise executes it as a shell command.
   *
   * @param item - Menu item object with a 'command' property
   */
  function executeItem(item) {
    // Check if this is a special command (picker/manager trigger)
    if (commandHandlers[item.command]) {
      try {
        commandHandlers[item.command]()
        errorMessage = ""
      } catch (error) {
        console.error("[MenuManager] Failed to execute special command:", error)
        errorMessage = `Failed to execute: ${item.name}`
      }
      return
    }

    // Otherwise, execute as a shell command
    try {
      Quickshell.execDetached({
        command: ["sh", "-c", item.command]
      })
      manager.visible = false
      errorMessage = ""
    } catch (error) {
      console.error("[MenuManager] Failed to execute command:", error)
      errorMessage = `Failed to launch: ${item.name}`
    }
  }

  // ========== IPC INTERFACE ==========

  /**
   * IPC handler for external control via quickshell CLI.
   *
   * USAGE:
   * - quickshell --ipc menu toggle  # Toggle menu visibility
   * - quickshell --ipc menu open    # Show menu
   * - quickshell --ipc menu close   # Hide menu
   *
   * This allows the menu to be controlled from scripts, keybindings,
   * or other external sources.
   */
  IpcHandler {
    target: "menu"

    function toggle(): void {
      manager.visible = !manager.visible
    }

    function open(): void {
      manager.visible = true
    }

    function close(): void {
      manager.visible = false
    }
  }
}
