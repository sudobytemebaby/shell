import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"

Item {
  id: root

  required property var powerMenuManager

  implicitWidth: buttonText.implicitWidth
  implicitHeight: Theme.barHeight

  Text {
    id: buttonText
    anchors.centerIn: parent
    text: "󰐥"
    color: mouseArea.containsMouse ? Theme.outline : Theme.on_surface
    font.pixelSize: Theme.typography.md
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
      root.powerMenuManager.visible = !root.powerMenuManager.visible
    }
  }
}
