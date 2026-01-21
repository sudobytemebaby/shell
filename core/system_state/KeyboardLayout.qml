import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// KeyboardLayout State Module
// Manages keyboard layout state using Hyprland IPC for instant updates.
// Uses event-driven architecture for zero-latency layout changes.
Scope {
  id: module

  // ============================================================================
  // DEPENDENCIES
  // ============================================================================

  property bool userInteracting: false

  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================

  property string currentLayout: "EN"
  property string currentIcon: "󰌌"

  property bool isInitialized: false

  // ============================================================================
  // EXTERNAL CHANGE SIGNAL
  // ============================================================================

  signal layoutChanged(string layout, string icon)

  // ============================================================================
  // HYPRLAND IPC EVENT LISTENER (Primary - Instant Updates)
  // ============================================================================

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === "activelayout") {
        handleLayoutChangeEvent(event.data)
      }
    }
  }

  // ============================================================================
  // EVENT HANDLERS
  // ============================================================================

  function handleLayoutChangeEvent(eventData) {
    if (!eventData || eventData.trim() === "") return

    // Event data format: "keyboard-name,Layout Name (variant)"
    var parts = eventData.split(",")
    if (parts.length >= 2) {
      var layoutString = parts[1].trim()
      setLayout(layoutString)
    }
  }

  // ============================================================================
  // LAYOUT PARSING & MAPPING
  // ============================================================================

  function setLayout(layoutString) {
    if (!layoutString) return

    var oldLayout = module.currentLayout
    var result = parseLayoutString(layoutString)

    module.currentLayout = result.code
    module.currentIcon = result.icon

    if (oldLayout !== module.currentLayout) {
      console.log("[KeyboardLayout]", oldLayout, "→", module.currentLayout)
    }

    if (module.isInitialized && oldLayout !== module.currentLayout) {
      module.layoutChanged(module.currentLayout, module.currentIcon)
    }
  }

  function parseLayoutString(layoutString) {
    var str = layoutString.toLowerCase().trim()

    // Remove variant: "English (US)" -> "English"
    if (str.indexOf("(") !== -1) {
      str = str.substring(0, str.indexOf("(")).trim()
    }

    // Map layouts
    var layoutMap = {
      "english (us)": {code: "EN", icon: "󰌌"},
      "english": {code: "EN", icon: "󰌌"},
      "us": {code: "EN", icon: "󰌌"},
      "russian": {code: "RU", icon: "󰗊"},
      "ru": {code: "RU", icon: "󰗊"},
      "arabic": {code: "AR", icon: "󰀍"},
      "ar": {code: "AR", icon: "󰀍"},
      "german": {code: "DE", icon: "󰀪"},
      "de": {code: "DE", icon: "󰀪"},
      "french": {code: "FR", icon: "󰀫"},
      "fr": {code: "FR", icon: "󰀫"},
      "spanish": {code: "ES", icon: "󰀩"},
      "es": {code: "ES", icon: "󰀩"}
    }

    if (layoutMap[str]) {
      return layoutMap[str]
    }

    // Fallback
    var code = str.substring(0, 2).toUpperCase()
    return {code: code, icon: "󰌌"}
  }

  // ============================================================================
  // INITIAL LAYOUT QUERY (using your existing script)
  // ============================================================================

  Process {
    id: initialLayoutProcess
    command: ["bash", "-c", "$HOME/.local/bin/keyboard-state"]
    running: false

    stdout: SplitParser {
      onRead: data => {
        if (!data || data.trim() === "") return

        var line = data.trim()
        var parts = line.split("|")

        if (parts.length === 2) {
          // Parse your script's output format: "KB|English(US)" or "KB|Русский"
          var lang = parts[1]

          // Map your custom labels to layout codes
          if (lang.indexOf("English") !== -1 || lang.indexOf("US") !== -1) {
            module.currentLayout = "EN"
            module.currentIcon = "󰌌"
          } else if (lang.indexOf("Русский") !== -1 || lang.indexOf("Russian") !== -1) {
            module.currentLayout = "RU"
            module.currentIcon = "󰗊"
          } else {
            module.currentLayout = lang.substring(0, 2).toUpperCase()
            module.currentIcon = "󰌌"
          }

          console.log("[KeyboardLayout] Initial layout:", module.currentLayout)
        }

        initialLayoutProcess.running = false
      }
    }

    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[KeyboardLayout] Script error:", data.trim())
        }
      }
    }
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  Timer {
    id: initTimer
    interval: 1000
    onTriggered: {
      module.isInitialized = true
      console.log("[KeyboardLayout] Module ready, layout:", module.currentLayout)
    }
  }

  Component.onCompleted: {
    // Get initial layout from your script
    initialLayoutProcess.running = true

    // Mark as initialized
    initTimer.start()

    console.log("[KeyboardLayout] Module loaded - waiting for Hyprland IPC events")
  }

  // ============================================================================
  // CLEANUP (Noctalia Pattern)
  // ============================================================================

  Component.onDestruction: {
    // Stop timers
    initTimer.stop()

    // Stop any running processes
    if (initialLayoutProcess.running) initialLayoutProcess.running = false
  }
}
