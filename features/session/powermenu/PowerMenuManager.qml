import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core/system_state" as Core

/**
 * PowerMenuManager - State management and business logic for the power menu
 *
 * This component handles:
 * - Power option definitions (commands, icons, descriptions)
 * - Command execution through ProcessUtils
 * - IPC interface for external control (hyprctl dispatch)
 * - Visibility state management
 *
 * Architecture:
 * - Follows the Manager pattern (state + logic)
 * - PowerMenuDisplay handles presentation
 * - Commands executed via Core.ProcessUtils for safety
 *
 * IPC Interface:
 * - powermenu:toggle() - Toggle menu visibility
 * - powermenu:open()   - Open menu
 * - powermenu:close()  - Close menu
 *
 * Usage example:
 * hyprctl dispatch ipc powermenu:toggle
 */

Scope {
  id: manager

  // ========================================================================
  // STATE
  // ========================================================================

  property bool visible: false  // Menu visibility state

  // ========================================================================
  // POWER OPTIONS CONFIGURATION
  // ========================================================================

  /**
   * Power options array
   * Each option defines:
   * - icon: Nerd Font icon
   * - name: Display name
   * - description: Short description of action
   * - command: System command to execute
   * - key: Keyboard shortcut (for reference/documentation)
   *
   * Order matters: Matches grid layout (left-to-right, top-to-bottom)
   * and keyboard shortcut indices in PowerMenuDisplay
   */
  property var powerOptions: [
    {
      icon: "󰐥",
      name: "Shutdown",
      description: "Power off the system",
      command: "systemctl poweroff",
      key: "S"
    },
    {
      icon: "󰜉",
      name: "Reboot",
      description: "Restart the system",
      command: "systemctl reboot",
      key: "R"
    },
    {
      icon: "󰍃",
      name: "Logout",
      description: "End your session",
      command: "hyprctl dispatch exit",
      key: "O"
    },
    {
      icon: "󰌾",
      name: "Lock",
      description: "Lock the screen",
      command: "loginctl lock-session",
      key: "L"
    },
    {
      icon: "󰤄",
      name: "Suspend",
      description: "Suspend to RAM",
      command: "systemctl suspend",
      key: "U"
    },
    {
      icon: "󰋊",
      name: "Hibernate",
      description: "Suspend to disk",
      command: "systemctl hibernate",
      key: "H"
    }
  ]

  // ========================================================================
  // COMMAND EXECUTION
  // ========================================================================

  /**
   * Execute a power option command
   *
   * This function:
   * - Closes the menu immediately for better UX
   * - Executes the command through ProcessUtils
   * - Logs success/failure to console
   *
   * @param option - Power option object from powerOptions array
   */
  function executePowerOption(option) {
    console.log("[PowerMenu] Executing:", option.name, "command:", option.command)

    // Close menu immediately for better UX (don't wait for command completion)
    manager.visible = false

    // Execute system command safely through ProcessUtils
    Core.ProcessUtils.runCommand(
      manager,
      ["sh", "-c", option.command],
      () => {
        console.log("[PowerMenu] Command executed successfully:", option.name)
      },
      (code, error) => {
        console.error("[PowerMenu] Failed to execute command:", option.name, error)
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
   *   hyprctl dispatch ipc powermenu:toggle
   *   hyprctl dispatch ipc powermenu:open
   *   hyprctl dispatch ipc powermenu:close
   */
  IpcHandler {
    target: "powermenu"

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
