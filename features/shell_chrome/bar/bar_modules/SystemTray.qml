import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../../../../shared/theme"

/**
 * SystemTray - Displays system tray icons
 *
 * Shows all registered StatusNotifierItem icons from applications.
 * Left-click activates the item, right-click opens its context menu.
 * Scroll events are forwarded to items that support them (e.g., volume).
 */

Item {
  id: root

  implicitWidth: trayLayout.implicitWidth
  implicitHeight: Theme.barHeight

  // Track items from SystemTray service
  property var trayItems: SystemTray.items.values || []

  // Hide when no tray items are available
  visible: trayItems.length > 0

  // Update when items change
  Connections {
    target: SystemTray.items
    function onValuesChanged() {
      root.trayItems = SystemTray.items.values || []
    }
  }

  RowLayout {
    id: trayLayout
    anchors.centerIn: parent
    spacing: Theme.spacing.sm

    Repeater {
      model: root.trayItems

      delegate: Item {
        id: trayItem

        required property var modelData

        implicitWidth: Theme.typography.sm + 4
        implicitHeight: Theme.barHeight

        Image {
          id: trayIcon
          anchors.centerIn: parent
          width: Theme.typography.sm
          height: Theme.typography.sm
          sourceSize.width: Theme.typography.sm * 2
          sourceSize.height: Theme.typography.sm * 2
          smooth: true
          asynchronous: true
          visible: status === Image.Ready

          source: {
            let icon = modelData?.icon || ""
            if (!icon) return ""

            // Handle icon paths with ?path= format
            if (icon.includes("?path=")) {
              const chunks = icon.split("?path=")
              const name = chunks[0]
              const path = chunks[1]
              const fileName = name.substring(name.lastIndexOf("/") + 1)
              return "file://" + path + "/" + fileName
            }
            return icon
          }
        }

        // Fallback text icon when image fails to load
        Text {
          id: fallbackIcon
          anchors.centerIn: parent
          text: "󰀻"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.sm
          font.family: Theme.fontFamily
          visible: trayIcon.status === Image.Error || trayIcon.status === Image.Null || !modelData?.icon
        }

        // Menu anchor for displaying the tray item's context menu
        QsMenuAnchor {
          id: menuAnchor
          menu: modelData?.menu || null
          anchor.window: trayItem.QsWindow.window
        }

        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
          cursorShape: Qt.PointingHandCursor

          onClicked: mouse => {
            if (!modelData) return

            if (mouse.button === Qt.LeftButton) {
              if (modelData.onlyMenu && modelData.hasMenu) {
                menuAnchor.open()
              } else {
                modelData.activate()
              }
            } else if (mouse.button === Qt.RightButton) {
              if (modelData.hasMenu) {
                menuAnchor.open()
              } else if (modelData.secondaryActivate) {
                modelData.secondaryActivate()
              }
            } else if (mouse.button === Qt.MiddleButton) {
              if (modelData.secondaryActivate) {
                modelData.secondaryActivate()
              }
            }
          }

          onWheel: wheel => {
            if (!modelData?.scroll) return
            var delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x
            var horizontal = wheel.angleDelta.y === 0
            modelData.scroll(delta / 120, horizontal)
          }
        }
      }
    }
  }
}
