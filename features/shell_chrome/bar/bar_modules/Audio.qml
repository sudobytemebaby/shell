import QtQuick
import Quickshell

BarStatusModule {
  id: root

  required property var systemState

  icon: "󰖁"
  status: "N/A"

  onClicked: Quickshell.execDetached({ command: ["sh", "-c", "~/.local/bin/tui-audio"] })

  Connections {
    target: root.systemState.volume
    enabled: root.systemState && root.systemState.volume
    function onVolumeChanged() { updateDisplay() }
    function onVolumeMutedChanged() { updateDisplay() }
  }

  Component.onCompleted: updateDisplay()

  function updateDisplay() {
    var vol = root.systemState.volume
    if (!vol) {
      root.icon = "󰖁"
      root.status = "N/A"
      return
    }
    root.icon = vol.volumeIcon
    root.status = vol.volumeMuted ? "Muted" : Math.round(vol.volume * 100) + "%"
  }
}
