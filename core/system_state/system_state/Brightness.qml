import QtQuick
import Quickshell
import Quickshell.Io

// Brightness State Module
// Manages system brightness state and provides control functions.
// Monitors both programmatic and external changes (e.g., keyboard shortcuts).
Scope {
  id: module
  
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  
  // Set by parent when user is interacting with controls
  // Prevents external change signals during user interaction
  property bool userInteracting: false
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  property real brightness: 0.5
  property real brightnessMax: 1.0
  
  // Track if brightness change came from THIS module (to prevent loops)
  property bool changingBrightness: false

  // ============================================================================
  // CACHED COMPUTED PROPERTIES (Noctalia Pattern)
  // ============================================================================

  readonly property string brightnessIcon: {
    if (brightness < 0.33) return "󰃞"
    if (brightness < 0.66) return "󰃟"
    return "󰃠"
  }

  // ============================================================================
  // EXTERNAL CHANGE SIGNAL (for OSD)
  // ============================================================================
  
  // Emitted when brightness changes from an EXTERNAL source
  // (e.g., keyboard shortcut, hardware button)
  // NOT emitted during user interaction or programmatic changes
  signal brightnessChangedExternally(real brightness)
  
  // ============================================================================
  // BACKLIGHT DEVICE AUTO-DETECTION
  // ============================================================================
  
  property string detectedBacklightDevice: ""
  
  Process {
    id: detectBacklightProcess
    command: ["sh", "-c", "ls /sys/class/backlight/ 2>/dev/null | head -n 1"]
    running: true
    
    stdout: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          module.detectedBacklightDevice = data.trim()
          console.log("[Brightness] Detected backlight device:", module.detectedBacklightDevice)
        } else {
          console.error("[Brightness] No backlight device found")
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[Brightness] Error detecting backlight:", data.trim())
        }
      }
    }
  }
  
  // ============================================================================
  // FILE WATCHER (for external changes)
  // ============================================================================
  
  FileView {
    id: brightnessFileWatcher
    path: module.detectedBacklightDevice 
        ? "/sys/class/backlight/" + module.detectedBacklightDevice + "/actual_brightness"
        : ""
    watchChanges: module.detectedBacklightDevice !== ""
    
    onPathChanged: {
      if (path && path !== "") {
        // Read initial brightness when device is detected
        Qt.callLater(() => {
          brightnessMaxGetter.running = true
        })
      }
    }
    
    onFileChanged: {
      // Only read back if we're not currently changing it ourselves
      // and user is not interacting
      if (!module.changingBrightness && !module.userInteracting) {
        readCurrentBrightness()
      }
    }
  }
  
  // ============================================================================
  // BRIGHTNESS READERS
  // ============================================================================
  
  // Get max brightness
  Process {
    id: brightnessMaxGetter
    command: ["brightnessctl", "max"]
    
    stdout: SplitParser {
      onRead: data => {
        var maxVal = parseInt(data.trim())
        
        if (!isNaN(maxVal) && maxVal > 0) {
          module.brightnessMax = maxVal
          // Chain to getting current value
          brightnessCurrentGetter.running = true
        }
        
        brightnessMaxGetter.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        brightnessMaxGetter.running = false
      }
    }
  }
  
  // Get current brightness
  Process {
    id: brightnessCurrentGetter
    command: ["brightnessctl", "get"]
    
    stdout: SplitParser {
      onRead: data => {
        var currentVal = parseInt(data.trim())
        
        if (!isNaN(currentVal) && module.brightnessMax > 0) {
          var newBrightness = currentVal / module.brightnessMax
          
          // Check if value actually changed significantly
          var oldBrightness = module.brightness
          module.brightness = newBrightness
          
          // Emit external change signal if:
          // 1. We're not changing it programmatically
          // 2. User is not interacting
          // 3. Value actually changed
          if (!module.changingBrightness && 
              !module.userInteracting && 
              Math.abs(oldBrightness - newBrightness) > 0.01) {
            module.brightnessChangedExternally(newBrightness)
          }
        }
        
        brightnessCurrentGetter.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        brightnessCurrentGetter.running = false
      }
    }
  }
  
  // ============================================================================
  // BRIGHTNESS SETTER
  // ============================================================================
  
  Process {
    id: brightnessSetterProcess
    command: ["brightnessctl", "set", "50%"]
    
    onExited: code => {
      // Clear the changing flag after a short delay
      brightnessChangeResetTimer.start()
    }
    
    stderr: SplitParser {
      onRead: data => {
        console.error("[Brightness] brightnessctl set error:", data)
      }
    }
  }
  
  // Timer to reset the changing flag
  Timer {
    id: brightnessChangeResetTimer
    interval: 200
    onTriggered: {
      module.changingBrightness = false
    }
  }
  
  // Debounce timer for reading brightness back
  Timer {
    id: brightnessDebounceTimer
    interval: 500
    onTriggered: {
      readCurrentBrightness()
    }
  }
  
  // ============================================================================
  // PUBLIC FUNCTIONS
  // ============================================================================
  
  // Read current brightness from system (internal)
  function readCurrentBrightness() {
    if (!brightnessMaxGetter.running) {
      brightnessMaxGetter.running = true
    }
  }
  
  // Sets brightness level
  // @param newBrightness - value between 0.01 and 1.0
  function setBrightness(newBrightness) {
    // Mark that we're changing brightness (prevents OSD and readback loops)
    changingBrightness = true
    brightnessChangeResetTimer.restart()
    
    // Clamp between 0.01 and 1 (prevent completely dark screen)
    newBrightness = Math.max(0.01, Math.min(1, newBrightness))
    
    // Update our property immediately for responsive UI
    brightness = newBrightness
    
    // Convert to percentage
    var percentage = Math.round(newBrightness * 100)
    
    // Set using brightnessctl
    brightnessSetterProcess.command = ["brightnessctl", "set", percentage + "%"]
    brightnessSetterProcess.running = true
    
    // Restart debounce timer - only read back after changes settle
    brightnessDebounceTimer.restart()
  }
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  Component.onCompleted: {
    readCurrentBrightness()
  }

  // ============================================================================
  // CLEANUP (Noctalia Pattern)
  // ============================================================================

  Component.onDestruction: {
    // Stop timers
    brightnessChangeResetTimer.stop()
    brightnessDebounceTimer.stop()

    // Stop any running processes
    if (detectBacklightProcess.running) detectBacklightProcess.running = false
    if (brightnessMaxGetter.running) brightnessMaxGetter.running = false
    if (brightnessCurrentGetter.running) brightnessCurrentGetter.running = false
    if (brightnessSetterProcess.running) brightnessSetterProcess.running = false
  }
}
