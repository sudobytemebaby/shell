import QtQuick
import Quickshell
import QtQuick.Layouts
import "../../../../shared/theme"

Item {
  id: root

  // Reference to system state
  required property var systemState

  property string icon: "󰖁"
  property string volume: "N/A"
  property string device: "Unknown"
  property bool hovered: false 

  implicitWidth: hovered ? rowLayout.implicitWidth : iconText.implicitWidth
  implicitHeight: Theme.barHeight

  // Smooth width transition
  Behavior on implicitWidth {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }

  RowLayout {
    id: rowLayout
    anchors.centerIn: parent
    spacing: Theme.spacing.sm

    Text {
      id: iconText
      text: icon
      color: Theme.on_surface
      font.pixelSize: Theme.typography.sm
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      id: volumeText
      text: volume
      color: Theme.on_surface_variant
      font.pixelSize: Theme.typography.sm
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      visible: hovered && volume !== "N/A"
      opacity: hovered ? 1.0 : 0.0
      
      Behavior on opacity {
        NumberAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true

    onEntered: root.hovered = true
    onExited: root.hovered = false 

    cursorShape: Qt.PointingHandCursor

    onClicked: {
      Quickshell.execDetached({
        command: ["sh", "-c", "~/.local/bin/tui-audio"]
      })
    }
  }

  // ============================================================================
  // VOLUME STATE MONITORING (using SystemStateManager)
  // ============================================================================
  
  Connections {
    target: root.systemState.volume
    enabled: root.systemState && root.systemState.volume
    
    function onVolumeChanged() {
      updateAudioDisplay()
    }
    
    function onVolumeMutedChanged() {
      updateAudioDisplay()
    }
    
    function onDeviceNameChanged() {
      updateAudioDisplay()
    }
    
    function onDeviceTypeChanged() {
      updateAudioDisplay()
    }
    
    function onIsHeadphonesChanged() {
      updateAudioDisplay()
    }
  }
  
  // Update audio display
  function updateAudioDisplay() {
    var volumeModule = root.systemState.volume
    
    if (!volumeModule) {
      root.icon = "󰖁"
      root.volume = "N/A"
      root.device = "Unknown"
      return
    }
    
    // Get icon from volume module (handles mute, device type, and volume level)
    root.icon = volumeModule.getVolumeIcon(volumeModule.volume, volumeModule.volumeMuted)
    
    // Format volume percentage
    if (volumeModule.volumeMuted) {
      root.volume = "Muted"
    } else {
      root.volume = Math.round(volumeModule.volume * 100) + "%"
    }
    
    // Get device name
    root.device = volumeModule.deviceName || "Unknown"
  }
  
  // Initial update
  Component.onCompleted: {
    updateAudioDisplay()
  }
}
