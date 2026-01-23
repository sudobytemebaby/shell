import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core/system_state" as Core

/**
 * ScreenshotManager - State management and business logic for the screenshot menu
 *
 * This component handles:
 * - Screenshot option definitions (commands, icons, descriptions)
 * - Command execution through ProcessUtils
 * - IPC interface for external control (hyprctl dispatch)
 * - Visibility state management
 *
 * Architecture:
 * - Follows the Manager pattern (state + logic)
 * - ScreenshotDisplay handles presentation
 * - Commands executed via Core.ProcessUtils for safety
 *
 * IPC Interface:
 * - screenshot:toggle() - Toggle menu visibility
 * - screenshot:open()   - Open menu
 * - screenshot:close()  - Close menu
 *
 * Usage example:
 * hyprctl dispatch ipc screenshot:toggle
 */

Scope {
  id: manager

  // ========================================================================
  // STATE
  // ========================================================================

  property bool visible: false  // Menu visibility state

  // ========================================================================
  // SCREENSHOT OPTIONS CONFIGURATION
  // ========================================================================

  /**
   * Screenshot options array
   * Each option defines:
   * - icon: Nerd Font icon
   * - name: Display name
   * - description: Short description of action
   * - command: System command to execute
   * - key: Keyboard shortcut (for reference/documentation)
   *
   * Order matters: Matches grid layout (left-to-right, top-to-bottom)
   * and keyboard shortcut indices in ScreenshotDisplay
   */
  property var screenshotOptions: [
    {
      icon: "󰹑",
      name: "Fullscreen",
      description: "Capture entire screen",
      command: "~/.local/bin/screenshot-output",
      key: "F"
    },
    {
      icon: "󱂬",
      name: "Window",
      description: "Capture active window",
      command: "~/.local/bin/screenshot-window",
      key: "W"
    },
    {
      icon: "󰆞",
      name: "Region",
      description: "Select area to capture",
      command: "~/.local/bin/screenshot-region",
      key: "S"
    }
  ]

  // ========================================================================
  // COMMAND EXECUTION
  // ========================================================================

  /**
   * Execute a screenshot option command
   *
   * This function:
   * - Closes the menu immediately for better UX
   * - Executes the command through ProcessUtils
   * - Logs success/failure to console
   *
   * @param option - Screenshot option object from screenshotOptions array
   */
  function executeScreenshotOption(option) {
    console.log("[Screenshot] Executing:", option.name, "command:", option.command)

    // Close menu immediately for better UX (don't wait for command completion)
    manager.visible = false

    // Execute system command safely through ProcessUtils
    Core.ProcessUtils.runCommand(
      manager,
      ["sh", "-c", option.command],
      () => {
        console.log("[Screenshot] Command executed successfully:", option.name)
      },
      (code, error) => {
        console.error("[Screenshot] Failed to execute command:", option.name, error)
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
   *   hyprctl dispatch ipc screenshot:toggle
   *   hyprctl dispatch ipc screenshot:open
   *   hyprctl dispatch ipc screenshot:close
   */
  IpcHandler {
    target: "screenshot"

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
}
