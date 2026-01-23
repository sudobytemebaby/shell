import QtQuick
import Quickshell
import Quickshell.Io
import "../../../../core/system_state" as Core

Scope {
  id: manager
  
  // ========== STATE ==========
  property bool isRecording: false
  
  // Path to the PID file that screen-rec uses
  readonly property string pidFilePath: "/tmp/wl-recorder.pid"
  
  // ========== CHECK IF RECORDING ==========
  // We'll poll this to keep the state in sync
  Process {
    id: checkRecordingProcess
    command: ["test", "-f", manager.pidFilePath]
    
    onExited: code => {
      // Exit code 0 means file exists (recording active)
      // Exit code 1 means file doesn't exist (not recording)
      manager.isRecording = (code === 0)
    }
  }
  
  // Timer to periodically check recording state
  Timer {
    interval: 1000  // Check every second
    running: true
    repeat: true
    onTriggered: {
      if (!checkRecordingProcess.running) {
        checkRecordingProcess.running = true
      }
    }
  }
  
  // ========== TOGGLE RECORDING ==========
  function toggleRecording() {
    console.log("Toggle recording called, current state:", manager.isRecording)

    Core.ProcessUtils.runCommand(
      manager,
      ["sh", "-c", "~/.local/bin/screen-rec"],
      () => {
        console.log("screen-rec executed successfully")
        // Force immediate state check after toggle
        checkRecordingProcess.running = true
      },
      (code, error) => {
        console.error("[RecordingManager] screen-rec failed:", error)
        // Still check state even on error
        checkRecordingProcess.running = true
      }
    )
  }
  
  // ========== INITIALIZATION ==========
  Component.onCompleted: {
    // Check initial state
    checkRecordingProcess.running = true
  }
}
