import QtQuick
import "../../../../shared/components"

IconButton {
  required property var systemState
  
  icon: systemState.bluetooth.powered ? "󰂯" : "󰂲"
  title: "Bluetooth"
  subtitle: systemState.bluetooth.getStatusText()
  
  isStateful: true  // This is a toggle button
  isActive: systemState.bluetooth.powered
  
  onClicked: systemState.bluetooth.togglePower()
}
