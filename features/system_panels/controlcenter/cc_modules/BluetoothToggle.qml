import QtQuick
import "../../../../shared/components/Buttons"

IconButton {
  id: root
  required property var systemState

  icon: systemState.bluetooth.bluetoothIcon
  title: "Bluetooth"
  subtitle: systemState.bluetooth.powered ? "On" : "Off"

  isStateful: true
  isActive: systemState.bluetooth.powered

  onClicked: systemState.bluetooth.togglePower()
}
