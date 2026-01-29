import QtQuick
import Quickshell

/**
 * QuickActionsManager - State management and business logic for quick action buttons
 *
 * This component handles:
 * - Quick action button definitions (icon, action, tooltip)
 * - Command execution for each action
 * - Integration with external managers (matugen)
 *
 * Architecture:
 * - Follows the Manager pattern (state + logic)
 * - QuickActions component handles presentation
 * - Commands executed via Quickshell.Process
 *
 * Available actions:
 * - Color picker (hyprpicker)
 * - Clipboard manager (clipse)
 * - Terminal launcher
 * - Matugen theme switcher
 */

Scope {
  id: manager

  // ========================================================================
  // EXTERNAL DEPENDENCIES
  // ========================================================================

  // Reference to matugen manager for theme switching
  required property var matugen

  // Reference to control center manager for closing after action
  required property var controlCenter

  // ========================================================================
  // QUICK ACTIONS CONFIGURATION
  // ========================================================================

  /**
   * Quick action button definitions
   * Each action defines:
   * - icon: Nerd Font icon representing the action
   * - tooltip: Description of what the action does
   * - action: Function to execute when button is clicked
   */
  readonly property var actions: [
    {
      icon: "󰈊",
      tooltip: "Color Picker",
      action: function() { executeColorPicker() }
    },
    {
      icon: "󰅇",
      tooltip: "Clipboard Manager",
      action: function() { executeClipboard() }
    },
    {
      icon: "",
      tooltip: "Terminal",
      action: function() { executeTerminal() }
    },
    {
      icon: "󰏘",
      tooltip: "Theme Switcher",
      action: function() { executeThemeSwitcher() }
    }
  ]

  // ========================================================================
  // ACTION HANDLERS
  // ========================================================================

  /**
   * Launch color picker tool (hyprpicker)
   * Opens hyprpicker with the -p flag to print color to stdout
   */
  function executeColorPicker() {
    manager.controlCenter.visible = false
    try {
      Quickshell.execDetached({
        command: ["sh", "hyprpicker", "-p"]
      })
    } catch (error) {
      console.error("[QuickActionsManager] Failed to launch color picker:", error)
    }
  }

  /**
   * Launch clipboard manager (clipse)
   * Opens in a floating terminal window
   */
  function executeClipboard() {
    manager.controlCenter.visible = false
    try {
      Quickshell.execDetached({
        command: ["foot", "--app-id=floating_term_s", "-e", "clipse"]
      })
    } catch (error) {
      console.error("[QuickActionsManager] Failed to launch clipboard manager:", error)
    }
  }

  /**
   * Launch terminal
   * Opens a floating terminal window
   */
  function executeTerminal() {
    manager.controlCenter.visible = false
    try {
      Quickshell.execDetached({
        command: ["foot", "--app-id=floating_term_s"]
      })
    } catch (error) {
      console.error("[QuickActionsManager] Failed to launch terminal:", error)
    }
  }

  /**
   * Open theme switcher dialog
   * Toggles the matugen dialog visibility
   */
  function executeThemeSwitcher() {
    manager.controlCenter.visible = false
    try {
      if (manager.matugen) {
        manager.matugen.visible = true
      } else {
        console.error("[QuickActionsManager] Matugen manager not available")
      }
    } catch (error) {
      console.error("[QuickActionsManager] Failed to open theme switcher:", error)
    }
  }

  /**
   * Execute action by index
   * Helper function to trigger an action from the actions array
   *
   * @param index - Index of the action to execute
   */
  function executeAction(index) {
    if (index >= 0 && index < actions.length) {
      actions[index].action()
    } else {
      console.error("[QuickActionsManager] Invalid action index:", index)
    }
  }
}
