import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components/Navigation"

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

    // When this window is fully destroyed by LazyLoader (because manager.visible
    // went false), notify the manager it's safe to run interactive tools like slurp.
    // This is the correct place — fires exactly once when the overlay is truly gone.
    Component.onDestruction: {
      loader.manager.windowClosed()
    }

    property int selectedIndex: 0

    KeyboardNavigationHandler {
      id: navHandler
      currentIndex: screenshotWindow.selectedIndex
      itemCount: loader.manager.screenshotOptions.length
      columns: 3
      wrapAround: true

      onNavigateUp: newIndex => screenshotWindow.selectedIndex = newIndex
      onNavigateDown: newIndex => screenshotWindow.selectedIndex = newIndex
      onNavigateLeft: newIndex => screenshotWindow.selectedIndex = newIndex
      onNavigateRight: newIndex => screenshotWindow.selectedIndex = newIndex

      onSelectCurrent: {
        var selected = loader.manager.screenshotOptions[screenshotWindow.selectedIndex]
        loader.manager.executeScreenshotOption(selected)
      }

      onClose: loader.manager.visible = false
    }

    contentItem {
      focus: true

      Keys.onPressed: event => {
        // Custom shortcuts
        if (event.key === Qt.Key_F) {
          loader.manager.executeScreenshotOption(loader.manager.screenshotOptions[0])
          event.accepted = true
          return
        }
        else if (event.key === Qt.Key_W) {
          loader.manager.executeScreenshotOption(loader.manager.screenshotOptions[1])
          event.accepted = true
          return
        }
        else if (event.key === Qt.Key_R) {
          loader.manager.executeScreenshotOption(loader.manager.screenshotOptions[2])
          event.accepted = true
          return
        }

        // Delegate standard navigation to handler
        navHandler.handleKeyPress(event)
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
      color: Theme.surface_transparent_medium
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
