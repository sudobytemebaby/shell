import QtQuick

BarStatusModule {
  id: root

  required property var systemState

  icon: "󰂲"
  status: "Off"

  onClicked: root.systemState.bluetooth.openManager()

  Connections {
    target: root.systemState.bluetooth
    enabled: root.systemState && root.systemState.bluetooth
    function onPoweredChanged() { updateDisplay() }
    function onHasConnectedDeviceChanged() { updateDisplay() }
    function onConnectedDeviceNameChanged() { updateDisplay() }
    function onReadyChanged() { updateDisplay() }
  }

  Component.onCompleted: updateDisplay()

  function updateDisplay() {
    var bt = root.systemState.bluetooth
    if (!bt || !bt.ready) {
      root.icon = "󰂲"
      root.status = "N/A"
      return
    }
    root.icon = bt.bluetoothIcon
    root.status = bt.statusText
  }
}
