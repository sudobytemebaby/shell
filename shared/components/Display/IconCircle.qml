import QtQuick
import "../../theme"

Rectangle {
  id: root

  // Public API
  required property string icon
  property color bgColor: Theme.surface_container
  property color iconColor: Theme.on_surface
  property int iconSize: Config.typography.lg

  width: 32
  height: 32
  radius: Config.radius.full
  color: bgColor

  Text {
    anchors.centerIn: parent
    text: root.icon
    color: root.iconColor
    font.pixelSize: root.iconSize
    font.family: Config.typography.sans
  }
}
