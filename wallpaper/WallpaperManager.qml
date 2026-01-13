import QtQuick
import Quickshell
import Quickshell.Io
import "../core" as Core

Scope {
  id: manager
  
  // ============================================================================
  // STATE
  // ============================================================================
  
  property bool visible: false
  property string wallpaperDir: ""
  property string thumbnailDir: ""
  
  // Script paths
  readonly property string switcherScript: "wallpaper-switcher"
  readonly property string thumbGenScript: "wallpaper-thumbgen"
  
  // Data
  property var wallpapers: []
  property string currentWallpaper: ""
  
  // Loading states
  property bool isLoading: false
  property bool isGeneratingThumbs: false
  property string errorMessage: ""
  
  // ============================================================================
  // INTERNAL STATE (prevent race conditions)
  // ============================================================================
  
  property bool listProcessRunning: false
  property bool currentWpProcessRunning: false
  property bool thumbGenProcessRunning: false
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    var homeDir = Quickshell.env("HOME")
    if (!homeDir) {
      manager.errorMessage = "Failed to get HOME directory"
      console.error("[WallpaperManager] No HOME environment variable")
      return
    }
    
    manager.wallpaperDir = homeDir + "/.config/hypr/wpapers"
    manager.thumbnailDir = homeDir + "/.cache/quickshell/wallpaper-thumbs"
    
    // Initial load
    refreshWallpapers()
  }
  
  // ============================================================================
  // LIST WALLPAPERS PROCESS
  // ============================================================================
  
  Process {
    id: listProcess
    // Use array form to prevent injection - $1 will be wallpaperDir
    command: [
      "sh", "-c",
      "ls -1 \"$1\" 2>/dev/null | grep -iE '\\.(png|jpg|jpeg|webp)$' | sort || echo ''",
      "sh",  // $0
      ""     // $1 - will be set before running
    ]
    
    property var wallpaperBuffer: []
    
    onStarted: {
      wallpaperBuffer = []
      manager.listProcessRunning = true
    }
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var line = data.trim()
        if (line && line !== "") {
          listProcess.wallpaperBuffer.push(line)
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (!data) return
        console.error("[WallpaperManager] ls error:", data.trim())
      }
    }
    
    onExited: code => {
      manager.listProcessRunning = false
      
      if (code === 0 || listProcess.wallpaperBuffer.length > 0) {
        // Success or partial success
        manager.wallpapers = listProcess.wallpaperBuffer.slice()
        manager.errorMessage = ""
        
        console.log("[WallpaperManager] Found", manager.wallpapers.length, "wallpapers")
        
        // After listing, generate thumbnails if needed
        Qt.callLater(() => generateThumbnailsIfNeeded())
      } else {
        // Complete failure
        manager.errorMessage = "Failed to list wallpapers in " + manager.wallpaperDir
        manager.wallpapers = []
      }
      
      manager.isLoading = false
    }
  }
  
  // ============================================================================
  // CURRENT WALLPAPER DETECTION
  // ============================================================================
  
  Process {
    id: currentWallpaperProcess
    // Secure command - extract basename directly
    command: [
      "sh", "-c",
      "grep -m1 '^[[:space:]]*path[[:space:]]*=' \"$1\" 2>/dev/null | " +
      "sed -E 's/^[[:space:]]*path[[:space:]]*=[[:space:]]*//; s/[[:space:]]*$//' | " +
      "xargs -r basename 2>/dev/null || echo ''",
      "sh",  // $0
      ""     // $1 - config path
    ]
    
    onStarted: {
      manager.currentWpProcessRunning = true
    }
    
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
    
    stderr: SplitParser {
      onRead: data => {
        // Silently ignore - config might not exist yet
        if (data && data.trim()) {
          console.warn("[WallpaperManager] Config read warning:", data.trim())
        }
      }
    }
    
    onExited: code => {
      manager.currentWpProcessRunning = false
    }
  }
  
  // ============================================================================
  // THUMBNAIL GENERATION
  // ============================================================================
  
  Process {
    id: thumbGenProcess
    command: ["wallpaper-thumbgen"]
    
    onStarted: {
      manager.thumbGenProcessRunning = true
      manager.isGeneratingThumbs = true
      console.log("[WallpaperManager] Generating thumbnails...")
    }
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        console.log("[WallpaperManager]", data.trim())
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (!data) return
        console.warn("[WallpaperManager] Thumbnail generation:", data.trim())
      }
    }
    
    onExited: code => {
      manager.thumbGenProcessRunning = false
      manager.isGeneratingThumbs = false
      
      if (code === 0) {
        console.log("[WallpaperManager] Thumbnails generated successfully")
      } else {
        console.warn("[WallpaperManager] Thumbnail generation failed (code:", code + ")")
      }
    }
  }
  
  // ============================================================================
  // PUBLIC FUNCTIONS
  // ============================================================================
  
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
    
    // List wallpapers
    listProcess.command[4] = manager.wallpaperDir
    listProcess.running = true
    
    // Get current wallpaper (can run in parallel)
    if (!manager.currentWpProcessRunning) {
      var homeDir = Quickshell.env("HOME")
      var configPath = homeDir + "/.config/hypr/hyprpaper.conf"
      currentWallpaperProcess.command[4] = configPath
      currentWallpaperProcess.running = true
    }
  }
  
  function generateThumbnailsIfNeeded() {
    // Don't generate if already running
    if (manager.thumbGenProcessRunning) {
      console.log("[WallpaperManager] Thumbnail generation already running")
      return
    }
    
    // Check if thumbnails exist
    checkThumbnailsProcess.running = true
  }
  
  // Check if thumbnails directory exists and has files
  Process {
    id: checkThumbnailsProcess
    command: [
      "sh", "-c",
      "[ -d \"$1\" ] && [ \"$(ls -A \"$1\" 2>/dev/null | wc -l)\" -gt 0 ] && echo 'exists' || echo 'missing'",
      "sh",
      ""  // Will be set to thumbnailDir
    ]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var status = data.trim()
        if (status === "missing") {
          console.log("[WallpaperManager] Thumbnails missing, generating...")
          thumbGenProcess.running = true
        } else {
          console.log("[WallpaperManager] Thumbnails already exist")
        }
      }
    }
    
    onStarted: {
      command[4] = manager.thumbnailDir
    }
  }
  
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
        if (output) console.log("[WallpaperManager]", output)
        console.log("[WallpaperManager] Wallpaper set successfully")
        manager.currentWallpaper = filename
        
        // Close picker on success
        manager.visible = false
      },
      (code, error) => {
        console.error("[WallpaperManager] Failed to set wallpaper:", error)
      }
    )
  }
  
  // ============================================================================
  // VISIBILITY HANDLING
  // ============================================================================
  
  onVisibleChanged: {
    if (visible && manager.wallpaperDir !== "") {
      // Refresh current wallpaper when opening
      if (!manager.currentWpProcessRunning) {
        var homeDir = Quickshell.env("HOME")
        var configPath = homeDir + "/.config/hypr/hyprpaper.conf"
        currentWallpaperProcess.command[4] = configPath
        currentWallpaperProcess.running = true
      }
    }
  }
  
  // ============================================================================
  // IPC HANDLERS
  // ============================================================================
  
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
