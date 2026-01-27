import QtQuick
import QtQuick.Layouts
import "../../../../shared/components/Buttons"

IconButton {
  id: root
  required property var nightLightManager
  
  Layout.fillWidth: true
  Layout.preferredHeight: 68

  icon: nightLightManager.nightLightActive ? "󱩌" : "󰹏"
  title: "Night Mod"
  subtitle: nightLightManager.nightLightActive ? "On" : "Off"

  isStateful: true
  isActive: nightLightManager.nightLightActive
  
  onClicked: nightLightManager.toggleNightLight()
}
