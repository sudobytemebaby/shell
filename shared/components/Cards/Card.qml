import QtQuick
import "../../theme"
import "../../components"

Rectangle {
  id: root

  property alias radius: root.radius
  property alias color: root.color
  property alias border: root.border

  property int padding: Theme.padding.lg

  default property alias contentItem: content.data

  radius: Theme.radius.xl
  //color: Theme.surface_container_low
  color: "transparent"

  border.width: 0
  border.color: Theme.surface_container_high

  // Content area
  Item {
    id: content
    anchors.fill: parent
    anchors.margins: root.padding
  }
}
