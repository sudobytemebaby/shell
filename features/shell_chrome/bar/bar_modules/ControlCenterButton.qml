import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"

Item {
  id: root

  // Reference to the control center manager
  required property var controlCenterManager

  implicitWidth: buttonText.implicitWidth
  implicitHeight: Theme.barHeight

  Text {
    id: buttonText
    anchors.centerIn: parent
    text: "󰣇"  // Settings/control icon
    color: mouseArea.containsMouse ? Qt.darker(Theme.accent, 1.3) : Theme.accent
    font.pixelSize: Theme.fontSizeS
    font.family: Theme.fontFamily
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
      controlCenterManager.visible = !controlCenterManager.visible
    }
  }
}
