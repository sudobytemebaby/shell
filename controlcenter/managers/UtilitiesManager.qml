import QtQuick
import Quickshell
import Quickshell.Io
import "../../core" as Core

Scope {
  id: manager
  
  // ========== NIGHT LIGHT STATE ==========
  property bool nightLightActive: false
  
  // ========== CHECK NIGHT LIGHT STATUS ==========
  Process {
    id: nightLightCheckProcess
    command: ["pgrep", "-x", "hyprsunset"]
    
    onExited: code => {
      // Exit code 0 means process found (night light is on)
      // Exit code 1 means process not found (night light is off)
      manager.nightLightActive = (code === 0)
    }
    
    stderr: SplitParser {
      onRead: data => {
        // Ignore stderr, pgrep sometimes complains
      }
    }
  }
  
  // Timer to periodically check night light state
  Timer {
    interval: 6000  // Check every 2 seconds
    running: true
    repeat: true
    onTriggered: {
      if (!nightLightCheckProcess.running) {
        nightLightCheckProcess.running = true
      }
    }
  }
  
  // ========== TOGGLE NIGHT LIGHT ==========
  function toggleNightLight() {
    Core.ProcessUtils.runCommand(
      manager,
      ["night-mode"],
      () => {
        // Wait a bit after script completes to ensure state is settled
        checkStateDelayTimer.restart()
      },
      (code, error) => {
        console.error("[UtilitiesManager] Failed to toggle night mode:", error)
        // Still check state even on error
        checkStateDelayTimer.restart()
      }
    )
  }
  
  // Delayed state check timer - gives the system time to settle
  Timer {
    id: checkStateDelayTimer
    interval: 250  // Wait 250ms after toggle
    onTriggered: {
      nightLightCheckProcess.running = true
    }
  }
  
  // ========== LAUNCHER FUNCTIONS ==========
  function launchColorPicker() {
    Core.ProcessUtils.runCommandAsync(manager, ["hyprpicker", "-a"])
  }
  
  function takeScreenshot() {
    Core.ProcessUtils.runCommandAsync(manager, ["hyprshot", "-m", "region"])
  }
  
  function openClipboard() {
    Core.ProcessUtils.runCommandAsync(manager, ["kitty", "--class", "floating_term_s", "-e", "clipse"])
  }
  
  // ========== INITIALIZATION ==========
  Component.onCompleted: {
    // Check initial night light state
    nightLightCheckProcess.running = true
  }
}
