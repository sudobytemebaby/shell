import QtQuick
import QtQuick.Layouts
import "../../../../shared/components/Buttons"

Item {
  id: root
  required property var nightLightManager
  
  Layout.fillWidth: true
  Layout.preferredHeight: 64
  
  MaterialStateButton {
    anchors.centerIn: parent
    icon: nightLightManager.nightLightActive ? "󱩌" : "󰹏"
    isActive: nightLightManager.nightLightActive
    onClicked: nightLightManager.toggleNightLight()
  }
}