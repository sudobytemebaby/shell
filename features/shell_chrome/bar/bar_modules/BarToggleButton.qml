import QtQuick
import "../../../../shared/theme"
import "../../../../shared/components/Animations"

Item {
  id: root

  required property string icon
  property color defaultColor: Theme.on_surface
  property color hoverColor: Theme.outline
  property int fontSize: Config.typography.sm

  signal clicked()

  implicitWidth: buttonText.implicitWidth
  implicitHeight: Config.bar.height

  Text {
    id: buttonText
    anchors.centerIn: parent
    text: root.icon
    color: mouseArea.containsMouse ? root.hoverColor : root.defaultColor
    font.pixelSize: root.fontSize
    verticalAlignment: Text.AlignVCenter

    AColor on color {}
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
