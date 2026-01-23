import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"

/**
 * ScreenshotDisplay - UI display for the screenshot menu system
 *
 * This component provides:
 * - Full-screen overlay screenshot menu interface
 * - Keyboard shortcuts for quick actions (letter keys + arrow navigation)
 * - Material 3 design with tertiary color highlighting
 * - Smooth animations and visual feedback
 *
 * Architecture:
 * - LazyLoader ensures UI only loads when visible
 * - ScreenshotManager handles state and command execution
 * - This component is purely presentational
 *
 * Keyboard shortcuts:
 * - F: Fullscreen
 * - W: Window
 * - S: Region/Section
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
    id: screenshotWindow

    // Fill entire screen - screenshot menu will be centered inside
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

    property int selectedIndex: 0  // Currently selected screenshot option index

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
          if (screenshotWindow.selectedIndex > 0) {
            screenshotWindow.selectedIndex--
          } else {
            // Wrap around to last option
            screenshotWindow.selectedIndex = loader.manager.screenshotOptions.length - 1
          }
          event.accepted = true
        }
        // Arrow key navigation: Down/Right moves to next option
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
          if (screenshotWindow.selectedIndex < loader.manager.screenshotOptions.length - 1) {
            screenshotWindow.selectedIndex++
          } else {
            // Wrap around to first option
            screenshotWindow.selectedIndex = 0
          }
          event.accepted = true
        }
        // Execute selected option on Enter
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          var selected = loader.manager.screenshotOptions[screenshotWindow.selectedIndex]
          loader.manager.executeScreenshotOption(selected)
          event.accepted = true
        }
        // Letter key shortcuts for quick access
        // F: Fullscreen
        else if (event.key === Qt.Key_F) {
          // Find fullscreen option (index 0)
          loader.manager.executeScreenshotOption(loader.manager.screenshotOptions[0])
          event.accepted = true
        }
        // W: Window
        else if (event.key === Qt.Key_W) {
          // Find window option (index 1)
          loader.manager.executeScreenshotOption(loader.manager.screenshotOptions[1])
          event.accepted = true
        }
        // S: Region/Section
        else if (event.key === Qt.Key_R) {
          // Find region option (index 2)
          loader.manager.executeScreenshotOption(loader.manager.screenshotOptions[2])
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
      y: (parent.height - 300) / 2
      width: 700
      height: 300
      radius: 28
      color: Theme.surface_container_transparent_medium
      border.width: 1
      border.color: Qt.lighter(Theme.surface_container, 1.3)

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
            text: "Screenshot"
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
        // SCREENSHOT OPTIONS GRID (1x3)
        // ====================================================================

        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 3
          rowSpacing: Theme.spacing.md
          columnSpacing: Theme.spacing.md

          Repeater {
            model: loader.manager.screenshotOptions

            // Screenshot option card delegate
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
                if (index === screenshotWindow.selectedIndex) {
                  return Theme.tertiary_container
                }
                // Hover state: Use surface container high
                if (optionMouseArea.containsMouse) {
                  return Theme.surface_container_high
                }
                // Default state: Use transparent surface container low
                return Theme.surface_container_low_transparent_medium
              }

              // Smooth color transitions
              Behavior on color {
                ColorAnimation {
                  duration: 200
                  easing.type: Easing.OutCubic
                }
              }

              ColumnLayout {
                anchors {
                  fill: parent
                  margins: Theme.spacing.md
                }
                spacing: Theme.spacing.sm

                Item { Layout.fillHeight: true }

                // Screenshot option icon
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.icon
                  // Use on_tertiary_container color when selected, otherwise on_surface
                  color: index === screenshotWindow.selectedIndex ?
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

                // Screenshot option name
                Text {
                  Layout.fillWidth: true
                  text: modelData.name
                  color: index === screenshotWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface
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

                // Screenshot option description
                Text {
                  Layout.fillWidth: true
                  text: modelData.description
                  color: index === screenshotWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface_variant
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamilyDisplay
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  opacity: index === screenshotWindow.selectedIndex ? 0.9 : 0.7

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
                  screenshotWindow.selectedIndex = index
                  loader.manager.executeScreenshotOption(modelData)
                }

                // Update selection on hover
                onEntered: {
                  screenshotWindow.selectedIndex = index
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
          text: "F Fullscreen • W Window • R Region • Esc Close"
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
