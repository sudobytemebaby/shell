import QtQuick
import "../../theme"

Item {
  id: root

  // Make the Elevation item automatically fill whatever parent it's in
  anchors.fill: parent

  property Item target: parent  // Points to the visual item (card)
  property bool enabled: true

  // Shadow layers for depth
  Rectangle {
    visible: root.enabled
    anchors.fill: parent  // Fill the Elevation item itself
    anchors.margins: -2
    radius: root.target.radius + 2  // Get radius from target, not parent
    color: "transparent"
    border.width: 2
    border.color: "#15000000" 
    z: -1
    opacity: 0.6
  }

  Rectangle {
    visible: root.enabled
    anchors.fill: parent  // Fill the Elevation item itself
    anchors.margins: -3
    radius: root.target.radius + 3  // Get radius from target, not parent
    color: "transparent"
    border.width: 2
    border.color: "#10000000"
    z: -2
    opacity: 0.4
  }
}
