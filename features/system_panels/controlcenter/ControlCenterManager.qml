import QtQuick
import Quickshell
import Quickshell.Io
import "managers" as Managers

Scope {
  id: manager

  property bool visible: false

  required property var systemState
  required property var matugen

  Managers.MediaManager {
    id: mediaManager
    controlCenterVisible: manager.visible
    mprisState: manager.systemState.mpris
  }

  Managers.QuickActionsManager {
    id: quickActionsManager
    matugen: manager.matugen
    controlCenter: manager
  }

  readonly property var media: mediaManager
  readonly property var quickActions: quickActionsManager

  IpcHandler {
    target: "controlcenter"

    function toggle(): void {
      manager.visible = !manager.visible
    }

    function open(): void {
      manager.visible = true
    }

    function close(): void {
      manager.visible = false
    }
  }
}