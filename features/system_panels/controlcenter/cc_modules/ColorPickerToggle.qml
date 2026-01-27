import QtQuick
import QtQuick.Layouts
import "../../../../shared/components/Buttons"

RoundIconButton {
  id: root
  required property var launcherManager
  
  Layout.alignment: Qt.AlignHCenter

  icon: "󰈊"
  isPrimary: false // Action button, not a state toggle
  
  onClicked: launcherManager.launchColorPicker()
}