import QtQuick
import "../../../../shared/theme"
import "../../../../shared/components/Animations"

Rectangle {
  id: root
  
  required property var calendarManager
  
  radius: Config.radius.full
  color: mouseArea.containsMouse ? Qt.darker(Theme.primary_container, 1.2) : Theme.primary_container
  
  scale: mouseArea.pressed ? 0.95 : 1.0
  
  AColor on color {}
  
  AScale on scale {}
  
  Text {
    anchors.centerIn: parent
    text: "Go to Today"
    color: Theme.on_primary_container
    font.pixelSize: Config.typography.md
    font.family: Config.typography.sans
    font.weight: Config.typography.weightMedium
    opacity: mouseArea.containsMouse ? 0.7 : 1
    
    AColor on color {}
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
