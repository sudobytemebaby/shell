import QtQuick
import "../../../../shared/components"

IconButton {
  required property var systemState

  icon: systemState.volume.micIcon
  title: "Mic State"
  subtitle: systemState.volume.micMuted ? "Muted" : "Active"

  isStateful: true
  isActive: !systemState.volume.micMuted

  onClicked: systemState.volume.toggleMicMute()
}
