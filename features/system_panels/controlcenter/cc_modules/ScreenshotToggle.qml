import QtQuick
import QtQuick.Layouts
import "../../../../shared/components/Buttons"

RoundIconButton {
  id: root
  required property var launcherManager
  
  Layout.alignment: Qt.AlignHCenter

  icon: "󱣵"
  isPrimary: false
  
  onClicked: launcherManager.takeScreenshot()
}