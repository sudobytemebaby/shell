import QtQuick
import QtQuick.Layouts
import "../../../../shared/components/Buttons"

IconButton {
  id: root
  required property var systemState
  
  Layout.fillWidth: true
  Layout.preferredHeight: 68

  icon: systemState.bluetooth.bluetoothIcon
  title: "Bluetooth"
  subtitle: systemState.bluetooth.powered ? "On" : "Off"

  isStateful: true
  isActive: systemState.bluetooth.powered
  
  onClicked: systemState.bluetooth.togglePower()
}
