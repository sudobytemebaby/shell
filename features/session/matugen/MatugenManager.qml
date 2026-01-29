import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core/system_state" as Core

/**
 * MatugenManager - State management and business logic for the matugen color scheme menu
 *
 * This component handles:
 * - Color scheme option definitions (schemes, icons, descriptions)
 * - Current wallpaper path detection from cache
 * - Light/dark mode toggle for theme switching
 * - Matugen command execution with selected scheme and mode
 * - Desktop notifications for success/error feedback
 * - IPC interface for external control (hyprctl dispatch)
 * - Visibility state management
 *
 * Architecture:
 * - Follows the Manager pattern (state + logic)
 * - MatugenDisplay handles presentation
 * - Commands executed via Core.ProcessUtils for safety
 * - Wallpaper path read from ~/.cache/quickshell/current-wallpaper
 * - Light mode adds -light flag to matugen command
 * - Notifications sent via notify-send
 *
 * IPC Interface:
 * - matugen:toggle()     - Toggle menu visibility
 * - matugen:open()       - Open menu
 * - matugen:close()      - Close menu
 * - matugen:toggleMode() - Toggle light/dark mode
 *
 * Usage example:
 * hyprctl dispatch ipc matugen:toggle
 * quickshell --ipc matugen open
 * quickshell --ipc matugen toggleMode
 */

