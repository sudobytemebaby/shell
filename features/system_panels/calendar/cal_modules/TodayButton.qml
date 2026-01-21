import QtQuick
import "../../../../shared/theme"

Rectangle {
  id: root
  
  required property var calendarManager
  
  radius: Theme.radius.full
  color: mouseArea.containsMouse ? Qt.darker(Theme.primary_container, 1.2) : Theme.primary_container
  
  scale: mouseArea.pressed ? 0.95 : 1.0
  
  Behavior on color {
    ColorAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }
  
  Behavior on scale {
    NumberAnimation {
      duration: 100
      easing.type: Easing.OutCubic
    }
  }
  
  Text {
    anchors.centerIn: parent
    text: "Go to Today"
    color: Theme.on_primary_container
    font.pixelSize: Theme.typography.md
    font.family: Theme.typography.fontFamily
    font.weight: Theme.typography.weightMedium
    opacity: mouseArea.containsMouse ? 0.7 : 1
    
    Behavior on color {
      ColorAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      root.calendarManager.goToToday()
    }
  }
}
