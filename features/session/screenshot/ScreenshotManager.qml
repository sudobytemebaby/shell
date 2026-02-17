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
 * - Commands launched via hyprctl dispatch exec to run fully outside
 *   Quickshell's process tree, avoiding compositor focus/input conflicts
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

  property bool visible: false       // Menu visibility state
  property var _pendingOption: null  // Stashed option waiting for window to fully die

  // ========================================================================
  // SIGNALS
  // ========================================================================

  // Fired by ScreenshotDisplay's PanelWindow.onDestruction when the overlay
  // is fully gone and it's safe to launch interactive tools like slurp
  signal windowClosed()

  // ========================================================================
  // INITIALIZATION
  // ========================================================================

  Component.onCompleted: {
    // Wire up the windowClosed signal to actual command execution.
    // Commands are launched via hyprctl dispatch exec so they run as a clean
    // Hyprland child, completely outside Quickshell's process tree.
    // This is necessary for interactive tools like slurp which need to grab
    // compositor input focus independently.
    manager.windowClosed.connect(() => {
      if (!manager._pendingOption) return

      var option = manager._pendingOption
      manager._pendingOption = null

      console.log("[Screenshot] Window destroyed, executing:", option.name)

      Core.ProcessUtils.runCommand(
        manager,
        ["hyprctl", "dispatch", "exec", option.command],
        () => {
          console.log("[Screenshot] Dispatched successfully:", option.name)
        },
        (code, error) => {
          console.error("[Screenshot] Dispatch failed:", option.name, error)
        }
      )
    })
  }

  // ========================================================================
  // SCREENSHOT OPTIONS CONFIGURATION
  // ========================================================================

  /**
   * Screenshot options array
   * Each option defines:
   * - icon: Nerd Font icon
   * - name: Display name
   * - description: Short description of action
   * - command: System command to execute (via hyprctl dispatch exec)
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
      command: "~/.local/bin/screenshot-fullscreen",
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
      key: "R"
    }
  ]

  // ========================================================================
  // COMMAND EXECUTION
  // ========================================================================

  /**
   * Execute a screenshot option command
   *
   * Stashes the option and closes the menu. The actual command runs only
   * after ScreenshotDisplay fires windowClosed() from PanelWindow.onDestruction,
   * guaranteeing the exclusive-focus overlay is fully gone before tools like
   * slurp try to grab pointer input from the compositor.
   *
   * @param option - Screenshot option object from screenshotOptions array
   */
  function executeScreenshotOption(option) {
    console.log("[Screenshot] Queuing:", option.name)
    manager._pendingOption = option
    manager.visible = false
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