Scope {
  id: manager

  // ========================================================================
  // STATE
  // ========================================================================

  property bool visible: false           // Menu visibility state
  property string currentWallpaperPath: "" // Full path to current wallpaper
  property bool isLoadingWallpaper: false  // True while reading wallpaper path
  property bool lightMode: false         // Light mode flag (false = dark mode, true = light mode)

  // ========================================================================
  // COLOR SCHEME OPTIONS CONFIGURATION
  // ========================================================================

  /**
   * Matugen color scheme options array
   * Each option defines:
   * - icon: Nerd Font icon representing the scheme
   * - name: Display name of the scheme
   * - description: Short description of the color scheme characteristics
   * - scheme: Matugen scheme identifier (command line argument)
   *
   * Order matters: Matches grid layout (left-to-right, top-to-bottom)
   * Navigate using arrow keys or Tab/Shift+Tab
   *
   * Available schemes from matugen:
   * - scheme-content: Content-based color extraction
   * - scheme-expressive: Vibrant and expressive colors
   * - scheme-fidelity: High color fidelity to source
   * - scheme-fruit-salad: Playful mix of colors
   * - scheme-monochrome: Grayscale color palette
   * - scheme-neutral: Balanced neutral colors
   * - scheme-rainbow: Full spectrum colors
   * - scheme-tonal-spot: Subtle tonal variations
   * - scheme-vibrant: Bold vibrant colors
   */
  property var colorSchemes: [
    {
      icon: "",
      name: "Content",
      description: "Content-based extraction",
      scheme: "scheme-content"
    },
    {
      icon: "󱝁",
      name: "Expressive",
      description: "Vibrant and expressive",
      scheme: "scheme-expressive"
    },
    {
      icon: "󰆗",
      name: "Fidelity",
      description: "High color fidelity",
      scheme: "scheme-fidelity"
    },
    {
      icon: "󱁃",
      name: "Fruit Salad",
      description: "Playful color mix",
      scheme: "scheme-fruit-salad"
    },
    {
      icon: "󰊠",
      name: "Monochrome",
      description: "Grayscale palette",
      scheme: "scheme-monochrome"
    },
    {
      icon: "󰔙",
      name: "Neutral",
      description: "Balanced neutrals",
      scheme: "scheme-neutral"
    },
    {
      icon: "",
      name: "Rainbow",
      description: "Full spectrum colors",
      scheme: "scheme-rainbow"
    },
    {
      icon: "󱠦",
      name: "Tonal Spot",
      description: "Subtle tonal variations",
      scheme: "scheme-tonal-spot"
    },
    {
      icon: "󰓠",
      name: "Vibrant",
      description: "Bold vibrant colors",
      scheme: "scheme-vibrant"
    }
  ]

  // ========================================================================
  // INITIALIZATION
  // ========================================================================

  /**
   * Initialize by reading current wallpaper path from cache
   */
  Component.onCompleted: {
    loadCurrentWallpaperPath()
  }

  // ========================================================================
  // CURRENT WALLPAPER DETECTION
  // ========================================================================

  /**
   * Process to read current wallpaper path from cache file
   * The wallpaper path is written by wallpaper-switcher script
   * Format: single line with full path to wallpaper
   */
  Process {
    id: loadWallpaperProcess

    onStarted: {
      manager.isLoadingWallpaper = true
    }

    stdout: SplitParser {
      onRead: data => {
        if (!data) return

        var path = data.trim()
        if (path && path !== "") {
          manager.currentWallpaperPath = path
          console.log("[MatugenManager] Loaded wallpaper path:", path)
        }
      }
    }

    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.warn("[MatugenManager] Wallpaper read warning:", data.trim())
        }
      }
    }

    onExited: code => {
      manager.isLoadingWallpaper = false

      if (code !== 0) {
        console.error("[MatugenManager] Failed to read wallpaper path (exit code:", code, ")")
      }
    }
  }

  /**
   * Load current wallpaper path from cache file
   * This file is maintained by the wallpaper-switcher script
   */
  function loadCurrentWallpaperPath() {
    if (manager.isLoadingWallpaper) return

    var homeDir = Quickshell.env("HOME")
    if (!homeDir) {
      console.error("[MatugenManager] No HOME environment variable")
      return
    }

    var cachePath = homeDir + "/.cache/quickshell/current-wallpaper"

    loadWallpaperProcess.command = ["cat", cachePath]
    loadWallpaperProcess.running = true
  }

  // ========================================================================
  // NOTIFICATIONS
  // ========================================================================

  /**
   * Send a notification using notify-send
   *
   * Uses a detached shell process with a delay to ensure the notification
   * survives config reloads triggered by theme changes.
   *
   * @param title - Notification title
   * @param message - Notification body
   * @param urgency - Urgency level (low, normal, critical)
   * @param icon - Icon name
   */
  function sendNotification(title, message, urgency, icon) {
    // Escape single quotes in title and message for shell safety
    var safeTitle = title.replace(/'/g, "'\\''")
    var safeMessage = message.replace(/'/g, "'\\''")

    // Use sh -c with sleep to delay notification until after config reload
    // The & backgrounds the process so it's completely detached from QML lifecycle
    var notifyCmd = "sleep 0.5 && notify-send -u " + (urgency || "normal") +
                    " -i " + (icon || "preferences-color") +
                    " '" + safeTitle + "' '" + safeMessage + "'"
    var cmd = ["sh", "-c", notifyCmd + " &"]

    console.log("[MatugenManager] Scheduling notification (0.5s delay):", title, "-", message)
    Core.ProcessUtils.runCommandAsync(
      manager,
      cmd
    )
  }

  // ========================================================================
  // COMMAND EXECUTION
  // ========================================================================

  /**
   * Execute matugen with selected color scheme
   *
   * This function:
   * - Closes the menu immediately for better UX
   * - Reads the current wallpaper path if not already loaded
   * - Executes matugen command with the scheme and wallpaper
   * - Sends notification on success or error (detached from QML lifecycle)
   * - Logs success/failure to console
   *
   * Command format:
   * matugen image <wallpaper_path> -t <scheme> --mode <light|dark>
   *
   * @param option - Color scheme option object from colorSchemes array
   */
  function executeColorScheme(option) {
    console.log("[MatugenManager] Applying color scheme:", option.name, "(" + option.scheme + ")")

    // Close menu immediately for better UX (don't wait for command completion)
    manager.visible = false

    // Ensure we have the current wallpaper path
    if (!manager.currentWallpaperPath || manager.currentWallpaperPath === "") {
      console.error("[MatugenManager] No wallpaper path available")
      // Try to reload wallpaper path
      loadCurrentWallpaperPath()
      return
    }

    // Escape paths for shell safety
    var safePath = manager.currentWallpaperPath.replace(/'/g, "'\\''")
    var safeName = option.name.replace(/'/g, "'\\''")
    var modeText = manager.lightMode ? "Light" : "Dark"
    var modeArg = manager.lightMode ? "light" : "dark"

    // Create a completely detached shell script that:
    // 1. Runs matugen
    // 2. Waits for completion
    // 3. Sends notification based on exit code
    // 4. Survives QML lifecycle and config reloads
    var script = "(" +
      "matugen image '" + safePath + "' -t " + option.scheme + " --mode " + modeArg + " && " +
      "notify-send -u normal -i preferences-color 'Matugen Color Scheme' '" + safeName + " scheme applied (" + modeText + " mode)' " +
      "|| " +
      "notify-send -u critical -i dialog-error 'Matugen Error' 'Failed to apply " + safeName + " scheme'" +
      ") &"

    console.log("[MatugenManager] Executing detached matugen command")

    // Execute the detached script
    Core.ProcessUtils.runCommandAsync(
      manager,
      ["sh", "-c", script]
    )
  }

  // ========================================================================
  // VISIBILITY HANDLING
  // ========================================================================

  /**
   * Refresh wallpaper path when menu is opened
   * This ensures we always have the latest wallpaper path
   */
  onVisibleChanged: {
    if (visible) {
      loadCurrentWallpaperPath()
    }
  }

  // ========================================================================
  // IPC INTERFACE
  // ========================================================================

  /**
   * IPC handler for external control
   * Allows control via hyprctl dispatch ipc commands or quickshell --ipc
   *
   * Examples:
   *   hyprctl dispatch ipc matugen:toggle
   *   quickshell --ipc matugen open
   *   quickshell --ipc matugen close
   *   quickshell --ipc matugen toggleMode
   */
  IpcHandler {
    target: "matugen"

    // Toggle menu visibility
    function toggle(): void {
      manager.visible = !manager.visible
    }

    // Open menu
    function open(): void {
      manager.visible = true
    }

    // Close menu
    function close(): void {
      manager.visible = false
    }

    // Toggle light/dark mode
    function toggleMode(): void {
      manager.lightMode = !manager.lightMode
      console.log("[MatugenManager] Mode toggled to:", manager.lightMode ? "light" : "dark")
    }
  }
}
