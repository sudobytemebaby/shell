// components/TickMarks.qml
import QtQuick
import QtQuick.Layouts
import "../../theme"

Row {
  id: root

  // How many ticks (including 0% and 100%)
  property int tickCount: 11

  Layout.fillWidth: true
  height: 8
  spacing: 0

  Repeater {
    model: root.tickCount

    Item {
      width: parent.width / root.tickCount
      height: 8

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 2
        height: index % 5 === 0 ? 6 : 4   // taller every 5th tick (50%, 100%, etc.)
        color: Theme.outline
        opacity: index % 5 === 0 ? 0.8 : 0.6
      }
    }
  }
}
