import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components/Input"

/**
 * LauncherDisplay
 *
 * UI display component for the application launcher system.
 *
 * ARCHITECTURE:
 * This component implements the Display pattern, handling all visual presentation
 * while delegating state management to LauncherManager.qml and application list
 * logic to LauncherAppList.qml. The UI is lazy-loaded for performance and uses
 * Material 3 design principles.
 *
 * FEATURES:
 * - Search-based filtering of desktop applications
 * - Keyboard navigation with highlight following
 * - Material 3 design with smooth animations
 * - Empty state handling with helpful messages
 * - Fallback launch mechanism for better reliability
 *
 * KEYBOARD SHORTCUTS:
 * - Up/Down or Ctrl+P/N: Navigate through applications
 * - Enter: Launch selected application
 * - Escape: Close launcher
 * - Type to search: Filter applications in real-time
 *
 * BEHAVIOR:
 * - Lazy loads when manager.visible becomes true
 * - Resets search and selection when opened
 * - Maintains highlight position during navigation
 * - Automatically scrolls to keep current item visible
 * - Tries app.execute() first, falls back to Quickshell.execDetached
 */

// ========== WINDOW CONFIGURATION ==========

PanelWindow {
  id: launcherWindow

  required property var manager

  // Fill entire screen - the launcher box will be centered inside
  anchors {
    top: true
    left: true
    bottom: true
    right: true
  }

  visible: manager.visible

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: manager.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  color: "transparent"
  mask: null

  Component.onCompleted: {
    exclusiveZone = 0
  }

  // ========== KEYBOARD NAVIGATION ==========

  contentItem {
    focus: true

    // Handle all keyboard shortcuts for launcher navigation
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          manager.visible = false
          event.accepted = true
        } 
        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
          appListComponent.moveUp()
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          appListComponent.moveDown()
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          event.accepted = true

          const selectedApp = appListComponent.getCurrentApp()

          if (selectedApp) {
            // Try app.execute() first (preferred method)
            try {
              selectedApp.execute()
              manager.visible = false
            } catch (error) {
              // Fallback: try execDetached if execute() fails
              try {
                Quickshell.execDetached({
                  command: selectedApp.command,
                  workingDirectory: selectedApp.workingDirectory || ""
                })
                manager.visible = false
              } catch (fallbackError) {
                console.error("[LauncherDisplay] Both launch methods failed:", fallbackError)
              }
            }
          }
      }
    }
  }

  // ========== BACKGROUND OVERLAY ==========

  // Clicking outside the launcher closes it
  MouseArea {
    anchors.fill: parent
    onClicked: manager.visible = false
  }

  // ========== MAIN CONTAINER ==========

  Rectangle {
    id: background
    x: (parent.width - 540) / 2
    y: (parent.height - 600) / 2
    width: 540
    height: 600
    radius: 28
    color: Theme.surface_container_transparent_medium
    border.width: 1
    border.color: Qt.lighter(Theme.surface_container, 1.3)

    // Prevent clicks on launcher from closing it (only background clicks close)
    MouseArea {
      anchors.fill: parent
    }

    ColumnLayout {
      anchors {
        fill: parent
        margins: Theme.padding.xl
      }
      spacing: Theme.spacing.md

      // ========== HEADER ==========
      RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        spacing: Theme.spacing.sm

        Text {
          Layout.fillWidth: true
          Layout.leftMargin: Theme.padding.xs
          text: "Applications"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.xl
          font.family: Theme.typography.fontFamily
          font.weight: Theme.typography.weightMedium
        }

        // Close button (clickable X icon)
        Text {
          Layout.rightMargin: Theme.padding.sm
          text: "✕"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.lg
          font.family: Theme.typography.fontFamily

          MouseArea {
            id: closeMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: manager.visible = false
          }
        }
      }

      // ========== SEARCH BAR ==========

      SearchBar {
        Layout.fillWidth: true
        Layout.preferredHeight: 48
        placeholder: "Search applications..."

        // Update manager's search text when user types
        onSearchChanged: text => {
          manager.searchText = text
        }
      }

      // ========== APP LIST ==========

      // Delegated to LauncherAppList component for separation of concerns
      // Handles application filtering, display, and launching
      LauncherAppList {
        id: appListComponent
        Layout.fillWidth: true
        Layout.fillHeight: true

        searchTerm: manager.searchText

        // Close launcher when an app is successfully launched
        onAppLaunched: {
          manager.visible = false
        }
      }

      // ========== FOOTER WITH HINT ==========
      Text {
        Layout.fillWidth: true
        text: "↑↓ / Ctrl+P/N Navigate • Enter Launch • Esc Close"
        color: Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        horizontalAlignment: Text.AlignHCenter
        opacity: 0.7
      }
    }
  }
}
