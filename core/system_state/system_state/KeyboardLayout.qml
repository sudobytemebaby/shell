import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// KeyboardLayout State Module
// Displays raw keyboard layout name from Hyprland (e.g., "English (US)", "Russian")
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

  property string currentLayout: ""

  property bool isInitialized: false

  // ============================================================================
  // EXTERNAL CHANGE SIGNAL
  // ============================================================================

  signal layoutChanged(string layout)

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
  // LAYOUT SETTING (Pass-through - no mapping)
  // ============================================================================

  function setLayout(layoutString) {
    if (!layoutString) return

    var oldLayout = module.currentLayout
    module.currentLayout = layoutString.trim()

    if (oldLayout !== module.currentLayout) {
      console.log("[KeyboardLayout]", oldLayout, "→", module.currentLayout)
    }

    if (module.isInitialized && oldLayout !== module.currentLayout) {
      module.layoutChanged(module.currentLayout)
    }
  }

  // ============================================================================
  // INITIAL LAYOUT QUERY (using your existing script)
  // ============================================================================

  Process {
    id: initialLayoutProcess
    command: ["sh", "-c", "hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -n1"]
    running: false

    stdout: SplitParser {
      onRead: data => {
        if (!data || data.trim() === "") return
        var layout = data.trim()
        module.currentLayout = layout
        console.log("[KeyboardLayout] Initial layout from hyprctl:", layout)
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
