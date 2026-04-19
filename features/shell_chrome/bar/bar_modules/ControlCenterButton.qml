import QtQuick
import "../../../../shared/theme"

BarToggleButton {
  required property var controlCenterManager

  icon: "󰣇"
  defaultColor: Theme.primary
  hoverColor: Theme.primary_container

  onClicked: controlCenterManager.visible = !controlCenterManager.visible
}
