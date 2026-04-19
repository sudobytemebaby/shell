import QtQuick
import "../../../../shared/theme"

BarToggleButton {
  required property var powerMenuManager

  icon: "󰐥"
  fontSize: Config.typography.md

  onClicked: powerMenuManager.visible = !powerMenuManager.visible
}
