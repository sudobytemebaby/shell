import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"
import "../../../../shared/components/Animations"

Item {
  id: root

  required property string icon
  property string status: "N/A"
  property color iconColor: Theme.on_surface
  property string noDataValue: "N/A"

  signal clicked()

  property bool hovered: false

  implicitWidth: hovered ? rowLayout.implicitWidth : iconText.implicitWidth
  implicitHeight: Config.bar.height

  AExpand on implicitWidth {}

  RowLayout {
    id: rowLayout
    anchors.centerIn: parent
    spacing: Config.spacing.sm

    Text {
      id: iconText
      text: root.icon
      color: root.iconColor
      font.pixelSize: Config.typography.sm
      font.family: Config.typography.sans
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      text: root.status
      color: Theme.on_surface_variant
      font.pixelSize: Config.typography.sm
      font.family: Config.typography.sans
      verticalAlignment: Text.AlignVCenter
      visible: root.hovered && root.status !== root.noDataValue
      opacity: root.hovered ? 1.0 : 0.0

      AFade on opacity {}
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: root.hovered = true
    onExited: root.hovered = false
    onClicked: root.clicked()
  }
}
