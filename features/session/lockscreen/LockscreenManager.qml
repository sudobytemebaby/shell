import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// LOCKSCREEN MANAGER
// Manages lockscreen state and provides IPC interface for external control
// Preloads wallpaper path for instant display
// ============================================================================

Scope {
  id: manager

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  property bool locked: false              // Lock state
  property bool displayActive: false       // Whether UI is loaded (lazy loading)
  property string wallpaperPath: ""        // Cached wallpaper path (preloaded)

  signal unlockCompleted()

  function lock() {
    locked = true
    displayActive = true

    // Refresh wallpaper path when locking (in case it changed)
    loadWallpaperPath()
  }

  function unlock() {
    locked = false
    unlockCompleted()
  }

  function toggle() {
    if (locked) {
      unlock()
    } else {
      lock()
    }
  }

  function scheduleDisplayUnload() {
    unloadTimer.restart()
  }

  // ============================================================================
  // FUNCTIONS
  // ============================================================================

  function loadWallpaperPath() {
    if (!wallpaperLoader.running) {
      wallpaperLoader.running = true
    }
  }

  // ============================================================================
  // WALLPAPER PATH LOADER (runs immediately on startup)
  // ============================================================================

  Process {
    id: wallpaperLoader

    command: [
      "cat",
      Quickshell.env("HOME") + "/.cache/quickshell/current-wallpaper"
    ]

    stdout: SplitParser {
      onRead: data => {
        if (!data) return

        var path = data.trim()
        if (path && path !== "") {
          manager.wallpaperPath = "file://" + path
        }
      }
    }

    stderr: SplitParser {
      onRead: data => {
        // Silently ignore errors (file might not exist yet)
      }
    }

    Component.onCompleted: {
      // Load wallpaper path immediately on startup
      running = true
    }
  }

  // ============================================================================
  // WALLPAPER IMAGE PRELOADER (invisible, keeps image cached)
  // ============================================================================

  Image {
    id: wallpaperPreloader
    source: manager.wallpaperPath
    visible: false
    cache: true
    asynchronous: true

    // This preloads the image so when lockscreen shows, it's instant
    Component.onCompleted: {
      console.log("[LockscreenManager] Wallpaper preloader ready")
    }
  }

  // ============================================================================
  // UNLOAD TIMER
  // ============================================================================

  Timer {
    id: unloadTimer
    interval: 250
    repeat: false
    onTriggered: {
      manager.displayActive = false
    }
  }

  // ============================================================================
  // IPC HANDLER
  // ============================================================================

  IpcHandler {
    target: "lockscreen"

    function lock(): void {
      manager.lock()
    }

    function unlock(): void {
      manager.unlock()
    }

    function toggle(): void {
      manager.toggle()
    }
  }
}
