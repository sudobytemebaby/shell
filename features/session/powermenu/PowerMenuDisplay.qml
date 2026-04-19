import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components/Animations"
import "../../../shared/components"
import "../../../shared/components/Modals"
import "../../../shared/components/Navigation"
import "../../../shared/components/Utils"

/**
 * PowerMenuDisplay - UI display for the power menu system
 *
 * This component provides:
 * - Full-screen overlay power menu interface
 * - Keyboard shortcuts for quick actions (letter keys + arrow navigation)
 * - Material 3 design with tertiary color highlighting
 * - Smooth animations and visual feedback
 *
 * Architecture:
 * - AnimatedLazyLoader ensures UI only loads when visible
 * - PowerMenuManager handles state and command execution
 * - This component is purely presentational
 *
 * Keyboard shortcuts:
 * - S: Shutdown
 * - R: Reboot
 * - O: Logout
 * - L: Lock session
 * - U: Suspend
 * - H: Hibernate
 * - Arrow keys: Navigate between options
 * - Enter: Execute selected option
 * - Escape: Close menu
 */

// ========== LAZY LOADING ==========

AnimatedLazyLoader {
  id: loader

  required property var manager

  show: manager.visible

  // ========== WINDOW CONFIGURATION ==========

  PanelWindow {
    id: powerMenuWindow

    // Fill entire screen - power menu will be centered inside
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    visible: loader.active

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0
    }

    // ========================================================================
    // SELECTION STATE
    // ========================================================================

    property int selectedIndex: 0  // Currently selected power option index

    // ========================================================================
    // KEYBOARD NAVIGATION & SHORTCUTS
    // ========================================================================

    KeyboardNavigationHandler {
      id: navHandler
      currentIndex: powerMenuWindow.selectedIndex
      itemCount: loader.manager.powerOptions.length
      columns: 3
      wrapAround: true

      onNavigateUp: newIndex => powerMenuWindow.selectedIndex = newIndex
      onNavigateDown: newIndex => powerMenuWindow.selectedIndex = newIndex
      onNavigateLeft: newIndex => powerMenuWindow.selectedIndex = newIndex
      onNavigateRight: newIndex => powerMenuWindow.selectedIndex = newIndex

      onSelectCurrent: {
        var selected = loader.manager.powerOptions[powerMenuWindow.selectedIndex]
        loader.manager.executePowerOption(selected)
      }

      onClose: loader.manager.visible = false
    }

    contentItem {
      focus: true

      // Handle keyboard shortcuts for navigation and quick actions
      Keys.onPressed: event => {
        // Letter key shortcuts for quick access
        // S: Shutdown
        if (event.key === Qt.Key_S) {
          loader.manager.executePowerOption(loader.manager.powerOptions[0])
          event.accepted = true
          return
        }
        // R: Reboot
        else if (event.key === Qt.Key_R) {
          loader.manager.executePowerOption(loader.manager.powerOptions[1])
          event.accepted = true
          return
        }
        // O: Logout
        else if (event.key === Qt.Key_O) {
          loader.manager.executePowerOption(loader.manager.powerOptions[2])
          event.accepted = true
          return
        }
        // L: Lock
        else if (event.key === Qt.Key_L) {
          loader.manager.executePowerOption(loader.manager.powerOptions[3])
          event.accepted = true
          return
        }
        // U: Suspend
        else if (event.key === Qt.Key_U) {
          loader.manager.executePowerOption(loader.manager.powerOptions[4])
          event.accepted = true
          return
        }
        // H: Hibernate
        else if (event.key === Qt.Key_H) {
          loader.manager.executePowerOption(loader.manager.powerOptions[5])
          event.accepted = true
          return
        }

        // Delegate standard navigation to handler
        navHandler.handleKeyPress(event)
      }
    }

    // ========================================================================
    // BACKGROUND OVERLAY
    // ========================================================================

    // Semi-transparent background - clicking it closes the menu
    MouseArea {
      anchors.fill: parent
      onClicked: {
        loader.manager.visible = false
      }
    }

    // ========================================================================
    // MAIN CONTAINER
    // ========================================================================

    // Centered modal dialog with Material 3 styling
    Rectangle {
      id: container

      layer.enabled: true
      layer.smooth: true
      layer.effect: PaneShadow {}

      color: Config.paneBackground

      radius: Config.powerMenu.radius
      border.width: Config.paneBorderWidth
      border.color: Theme.surface_container

      width: Config.powerMenu.width
      height: Config.powerMenu.height
      x: (parent.width - Config.powerMenu.width) / 2
      y: (parent.height - Config.powerMenu.height) / 2

      scale: loader.contentScale
      opacity: loader.contentOpacity

      // Prevent clicks on container from propagating to background (which would close menu)
      MouseArea {
        anchors.fill: parent
      }

      ColumnLayout {
        anchors {
          fill: parent
          margins: Config.padding.xl
        }
        spacing: Config.spacing.md

        // ====================================================================
        // HEADER
        // ====================================================================

        ModalHeader {
          title: "Power Options"
          onCloseClicked: loader.manager.visible = false
        }

        // ====================================================================
        // POWER OPTIONS GRID (2x3)
        // ====================================================================

        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 3
          rowSpacing: Config.spacing.md
          columnSpacing: Config.spacing.md

          Repeater {
            model: loader.manager.powerOptions

            // Power option card delegate
            delegate: Rectangle {
              required property var modelData
              required property int index

              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.preferredHeight: 140

              radius: Config.radius.xl

              // Color logic: Use tertiary color for selection, hover for mouse interaction
              color: {
                // Selected state: Use tertiary container color
                if (index === powerMenuWindow.selectedIndex) {
                  return Theme.tertiary_container
                }
                // Default state: Use transparent surface container low
                return "transparent"
              }

              ColumnLayout {
                anchors {
                  fill: parent
                  margins: Config.spacing.md
                }
                spacing: Config.spacing.sm

                Item { Layout.fillHeight: true }

                // Power option icon
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.icon
                  // Use on_tertiary_container color when selected, otherwise on_surface
                  color: index === powerMenuWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface
                  font.pixelSize: 48
                  font.family: Config.typography.sans

                  AColor on color {}
                }

                // Power option name
                Text {
                  Layout.fillWidth: true
                  text: modelData.name
                  color: index === powerMenuWindow.selectedIndex ?
                         Theme.tertiary: Theme.on_surface
                  font.pixelSize: Config.typography.lg
                  font.family: Config.typography.sans
                  font.weight: Config.typography.weightMedium
                  horizontalAlignment: Text.AlignHCenter

                  AColor on color {}
                }

                // Power option description
                Text {
                  Layout.fillWidth: true
                  text: modelData.description
                  color: index === powerMenuWindow.selectedIndex ?
                         Theme.tertiary: Theme.on_surface_variant
                  font.pixelSize: Config.typography.sm
                  font.family: Config.typography.sans
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  opacity: index === powerMenuWindow.selectedIndex ? 0.9 : 0.7

                  AColor on color {}
                }

                Item { Layout.fillHeight: true }
              }

              // Mouse interaction handler
              MouseArea {
                id: optionMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                // Execute option on click
                onClicked: {
                  powerMenuWindow.selectedIndex = index
                  loader.manager.executePowerOption(modelData)
                }

                // Update selection on hover
                onEntered: {
                  powerMenuWindow.selectedIndex = index
                }
              }
            }
          }
        }

        // ====================================================================
        // FOOTER WITH KEYBOARD SHORTCUTS
        // ====================================================================

        FooterHint {
          hint: "S Shutdown • R Reboot • O Logout • L Lock • U Suspend • H Hibernate • Esc Close"
        }
      }
    }
  }
}
