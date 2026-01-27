import QtQuick
import QtQuick.Layouts
import "../../../../shared/components/Buttons"

IconButton {
  id: root
  required property var systemState

  Layout.fillWidth: true
  Layout.preferredHeight: 68

  icon: systemState.volume.micIcon
  title: "Mic State"
  subtitle: systemState.volume.micMuted ? "Muted" : "On"
  
  isStateful: true
  isActive: !systemState.volume.micMuted
  
  onClicked: systemState.volume.toggleMicMute()
}
