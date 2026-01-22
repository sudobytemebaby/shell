import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../../shared/theme"
import "bar_modules" as Modules

/**
 * Bar - Dynamic Island style status bar
 *
 * A minimal, centered bar with rounded corners that floats at the top
 * of the screen, inspired by iOS Dynamic Island design.
 *
 * Features:
 * - Centered horizontal positioning
 * - Compact width that fits content
 * - Rounded corners for modern aesthetic
 * - Minimal vertical margin from screen top
 * - Three sections: left (workspaces), center (spacer), right (status)
 *
 * Architecture:
 * - Uses PanelWindow anchored only to top (not full width)
 * - Contains centered Rectangle with pill-shaped design
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

  // Only anchor to top - this allows horizontal centering
  anchors.top: true
  anchors.left: true
  anchors.right: true

  // Minimal height - just the bar height for tight spacing
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
  // DYNAMIC ISLAND BAR CONTAINER
  // ========================================================================

  // Centered notch-style bar (like MacBook notch) that sticks to top
  Rectangle {
    id: barContainer

    // Center horizontally and stick to top edge
    anchors {
      horizontalCenter: parent.horizontalCenter
      top: parent.top
    }

    // Compact height for minimal appearance
    height: Theme.barHeight

    // Width fits content with padding
    implicitWidth: barLayout.implicitWidth + (Theme.padding.xl * 4)

    // MacBook notch style: sharp top corners, rounded bottom corners
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: Theme.radius.md
    bottomRightRadius: Theme.radius.md

    // Semi-transparent background with blur support
    color: Theme.surface_container_transparent_medium

    // Subtle border for depth
    border.width: 1
    border.color: Qt.lighter(Theme.surface_container, 1.2)

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
