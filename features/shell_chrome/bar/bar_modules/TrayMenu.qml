import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../../../shared/theme"

Item {
  id: root

  property var trayItem: null
  property var anchorItem: null

  readonly property var menu: trayItem ? trayItem.menu : null

  Component.onCompleted: {
    console.log("[TrayMenu] Component loaded, trayItem:", trayItem ? trayItem.id : "null", "hasMenu:", trayItem ? trayItem.hasMenu : false)
  }

  QsMenuAnchor {
    id: menuAnchor
    menu: root.menu

    anchor {
      item: root.anchorItem
      gravity: Edges.Bottom
      rect.y: root.anchorItem ? root.anchorItem.height + 4 : 0
      rect.x: 0
    }
  }

  function open() {
    console.log("[TrayMenu] open() called for", trayItem ? trayItem.id : "null", "menu:", menu)
    menuAnchor.open()
  }

  function close() {
    console.log("[TrayMenu] close() called")
    menuAnchor.close()
  }

  function toggle() {
    if (menuAnchor.visible) {
      close()
    } else {
      open()
    }
  }
}
