import QtQuick
import "../../theme"

Rectangle {
  id: root

  // Public API
  required property string icon
  property color bgColor: Theme.surface_container
  property color iconColor: Theme.on_surface

  // Icon size defaults to 50% of container (ratio-based)
  property real iconRatio: 0.5
  property int iconSize: Math.round(Math.min(width, height) * iconRatio)

  width: Config.sizes.iconCircle
  height: Config.sizes.iconCircle
  radius: Config.radius.full
  color: bgColor

  Text {
    // Use integer-aligned centering for crisp icon rendering
    x: Math.round((parent.width - implicitWidth) / 2)
    y: Math.round((parent.height - implicitHeight) / 2)
    text: root.icon
    color: root.iconColor
    font.pixelSize: root.iconSize
    font.family: Config.typography.sans
  }
}
