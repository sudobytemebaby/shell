import QtQuick
import QtQuick.Layouts
import "../../../../shared/components/Buttons"

IconButton {
  id: root
  required property var systemState

  Layout.fillWidth: true
  Layout.preferredHeight: 68

  icon: systemState.network.getNetworkIcon()
  title: "Wireless"
  subtitle: {
      if (!systemState.network.wifiEnabled) return "Off";
      if (!systemState.network.wifiConnected) return "Disconnected";
      return systemState.network.wifiSsid || "Connected";
  }
  
  isStateful: true
  isActive: systemState.network.wifiEnabled
  
  onClicked: systemState.network.toggleWifi()
}
