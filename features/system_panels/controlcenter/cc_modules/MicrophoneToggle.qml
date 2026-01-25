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
    icon: systemState.volume.micIcon
    isActive: !systemState.volume.micMuted
    onClicked: systemState.volume.toggleMicMute()
  }
}
