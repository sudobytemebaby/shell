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
    icon: systemState.network.getNetworkIcon()
    isActive: systemState.network.wifiEnabled && systemState.network.wifiConnected
    onClicked: systemState.network.toggleWifi()
  }
}
