import QtQuick
import Quickshell
import Quickshell.Io
import "../../../../shared/components/Buttons"

IconButton {
  id: root

  icon: nightModeActive ? "󰖔" : "󰖕"
  title: "Night Mod"
  subtitle: nightModeActive ? "On" : "Off"

  isStateful: true
  isActive: nightModeActive

  property bool nightModeActive: false

  // Check night mode status on startup
  Component.onCompleted: {
    statusChecker.running = true
  }

  // Status checker process
  Process {
    id: statusChecker
    command: ["pgrep", "-x", "hyprsunset"]

    onExited: (exitCode, exitStatus) => {
      // Exit code 0 means process found (night mode is on)
      // Exit code 1 means process not found (night mode is off)
      root.nightModeActive = (exitCode === 0)
    }
  }

  // Toggle process
  Process {
    id: toggleProcess
    command: ["sh", "-c", "~/.local/bin/night-mode"]

    onExited: {
      // Recheck status after toggle
      statusChecker.running = true
    }
  }

  // Periodic status check (every 5 seconds)
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: {
      if (!statusChecker.running) {
        statusChecker.running = true
      }
    }
  }

  onClicked: {
    if (!toggleProcess.running) {
      toggleProcess.running = true
    }
  }
}
