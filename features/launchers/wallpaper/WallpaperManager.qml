import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core/system_state" as Core

/**
 * WallpaperManager - Central state and logic manager for the wallpaper picker
 *
 * This component manages:
 * - Wallpaper discovery from ~/.config/hypr/wpapers
 * - Current wallpaper detection from hyprpaper.conf
 * - Thumbnail generation via external script
 * - Wallpaper switching via hyprctl
 * - IPC interface for external control (toggle/open/close/refresh)
 *
 * Architecture:
 * - This is a pure state management layer (no UI)
 * - UI is handled by WallpaperGrid.qml which binds to this manager
 * - Uses secure command construction (array form) to prevent injection
 * - Implements race condition prevention with process state flags
 *
 * Security:
 * - All shell commands use array form with $1, $2 placeholders
 * - Prevents injection attacks by avoiding string interpolation
 * - Safe path handling with proper quoting
 */
Scope {
  id: manager

  // ============================================================================
  // PUBLIC STATE
  // ============================================================================

  property bool visible: false              // Controls whether the picker window is shown
  property string wallpaperDir: ""          // Path to wallpaper directory

  // Script paths (available in system PATH)
  readonly property string switcherScript: "wallpaper-switcher"

  // Wallpaper data
  property var wallpapers: []               // Array of wallpaper filenames
  property string currentWallpaper: ""      // Currently active wallpaper filename

  // Loading states
  property bool isLoading: false            // True while scanning wallpaper directory
  property string errorMessage: ""          // Error message to display (empty = no error)

  // ============================================================================
  // INTERNAL STATE (prevent race conditions)
  // ============================================================================

  // Process state flags to prevent multiple simultaneous operations
  property bool listProcessRunning: false          // Wallpaper listing in progress
  property bool currentWpProcessRunning: false     // Current wallpaper detection in progress
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /**
   * Initialize paths and perform initial wallpaper scan
   * Sets up wallpaper directory and thumbnail cache paths from HOME environment
   */
  Component.onCompleted: {
    var homeDir = Quickshell.env("HOME")
    if (!homeDir) {
      manager.errorMessage = "Failed to get HOME directory"
      console.error("[WallpaperManager] No HOME environment variable")
      return
    }

    manager.wallpaperDir = homeDir + "/.config/hypr/wpapers"

    // Initial load - scan wallpaper directory
    refreshWallpapers()
  }

  // ============================================================================
  // LIST WALLPAPERS PROCESS
  // ============================================================================

  /**
   * Process to list wallpaper files from directory
   *
   * Secure command construction:
   * - Uses array form with $1 placeholder for directory path
   * - Prevents injection attacks
   * - Filters for image formats: PNG, JPG, JPEG, WEBP
   * - Sorts results alphabetically
   * - Handles errors gracefully (2>/dev/null)
   */
  Process {
    id: listProcess
    // Secure array form - $1 will be set to wallpaperDir before execution
    command: [
      "sh", "-c",
      "ls -1 \"$1\" 2>/dev/null | grep -iE '\\.(png|jpg|jpeg|webp)$' | sort || echo ''",
      "sh",  // $0
      ""     // $1 - will be set before running
    ]

    // Buffer to collect wallpaper filenames as they come in
    property var wallpaperBuffer: []
    
    onStarted: {
      // Clear buffer and set race condition flag
      wallpaperBuffer = []
      manager.listProcessRunning = true
    }

    // Parse stdout line by line
    stdout: SplitParser {
      onRead: data => {
        if (!data) return

        var line = data.trim()
        if (line && line !== "") {
          // Add each wallpaper filename to buffer
          listProcess.wallpaperBuffer.push(line)
        }
      }
    }

    // Log any errors from stderr
    stderr: SplitParser {
      onRead: data => {
        if (!data) return
        console.error("[WallpaperManager] ls error:", data.trim())
      }
    }

    // Handle process completion
    onExited: code => {
      manager.listProcessRunning = false

      if (code === 0 || listProcess.wallpaperBuffer.length > 0) {
        // Success or partial success - update wallpaper list
        manager.wallpapers = listProcess.wallpaperBuffer.slice()
        manager.errorMessage = ""

        console.log("[WallpaperManager] Found", manager.wallpapers.length, "wallpapers")
      } else {
        // Complete failure - show error
        manager.errorMessage = "Failed to list wallpapers in " + manager.wallpaperDir
        manager.wallpapers = []
      }

      manager.isLoading = false
    }
  }

  // ============================================================================
  // CURRENT WALLPAPER DETECTION
  // ============================================================================

  /**
   * Process to detect currently active wallpaper from hyprpaper.conf
   *
   * Parses the config file to extract the wallpaper path, then gets just the filename
   * Example config line: "path = /home/user/.config/hypr/wpapers/nord_space.png"
   * Result: "nord_space.png"
   */
  Process {
    id: currentWallpaperProcess
    // Secure array form - extracts filename from hyprpaper config
    command: [
      "sh", "-c",
      "grep -m1 '^[[:space:]]*path[[:space:]]*=' \"$1\" 2>/dev/null | " +
      "sed -E 's/^[[:space:]]*path[[:space:]]*=[[:space:]]*//; s/[[:space:]]*$//' | " +
      "xargs -r basename 2>/dev/null || echo ''",
      "sh",  // $0
      ""     // $1 - config path (set before running)
    ]
    
    onStarted: {
      // Set race condition flag
      manager.currentWpProcessRunning = true
    }

    // Parse output to get current wallpaper filename
    stdout: SplitParser {
      onRead: data => {
        if (!data) return

        var filename = data.trim()
        if (filename && filename !== "") {
          manager.currentWallpaper = filename
          console.log("[WallpaperManager] Current wallpaper:", filename)
        }
      }
    }

    // Silently handle errors (config might not exist on first run)
    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.warn("[WallpaperManager] Config read warning:", data.trim())
        }
      }
    }

    onExited: code => {
      // Clear race condition flag
      manager.currentWpProcessRunning = false
    }
  }

  // ============================================================================
  // PUBLIC FUNCTIONS
  // ============================================================================

  /**
   * Refresh wallpaper list from directory
   *
   * This function:
   * - Scans wallpaper directory for image files
   * - Detects currently active wallpaper
   * - Prevents race conditions with state flags
   *
   * Note: Thumbnails are generated on-demand by ImageCacheService
   */
  function refreshWallpapers() {
    if (!manager.wallpaperDir || manager.wallpaperDir === "") {
      console.error("[WallpaperManager] No wallpaper directory set")
      return
    }

    // Prevent multiple simultaneous refreshes
    if (manager.isLoading || manager.listProcessRunning) {
      console.log("[WallpaperManager] Refresh already in progress, ignoring")
      return
    }

    console.log("[WallpaperManager] Refreshing wallpapers from", manager.wallpaperDir)

    manager.isLoading = true
    manager.errorMessage = ""

    // Start wallpaper listing process
    listProcess.command[4] = manager.wallpaperDir
    listProcess.running = true

    // Get current wallpaper in parallel (if not already running)
    if (!manager.currentWpProcessRunning) {
      var homeDir = Quickshell.env("HOME")
      var configPath = homeDir + "/.config/hypr/hyprpaper.conf"
      currentWallpaperProcess.command[4] = configPath
      currentWallpaperProcess.running = true
    }
  }

  /**
   * Set wallpaper to the specified filename
   *
   * This function:
   * - Calls wallpaper-switcher script which handles hyprctl commands
   * - Updates hyprpaper.conf for persistence
   * - Closes picker on success
   * - Updates currentWallpaper property
   *
   * @param filename - Wallpaper filename (not full path, just filename)
   */
  function setWallpaper(filename) {
    if (!filename || filename === "") {
      console.error("[WallpaperManager] No filename provided")
      return
    }

    console.log("[WallpaperManager] Setting wallpaper to:", filename)

    Core.ProcessUtils.runCommand(
      manager,
      [manager.switcherScript, filename],
      (output) => {
        // Success callback
        if (output) console.log("[WallpaperManager]", output)
        console.log("[WallpaperManager] Wallpaper set successfully")
        manager.currentWallpaper = filename

        // Close picker on success
        manager.visible = false
      },
      (code, error) => {
        // Error callback
        console.error("[WallpaperManager] Failed to set wallpaper:", error)
      }
    )
  }
  
  // ============================================================================
  // VISIBILITY HANDLING
  // ============================================================================

  /**
   * Refresh current wallpaper when picker is opened
   *
   * This ensures the current wallpaper indicator is always up-to-date
   * when the picker is displayed
   */
  onVisibleChanged: {
    if (visible && manager.wallpaperDir !== "") {
      // Refresh current wallpaper detection when opening picker
      if (!manager.currentWpProcessRunning) {
        var homeDir = Quickshell.env("HOME")
        var configPath = homeDir + "/.config/hypr/hyprpaper.conf"
        currentWallpaperProcess.command[4] = configPath
        currentWallpaperProcess.running = true
      }
    }
  }

  // ============================================================================
  // IPC INTERFACE
  // ============================================================================

  /**
   * IPC handler for external control of the wallpaper picker
   * Allows other processes to control the picker via quickshell IPC
   *
   * Available methods:
   * - toggle(): Toggle picker visibility
   * - open(): Show picker
   * - close(): Hide picker
   * - refresh(): Rescan wallpaper directory
   *
   * Example usage from shell:
   *   quickshell --ipc wallpaper toggle
   *   quickshell --ipc wallpaper refresh
   */
  IpcHandler {
    target: "wallpaper"

    function toggle(): void {
      manager.visible = !manager.visible
    }

    function open(): void {
      manager.visible = true
    }

    function close(): void {
      manager.visible = false
    }

    function refresh(): void {
      manager.refreshWallpapers()
    }
  }
}
