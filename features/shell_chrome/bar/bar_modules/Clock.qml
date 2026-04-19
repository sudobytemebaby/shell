import QtQuick
import Quickshell
import "../../../../shared/theme"
import "../../../../shared/components/Animations"

Item {
  id: root
  
  // Accept the calendar manager from bar
  required property var calendarManager
  
  implicitWidth: clock.implicitWidth
  implicitHeight: Config.bar.height
  
  Text {
    id: clock
    anchors.centerIn: parent
    color: mouseArea.containsMouse ? Qt.darker(Theme.on_surface, 1.3) : Theme.on_surface
    font.pixelSize: Config.typography.sm
    font.family: Config.typography.sans
    font.bold: false
    verticalAlignment: Text.AlignVCenter

    text: Qt.formatDateTime(systemClock.date, "dddd  hh:mm")
    
    AColor on color {}

    // System clock for time display
    SystemClock {
      id: systemClock
      enabled: true
      precision: SystemClock.Minutes
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      root.calendarManager.visible = !root.calendarManager.visible
    }
  }
}
