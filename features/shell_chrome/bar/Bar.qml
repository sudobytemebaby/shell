import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../../shared/theme"
import "bar_modules" as Modules

/**
 * Bar - Full Width Top Bar
 *
 * A classic full-width status bar that spans the entire top of the screen.
 *
 * Features:
 * - Full screen width
 * - Clean rectangular design
 * - Minimal vertical spacing from screen top
 * - Three sections: left (workspaces), center (spacer), right (status)
 *
 * Architecture:
 * - Uses PanelWindow anchored to full width at top
 * - Simple Rectangle layout spanning entire width
 * - Modules are imported from bar_modules directory
 */

PanelWindow {
  id: barWindow

  // ========================================================================
  // REQUIRED PROPERTIES (injected from shell.qml)
  // ========================================================================

  required property var controlCenterManager
  required property var notificationCenterManager
  required property var calendarManager
  required property var systemState

  // ========================================================================
  // STATE
  // ========================================================================

  property bool barVisible: true  // Bar visibility state

  // ========================================================================
  // WINDOW CONFIGURATION
  // ========================================================================

  // Anchor to top and fill width
  anchors.top: true
  anchors.left: true
  anchors.right: true

  // Bar height
  implicitHeight: Theme.barHeight

  // Transparent window background (the bar itself will have the background)
  color: "transparent"

  // Window visibility - stays visible during hide animation, then hides
  visible: barVisible || hideTimer.running

  // ========================================================================
  // ANIMATION DELAY TIMER
  // ========================================================================

  /**
   * Timer to delay window hiding until after slide-out animation completes
   * This ensures the animation plays fully before the window disappears
   */
  Timer {
    id: hideTimer
    interval: 250
    running: false
    repeat: false
  }

  // Start hide timer when barVisible becomes false
  onBarVisibleChanged: {
    if (!barVisible) {
      hideTimer.start()
    }
  }

  // ========================================================================
  // IPC INTERFACE
  // ========================================================================

  /**
   * IPC handler for external control of bar visibility
   * Allows control via quickshell --ipc commands
   *
   * Examples:
   *   quickshell --ipc bar toggle  # Toggle bar visibility
   *   quickshell --ipc bar show    # Show bar
   *   quickshell --ipc bar hide    # Hide bar
   */
  IpcHandler {
    target: "bar"

    // Toggle bar visibility
    function toggle(): void {
      barWindow.barVisible = !barWindow.barVisible
    }

    // Show bar
    function show(): void {
      barWindow.barVisible = true
    }

    // Hide bar
    function hide(): void {
      barWindow.barVisible = false
    }
  }

  // ========================================================================
  // FULL WIDTH TOP BAR
  // ========================================================================

  // Standard full-width bar spanning entire screen
  Rectangle {
    id: barContainer

    // Fill the entire width, stick to top
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
    }

    // Standard bar height
    height: Theme.barHeight

    // No rounded corners - clean rectangular bar
    radius: 0 

    // Semi-transparent background with blur support
    color: Theme.surface_container_low_transparent_medium

    // Bottom border for subtle depth
    Rectangle {
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      height: 1
      color: Theme.surface_container_high
      opacity: 1
    }

    // Slide animation: slides down when showing, slides up when hiding
    transform: Translate {
      y: barWindow.barVisible ? 0 : -(barContainer.height + 2)

      Behavior on y {
        NumberAnimation {
          duration: 150
          easing.type: barWindow.barVisible ? Easing.OutCubic : Easing.InCubic
        }
      }
    }

    // Fade animation: fade in when showing, fade out when hiding
    opacity: barWindow.barVisible ? 1 : 0

    Behavior on opacity {
      NumberAnimation {
        duration: 150 
        easing.type: Easing.InOutQuad
      }
    }

    // ======================================================================
    // BAR CONTENT LAYOUT
    // ======================================================================

    RowLayout {
      id: barLayout

      anchors {
        fill: parent
        leftMargin: Theme.padding.lg
        rightMargin: Theme.padding.lg
      }

      spacing: Theme.spacing.xl

      // ====================================================================
      // LEFT SECTION - Workspaces & Controls
      // ====================================================================

      RowLayout {
        Layout.alignment: Qt.AlignLeft
        spacing: Theme.spacing.md

        // Control Center toggle button
        Modules.ControlCenterButton {
          controlCenterManager: barWindow.controlCenterManager
        }

        // Workspace indicators
        Modules.Workspaces {}

        // Keyboard layout indicator
        Modules.Keyboard {
          systemState: barWindow.systemState
        }

        // System tray icons
        Modules.SystemTray {}
      }

      // ====================================================================
      // CENTER SPACER
      // ====================================================================

      Item {
        Layout.fillWidth: true
        Layout.minimumWidth: Theme.spacing.xxl
      }

      // ====================================================================
      // RIGHT SECTION - System Status
      // ====================================================================

      RowLayout {
        Layout.alignment: Qt.AlignRight
        spacing: Theme.spacing.md

        // Battery status
        Modules.Battery {
          systemState: barWindow.systemState
        }

        // Bluetooth status
        Modules.Bluetooth {
          systemState: barWindow.systemState
        }

        // Audio volume
        Modules.Audio {
          systemState: barWindow.systemState
        }

        // Network status
        Modules.Network {
          systemState: barWindow.systemState
        }

        // Notification center toggle
        Modules.NotificationCenterButton {
          notificationCenterManager: barWindow.notificationCenterManager
        }

        // Clock with calendar toggle
        Modules.Clock {
          calendarManager: barWindow.calendarManager
        }
      }
    }
  }
}
