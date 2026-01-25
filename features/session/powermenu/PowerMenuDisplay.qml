import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"

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
 * - LazyLoader ensures UI only loads when visible
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

LazyLoader {
  id: loader

  required property var manager

  // Lazy load UI only when visible for better performance
  active: manager.visible

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

    contentItem {
      focus: true

      // Handle keyboard shortcuts for navigation and quick actions
      Keys.onPressed: event => {
        // Close menu on Escape
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        // Arrow key navigation: Up/Left moves to previous option
        else if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
          if (powerMenuWindow.selectedIndex > 0) {
            powerMenuWindow.selectedIndex--
          } else {
            // Wrap around to last option
            powerMenuWindow.selectedIndex = loader.manager.powerOptions.length - 1
          }
          event.accepted = true
        }
        // Arrow key navigation: Down/Right moves to next option
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
          if (powerMenuWindow.selectedIndex < loader.manager.powerOptions.length - 1) {
            powerMenuWindow.selectedIndex++
          } else {
            // Wrap around to first option
            powerMenuWindow.selectedIndex = 0
          }
          event.accepted = true
        }
        // Execute selected option on Enter
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          var selected = loader.manager.powerOptions[powerMenuWindow.selectedIndex]
          loader.manager.executePowerOption(selected)
          event.accepted = true
        }
        // Letter key shortcuts for quick access
        // S: Shutdown
        else if (event.key === Qt.Key_S) {
          // Find shutdown option (index 0)
          loader.manager.executePowerOption(loader.manager.powerOptions[0])
          event.accepted = true
        }
        // R: Reboot
        else if (event.key === Qt.Key_R) {
          // Find reboot option (index 1)
          loader.manager.executePowerOption(loader.manager.powerOptions[1])
          event.accepted = true
        }
        // O: Logout
        else if (event.key === Qt.Key_O) {
          // Find logout option (index 2)
          loader.manager.executePowerOption(loader.manager.powerOptions[2])
          event.accepted = true
        }
        // L: Lock
        else if (event.key === Qt.Key_L) {
          // Find lock option (index 3)
          loader.manager.executePowerOption(loader.manager.powerOptions[3])
          event.accepted = true
        }
        // U: Suspend
        else if (event.key === Qt.Key_U) {
          // Find suspend option (index 4)
          loader.manager.executePowerOption(loader.manager.powerOptions[4])
          event.accepted = true
        }
        // H: Hibernate
        else if (event.key === Qt.Key_H) {
          // Find hibernate option (index 5)
          loader.manager.executePowerOption(loader.manager.powerOptions[5])
          event.accepted = true
        }
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
      x: (parent.width - 700) / 2
      y: (parent.height - 450) / 2
      width: 700
      height: 450
      radius: 28
      color: Theme.surface_container_transparent_medium
      border.width: 0.5
      border.color: Theme.surface_container_high

      // Prevent clicks on container from propagating to background (which would close menu)
      MouseArea {
        anchors.fill: parent
      }

      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.padding.xl
        }
        spacing: Theme.spacing.md

        // ====================================================================
        // HEADER
        // ====================================================================

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          spacing: Theme.spacing.sm

          // Title text
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding.xs
            text: "Power Options"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }

          // Close button (X icon)
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.rightMargin: Theme.padding.xs
            radius: Theme.radius.full
            color: closeMouseArea.containsMouse ? Theme.surface_container_high : "transparent"

            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.lg
              font.family: Theme.typography.fontFamily
            }

            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor

              onClicked: {
                loader.manager.visible = false
              }
            }
          }
        }

        // ====================================================================
        // POWER OPTIONS GRID (2x3)
        // ====================================================================

        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 3
          rowSpacing: Theme.spacing.md
          columnSpacing: Theme.spacing.md

          Repeater {
            model: loader.manager.powerOptions

            // Power option card delegate
            delegate: Rectangle {
              required property var modelData
              required property int index

              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.preferredHeight: 140

              radius: Theme.radius.xl

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
                  margins: Theme.spacing.md
                }
                spacing: Theme.spacing.sm

                Item { Layout.fillHeight: true }

                // Power option icon
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.icon
                  // Use on_tertiary_container color when selected, otherwise on_surface
                  color: index === powerMenuWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface
                  font.pixelSize: 48
                  font.family: Theme.typography.fontFamily

                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }

                // Power option name
                Text {
                  Layout.fillWidth: true
                  text: modelData.name
                  color: index === powerMenuWindow.selectedIndex ?
                         Theme.tertiary: Theme.on_surface
                  font.pixelSize: Theme.typography.lg
                  font.family: Theme.typography.fontFamilyDisplay
                  font.weight: Theme.typography.weightMedium
                  horizontalAlignment: Text.AlignHCenter

                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }

                // Power option description
                Text {
                  Layout.fillWidth: true
                  text: modelData.description
                  color: index === powerMenuWindow.selectedIndex ?
                         Theme.tertiary: Theme.on_surface_variant
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamilyDisplay
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  opacity: index === powerMenuWindow.selectedIndex ? 0.9 : 0.7

                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
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

        Text {
          Layout.fillWidth: true
          text: "S Shutdown • R Reboot • O Logout • L Lock • U Suspend • H Hibernate • Esc Close"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          horizontalAlignment: Text.AlignHCenter
          opacity: 0.7
        }
      }
    }
  }
}
