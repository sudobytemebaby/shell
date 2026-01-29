import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components/Input"
import "../../../shared/components/Modals"
import "../../../shared/components/Navigation"

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
 * - Component is destroyed when closed to free memory and reset state
 * - Resets search and selection when opened
 * - Maintains highlight position during navigation
 * - Automatically scrolls to keep current item visible
 * - Tries app.execute() first, falls back to Quickshell.execDetached
 */

// ========== LAZY LOADING ==========

Loader {
  id: loader
  active: manager.visible

  required property var manager

  sourceComponent: PanelWindow {
    id: launcherWindow

    // Fill entire screen - the launcher box will be centered inside
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    visible: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0
    }

    // ========== KEYBOARD NAVIGATION ==========

    KeyboardNavigationHandler {
      id: navHandler
      currentIndex: 0  // Not used directly (appListComponent manages its own index)
      itemCount: 0     // Not used directly
      enableCtrlPN: true

      onNavigateUp: appListComponent.moveUp()
      onNavigateDown: appListComponent.moveDown()

      onSelectCurrent: {
        const selectedApp = appListComponent.getCurrentApp()
        if (selectedApp) {
          // Try app.execute() first (preferred method)
          try {
            selectedApp.execute()
            loader.manager.visible = false
          } catch (error) {
            // Fallback: try execDetached if execute() fails
            try {
              Quickshell.execDetached({
                command: selectedApp.command,
                workingDirectory: selectedApp.workingDirectory || ""
              })
              loader.manager.visible = false
            } catch (fallbackError) {
              console.error("[LauncherDisplay] Both launch methods failed:", fallbackError)
            }
          }
        }
      }

      onClose: loader.manager.visible = false
    }

    contentItem {
      focus: true
      Keys.onPressed: event => navHandler.handleKeyPress(event)
    }

    // Clicking outside the launcher closes it
    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
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
      border.width: 0.5
      border.color: Theme.surface_container_high

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

        ModalHeader {
          title: "Applications"
          onCloseClicked: loader.manager.visible = false
        }

        // ========== SEARCH BAR ==========

        SearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 48
          placeholder: "Search applications..."

          // Update manager's search text when user types
          onSearchChanged: text => {
            loader.manager.searchText = text
          }
        }

        // ========== APP LIST ==========

        // Delegated to LauncherAppList component for separation of concerns
        // Handles application filtering, display, and launching
        LauncherAppList {
          id: appListComponent
          Layout.fillWidth: true
          Layout.fillHeight: true

          searchTerm: loader.manager.searchText

          // Close launcher when an app is successfully launched
          onAppLaunched: {
            loader.manager.visible = false
          }
        }

        // ========== FOOTER WITH HINT ==========

        FooterHint {
          hint: "Ctrl+P/N Navigate • Enter Launch • Esc Close"
        }
      }
    }
  }
}
