import QtQuick
import "../theme"

Rectangle {
  id: root
  
  // Public API
  required property string icon
  signal clicked()
  
  // Optional customization
  property bool isPrimary: false  // Set true for main action button (bigger, more prominent)
  property int size: isPrimary ? 48 : 40
  
  width: size
  height: size
  radius: Theme.radius.full
  
  color: {
    if (isPrimary) {
      return mouseArea.pressed ? Qt.darker(Theme.primary, 1.2) : Theme.primary
    } else {
      return mouseArea.containsMouse ? Qt.lighter(Theme.surface_container_low, 1.3): Theme.surface_container_low_transparent_light
    }
  }
  
  border.width: isPrimary ? 0 : 1
  border.color: Theme.surface_container_high
  
  scale: mouseArea.pressed ? 0.88 : 1.0
  
  Behavior on color {
    ColorAnimation { duration: 150 }
  }
  
  Behavior on border.color {
    ColorAnimation { duration: 150 }
  }
  
  Behavior on scale {
    NumberAnimation { 
      duration: 100
      easing.type: Easing.OutCubic
    }
  }
  
  Text {
    anchors.centerIn: parent
    text: root.icon
    color: isPrimary ? Theme.on_primary : Theme.on_surface
    font.pixelSize: isPrimary ? Theme.typography.xxl : Theme.typography.xl
    font.family: Theme.typography.fontFamily
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    anchors.margins: -4  // Bigger hit area
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
