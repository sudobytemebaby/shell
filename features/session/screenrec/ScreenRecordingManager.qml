import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core/system_state" as Core

/**
 * ScreenRecordingManager - State management and business logic for the screen recording menu
 *
 * This component handles:
 * - Screen recording option definitions (commands, icons, descriptions)
 * - Command execution through ProcessUtils
 * - IPC interface for external control (hyprctl dispatch)
 * - Visibility state management
 * - Recording state tracking (whether recording is active)
 *
 * Architecture:
 * - Follows the Manager pattern (state + logic)
 * - ScreenRecordingDisplay handles presentation
 * - Commands executed via Core.ProcessUtils for safety
 * - Tracks recording state via PID file
 *
 * IPC Interface:
 * - screenrec:toggle() - Toggle menu visibility
 * - screenrec:open()   - Open menu
 * - screenrec:close()  - Close menu
 *
 * Usage example:
 * hyprctl dispatch ipc screenrec:toggle
 */

Scope {
  id: manager

  // ========================================================================
  // STATE
  // ========================================================================

  property bool visible: false  // Menu visibility state
  property bool isRecording: false  // Recording active state

  // Path to the PID file that screen recording uses
  readonly property string pidFilePath: "/tmp/wl-recorder.pid"

  // ========================================================================
  // RECORDING STATE TRACKING
  // ========================================================================

  /**
   * Process to check if recording is active by checking PID file existence
   */
  Process {
    id: checkRecordingProcess
    command: ["test", "-f", manager.pidFilePath]

    onExited: code => {
      // Exit code 0 means file exists (recording active)
      // Exit code 1 means file doesn't exist (not recording)
      manager.isRecording = (code === 0)
    }
  }

  /**
   * Timer to periodically check recording state
   * Polls every second to keep UI in sync with actual recording state
   */
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

  // ========================================================================
  // SCREEN RECORDING OPTIONS CONFIGURATION
  // ========================================================================

  /**
   * Screen recording options array
   * Each option defines:
   * - icon: Nerd Font icon
   * - name: Display name
   * - description: Short description of action
   * - command: System command to execute
   * - key: Keyboard shortcut (for reference/documentation)
   *
   * Order matters: Matches grid layout (left-to-right, top-to-bottom)
   * and keyboard shortcut indices in ScreenRecordingDisplay
   */
  property var recordingOptions: [
    {
      icon: "󰹑",
      name: "Fullscreen",
      description: "Record entire screen",
      command: "~/.local/bin/screenrec-output",
      key: "F"
    },
    {
      icon: "󱂬",
      name: "Window",
      description: "Record active window",
      command: "~/.local/bin/screenrec-window",
      key: "W"
    },
    {
      icon: "󰆞",
      name: "Region",
      description: "Select area to record",
      command: "~/.local/bin/screenrec-region",
      key: "S"
    }
  ]

  // ========================================================================
  // COMMAND EXECUTION
  // ========================================================================

  /**
   * Execute a screen recording option command
   *
   * This function:
   * - Executes the command through ProcessUtils
   * - If not recording, starts recording and closes menu
   * - If already recording, stops recording (toggles)
   * - Logs success/failure to console
   * - Updates recording state after execution
   *
   * @param option - Recording option object from recordingOptions array
   */
  function executeRecordingOption(option) {
    console.log("[ScreenRecording] Executing:", option.name, "command:", option.command, "isRecording:", manager.isRecording)

    // If already recording, just stop it (toggle behavior)
    if (manager.isRecording) {
      console.log("[ScreenRecording] Already recording, stopping...")
      Core.ProcessUtils.runCommand(
        manager,
        ["sh", "-c", option.command],
        () => {
          console.log("[ScreenRecording] Recording stopped successfully")
          // Force immediate state check after toggle
          checkRecordingProcess.running = true
        },
        (code, error) => {
          console.error("[ScreenRecording] Failed to stop recording:", error)
          // Still check state even on error
          checkRecordingProcess.running = true
        }
      )
      // Close menu after stopping
      manager.visible = false
      return
    }

    // Start new recording
    // Close menu immediately for better UX (don't wait for command completion)
    manager.visible = false

    // Execute system command safely through ProcessUtils
    Core.ProcessUtils.runCommand(
      manager,
      ["sh", "-c", option.command],
      () => {
        console.log("[ScreenRecording] Command executed successfully:", option.name)
        // Force immediate state check after starting
        checkRecordingProcess.running = true
      },
      (code, error) => {
        console.error("[ScreenRecording] Failed to execute command:", option.name, error)
        // Still check state even on error
        checkRecordingProcess.running = true
      }
    )
  }

  // ========================================================================
  // IPC INTERFACE
  // ========================================================================

  /**
   * IPC handler for external control
   * Allows control via hyprctl dispatch ipc commands
   *
   * Examples:
   *   hyprctl dispatch ipc screenrec:toggle
   *   hyprctl dispatch ipc screenrec:open
   *   hyprctl dispatch ipc screenrec:close
   */
  IpcHandler {
    target: "screenrec"

    // Toggle menu visibility
    function toggle(): void {
      manager.visible = !manager.visible
    }

    // Open menu
    function open(): void {
      manager.visible = true
    }

    // Close menu
    function close(): void {
      manager.visible = false
    }
  }

  // ========================================================================
  // INITIALIZATION
  // ========================================================================

  Component.onCompleted: {
    // Check initial recording state on startup
    checkRecordingProcess.running = true
  }
}
