import QtQuick
import Quickshell
import "managers" as Managers

Scope {
  id: manager

  property bool visible: false

  required property var systemState

  Managers.MediaManager {
    id: mediaManager
    controlCenterVisible: manager.visible
    mprisState: manager.systemState.mpris
  }

  readonly property var media: mediaManager
}