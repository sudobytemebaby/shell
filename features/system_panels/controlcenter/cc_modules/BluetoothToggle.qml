import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"

Item {
  id: root
  required property var systemState
  
  Layout.fillWidth: true
  Layout.preferredHeight: 64
  
  MaterialStateButton {
    anchors.centerIn: parent
    icon: systemState.bluetooth.bluetoothIcon
    isActive: systemState.bluetooth.powered
    onClicked: systemState.bluetooth.togglePower()
  }
}
