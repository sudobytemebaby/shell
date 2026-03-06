import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../../shared/theme"

Item {
  id: root

  implicitWidth: buttonText.implicitWidth
  implicitHeight: Theme.barHeight

  Text {
    id: buttonText
    anchors.centerIn: parent
    text: "󰐥"
    color: mouseArea.containsMouse ? Theme.error : Theme.on_surface
    font.pixelSize: Theme.typography.sm
    verticalAlignment: Text.AlignVCenter
    
    Behavior on color {
      ColorAnimation {
        duration: 200
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
      Quickshell.callIpc("powermenu", "toggle")
    }
  }
}
