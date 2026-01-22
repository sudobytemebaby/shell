import QtQuick
import Quickshell
import Quickshell.Io

/**
 * LauncherManager
 *
 * Central state and logic manager for the application launcher system.
 *
 * ARCHITECTURE:
 * This component implements the Manager pattern, separating state management
 * and business logic from UI presentation (handled by LauncherDisplay.qml).
 *
 * RESPONSIBILITIES:
 * - Maintains visibility state and search text
 * - Provides IPC interface for external control
 * - Manages error state for launch failures
 *
 * USAGE:
 * The launcher displays desktop applications from DesktopEntries.applications
 * and allows users to search and launch them. LauncherAppList.qml handles
 * the application filtering and display logic.
 *
 * IPC INTERFACE:
 * - quickshell --ipc launcher toggle  # Toggle launcher visibility
 * - quickshell --ipc launcher open    # Open launcher
 * - quickshell --ipc launcher close   # Close launcher
 */
Scope {
  id: manager

  // ========== VISIBILITY STATE ==========

  // Controls whether the application launcher is visible
  property bool visible: false

  // ========== SEARCH STATE ==========

  // Current search filter text for application filtering
  property string searchText: ""

  // ========== ERROR STATE ==========

  // Error message from last failed operation (empty if no error)
  property string errorMessage: ""

  onVisibleChanged: {
    if (visible) {
      searchText = "" // Reset search when opening
      errorMessage = "" // Clear any previous errors
    }
  }

  // ========== IPC INTERFACE ==========

  /**
   * IPC handler for external control via quickshell CLI.
   *
   * USAGE:
   * - quickshell --ipc launcher toggle  # Toggle launcher visibility
   * - quickshell --ipc launcher open    # Show launcher
   * - quickshell --ipc launcher close   # Hide launcher
   *
   * This allows the launcher to be controlled from scripts, keybindings,
   * or other external sources.
   */
  IpcHandler {
    target: "launcher"

    function toggle(): void {
      manager.visible = !manager.visible
    }

    function open(): void {
      manager.visible = true
    }

    function close(): void {
      manager.visible = false
    }
  }
}
