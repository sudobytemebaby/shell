import QtQuick
import "../../../../shared/theme"

Item {
  id: root
  
  // Accept the calendar manager from bar
  required property var calendarManager
  
  implicitWidth: clock.implicitWidth
  implicitHeight: Theme.barHeight
  
  Text {
    id: clock
    anchors.centerIn: parent
    color: mouseArea.containsMouse ? Qt.darker(Theme.on_surface, 1.3) : Theme.on_surface
    font.pixelSize: Theme.typography.sm
    font.family: Theme.fontFamilyDisplay || "sans-serif"
    font.bold: false
    verticalAlignment: Text.AlignVCenter
    
    Behavior on color {
      ColorAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
    
    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: {
        clock.text = Qt.formatTime(new Date(), "hh:mm")
      }
    }
    
    Component.onCompleted: {
      clock.text = Qt.formatTime(new Date(), "hh:mm")
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
