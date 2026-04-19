import QtQuick
import "../../../../shared/theme"

BarStatusModule {
  id: root

  required property var systemState

  icon: " "
  status: "N/A"

  onClicked: {
    // no-op for now
  }

  Connections {
    target: root.systemState.battery
    enabled: root.systemState && root.systemState.battery
    function onPercentageChanged() { updateDisplay() }
    function onIsChargingChanged() { updateDisplay() }
    function onReadyChanged() { updateDisplay() }
  }

  Component.onCompleted: updateDisplay()

  function updateDisplay() {
    var battery = root.systemState.battery
    if (!battery || !battery.ready || !battery.isLaptopBattery) {
      root.icon = ""
      root.status = "N/A"
      return
    }
    root.icon = battery.batteryIcon
    root.status = Math.round(battery.percentage * 100) + "%"
    root.iconColor = (battery.percentage <= 0.1 && !battery.isCharging) ? Theme.error : Theme.on_surface
  }
}
