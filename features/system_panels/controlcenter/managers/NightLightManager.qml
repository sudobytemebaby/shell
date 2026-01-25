import QtQuick
import Quickshell
import Quickshell.Io
import "../../../../core/system_state" as Core

Scope {
  id: manager
  
  property bool nightLightActive: false
  
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
    interval: 6000
    running: true
    repeat: true
    onTriggered: {
      if (!nightLightCheckProcess.running) {
        nightLightCheckProcess.running = true
      }
    }
  }
  
  function toggleNightLight() {
    Core.ProcessUtils.runCommand(
      manager,
      ["sh", "-c", "~/.local/bin/night-mode"],
      () => {
        // Wait a bit after script completes to ensure state is settled
        checkStateDelayTimer.restart()
      },
      (code, error) => {
        console.error("[NightLightManager] Failed to toggle night mode:", error)
        // Still check state even on error
        checkStateDelayTimer.restart()
      }
    )
  }
  
  // Delayed state check timer - gives the system time to settle
  Timer {
    id: checkStateDelayTimer
    interval: 100
    onTriggered: {
      nightLightCheckProcess.running = true
    }
  }
  
  Component.onCompleted: {
    // Check initial night light state
    nightLightCheckProcess.running = true
  }
}
