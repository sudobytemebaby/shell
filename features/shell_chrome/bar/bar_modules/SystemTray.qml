import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../../../../shared/theme"

Item {
  id: root

  implicitWidth: trayLayout.implicitWidth
  implicitHeight: Config.bar.height

  visible: true // DEBUG - force visible to test rendering
  // visible: SystemTray.items.values && SystemTray.items.values.length > 0

  onVisibleChanged: {
    console.log("[SystemTray] Visibility changed to:", visible, "item count:", SystemTray.items.values ? SystemTray.items.values.length : 0)
  }

  Component.onCompleted: {
    console.log("[SystemTray] Component loaded, item count:", SystemTray.items.values ? SystemTray.items.values.length : 0)
  }

  Connections {
    target: SystemTray.items
    function onObjectInsertedPost(object, index) {
      console.log("[SystemTray] Item inserted:", object.id, "icon:", object.icon, "at index:", index)
    }
    function onObjectRemovedPre(object, index) {
      console.log("[SystemTray] Item removed:", object.id, "at index:", index)
    }
  }

  RowLayout {
    id: trayLayout
    anchors.centerIn: parent
    spacing: Config.spacing.sm

    Repeater {
      model: SystemTray.items

      delegate: Item {
        id: trayItem

        implicitWidth: Config.typography.sm + 4
        implicitHeight: Config.bar.height

        Component.onCompleted: {
          console.log("[SystemTray] Delegate created for:", modelData.id, "icon:", modelData.icon)
        }

        Image {
          id: trayIcon
          anchors.centerIn: parent
          width: Config.typography.sm
          height: Config.typography.sm
          sourceSize.width: Config.typography.sm * 2
          sourceSize.height: Config.typography.sm * 2
          smooth: true
          asynchronous: true
          source: modelData.icon || ""
          
          onStatusChanged: {
            console.log("[SystemTray] Icon status for", modelData.id, ":", status, "source:", source)
          }
        }

        Text {
          id: fallbackIcon
          anchors.centerIn: parent
          text: "󰀻"
          color: Theme.on_surface
          font.pixelSize: Config.typography.sm
          font.family: Config.typography.sans
          visible: trayIcon.status === Image.Error || trayIcon.status === Image.Null || !modelData.icon
        }

        TrayMenu {
          id: trayMenu
          trayItem: modelData
          anchorItem: trayItem
        }

        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
          cursorShape: Qt.PointingHandCursor

          onPressed: mouse => {
            console.log("[SystemTray] Mouse pressed on", modelData.id, "button:", mouse.button)
            if (mouse.button === Qt.RightButton) {
              if (modelData.hasMenu) {
                console.log("[SystemTray] Opening menu for", modelData.id)
                trayMenu.open()
              } else if (modelData.secondaryActivate) {
                modelData.secondaryActivate()
              }
            }
          }

          onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
              if (modelData.onlyMenu && modelData.hasMenu) {
                trayMenu.open()
              } else {
                modelData.activate()
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
