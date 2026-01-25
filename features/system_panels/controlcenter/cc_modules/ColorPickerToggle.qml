import QtQuick
import QtQuick.Layouts
import "../../../../shared/components/Buttons"

Item {
  id: root
  required property var launcherManager
  
  Layout.fillWidth: true
  Layout.preferredHeight: 64
  
  MaterialButton {
    anchors.centerIn: parent
    icon: "󰈊"
    onClicked: launcherManager.launchColorPicker()
  }
}