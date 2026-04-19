import QtQuick

BarStatusModule {
  id: root

  required property var systemState

  icon: "󰖪"
  status: "—"
  noDataValue: "—"

  onClicked: root.systemState.network.openNetworkManager()

  Connections {
    target: root.systemState.network
    enabled: root.systemState && root.systemState.network
    function onWifiSignalStrengthChanged() { updateDisplay() }
    function onInterfaceNameChanged() { updateDisplay() }
    function onWifiEnabledChanged() { updateDisplay() }
    function onWifiConnectedChanged() { updateDisplay() }
    function onConnectionTypeChanged() { updateDisplay() }
    function onWifiSsidChanged() { updateDisplay() }
    function onReadyChanged() { updateDisplay() }
  }

  Component.onCompleted: updateDisplay()

  function updateDisplay() {
    var network = root.systemState.network
    if (!network || !network.ready) {
      root.icon = "󰖪"
      root.status = "—"
      return
    }
    root.icon = network.networkIcon
    if (network.connectionType === "wifi" && network.wifiConnected)
      root.status = network.wifiSsid || network.interfaceName
    else if (network.connectionType === "ethernet")
      root.status = "Ethernet"
    else if (!network.wifiEnabled)
      root.status = "Disabled"
    else
      root.status = "Disconnected"
  }
}
