import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"

/**
 * ScreenshotDisplay - Compact OSD-style screenshot menu
 *
 * Provides:
 * - Minimal bottom-aligned OSD interface with icon-only options
 * - Keyboard shortcuts: F (Fullscreen) | W (Window) | R (Region)
 * - Arrow key navigation and Enter to execute
 * - Escape or click outside to close
 */

LazyLoader {
  id: loader
  required property var manager
  active: manager.visible

  PanelWindow {
    id: screenshotWindow

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

    property int selectedIndex: 0

    contentItem {
      focus: true

      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
          if (screenshotWindow.selectedIndex > 0) {
            screenshotWindow.selectedIndex--
          } else {
            screenshotWindow.selectedIndex = loader.manager.screenshotOptions.length - 1
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
          if (screenshotWindow.selectedIndex < loader.manager.screenshotOptions.length - 1) {
            screenshotWindow.selectedIndex++
          } else {
            screenshotWindow.selectedIndex = 0
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          var selected = loader.manager.screenshotOptions[screenshotWindow.selectedIndex]
          loader.manager.executeScreenshotOption(selected)
          event.accepted = true
        }
        else if (event.key === Qt.Key_F) {
          loader.manager.executeScreenshotOption(loader.manager.screenshotOptions[0])
          event.accepted = true
        }
        else if (event.key === Qt.Key_W) {
          loader.manager.executeScreenshotOption(loader.manager.screenshotOptions[1])
          event.accepted = true
        }
        else if (event.key === Qt.Key_R) {
          loader.manager.executeScreenshotOption(loader.manager.screenshotOptions[2])
          event.accepted = true
        }
      }
    }

    Rectangle {
      anchors.fill: parent
      color: "#000000"
      opacity: 0.3

      MouseArea {
        anchors.fill: parent
        onClicked: {
          loader.manager.visible = false
        }
      }
    }

    // Compact OSD panel at bottom center
    Rectangle {
      id: container
      x: (parent.width - 300) / 2
      y: parent.height - 60 - 24
      width: 300
      height: 60
      radius: Theme.radius.full
      color: Theme.surface_container_transparent_medium
      border.width: 0.5
      border.color: Theme.surface_container_high

      MouseArea {
        anchors.fill: parent
      }

      GridLayout {
        anchors {
          fill: parent
          margins: Theme.padding.sm
        }
        columns: 3
        columnSpacing: Theme.spacing.sm

        Repeater {
          model: loader.manager.screenshotOptions

          delegate: Rectangle {
            required property var modelData
            required property int index

            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radius.full

            color: index === screenshotWindow.selectedIndex ?
                   Theme.tertiary_container : "transparent"

            Text {
              anchors.centerIn: parent
              text: modelData.icon
              color: index === screenshotWindow.selectedIndex ?
                     Theme.on_tertiary_container : Theme.on_surface
              font.pixelSize: 18
              font.family: Theme.typography.fontFamily

              Behavior on color {
                ColorAnimation {
                  duration: 200
                  easing.type: Easing.OutCubic
                }
              }
            }

            MouseArea {
              id: optionMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor

              onClicked: {
                screenshotWindow.selectedIndex = index
                loader.manager.executeScreenshotOption(modelData)
              }

              onEntered: {
                screenshotWindow.selectedIndex = index
              }
            }
          }
        }
      }
    }
  }
}
