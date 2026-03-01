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
 * - Three sections: left (workspaces), center (clock), right (status)
 *
 * Architecture:
 * - Uses PanelWindow anchored to full width at top
 * - Item-based layout with anchors for true mathematical centering
 * - Left/right sections use anchors.left/right, clock uses anchors.centerIn
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

  property bool barVisible: true

  // ========================================================================
  // WINDOW CONFIGURATION
  // ========================================================================

  anchors.top: true
  anchors.left: true
  anchors.right: true

  implicitHeight: Theme.barHeight

  color: "transparent"

  // Window stays visible during hide animation, then disappears
  visible: barVisible || hideTimer.running

  // ========================================================================
  // ANIMATION DELAY TIMER
  // ========================================================================

  Timer {
    id: hideTimer
    interval: 250
    running: false
    repeat: false
  }

  onBarVisibleChanged: {
    if (!barVisible) hideTimer.start()
  }

  // ========================================================================
  // IPC INTERFACE
  // ========================================================================

  IpcHandler {
    target: "bar"
    function toggle(): void { barWindow.barVisible = !barWindow.barVisible }
    function show(): void   { barWindow.barVisible = true }
    function hide(): void   { barWindow.barVisible = false }
  }

  // ========================================================================
  // FULL WIDTH TOP BAR
  // ========================================================================

  Rectangle {
    id: barContainer

    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
    }

    height: Theme.barHeight
    radius: 0
    color: Theme.surface_transparent_medium

    // Bottom border
    Rectangle {
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      height: 1
      color: Theme.surface_container_high
    }

    // Slide animation
    transform: Translate {
      y: barWindow.barVisible ? 0 : -(barContainer.height + 2)
      Behavior on y {
        NumberAnimation {
          duration: 150
          easing.type: barWindow.barVisible ? Easing.OutCubic : Easing.InCubic
        }
      }
    }

    // Fade animation
    opacity: barWindow.barVisible ? 1 : 0
    Behavior on opacity {
      NumberAnimation {
        duration: 150
        easing.type: Easing.InOutQuad
      }
    }

    // ======================================================================
    // BAR CONTENT LAYOUT
    // Using Item + anchors instead of RowLayout so the clock is always
    // mathematically centered on screen, regardless of left/right widths.
    // ======================================================================

    Item {
      anchors {
        fill: parent
        leftMargin: Theme.padding.lg
        rightMargin: Theme.padding.lg
      }

      // ==================================================================
      // LEFT SECTION
      // ==================================================================

      RowLayout {
        id: leftSection
        anchors {
          left: parent.left
          verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spacing.lg

        Modules.ControlCenterButton {
          controlCenterManager: barWindow.controlCenterManager
        }

        Modules.Workspaces {}

        Modules.Keyboard {
          systemState: barWindow.systemState
        }

      }

      // ==================================================================
      // CENTER - Clock, always exactly in the middle of the bar
      // ==================================================================

      Modules.Clock {
        anchors.centerIn: parent
        calendarManager: barWindow.calendarManager
      }

      // ==================================================================
      // RIGHT SECTION
      // ==================================================================

      RowLayout {
        id: rightSection
        anchors {
          right: parent.right
          verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spacing.lg

        Modules.SystemTray {}

        Modules.Battery {
          systemState: barWindow.systemState
        }

        Modules.Bluetooth {
          systemState: barWindow.systemState
        }

        Modules.Audio {
          systemState: barWindow.systemState
        }

        Modules.Network {
          systemState: barWindow.systemState
        }

        Modules.NotificationCenterButton {
          notificationCenterManager: barWindow.notificationCenterManager
        }
      }
    }
  }
}
