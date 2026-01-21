import QtQuick
import "../../../../shared/components"

SliderCard {
  id: root
  
  required property var audioManager
  required property var systemState
  
  icon: "󰕾"
  label: "Volume"
  value: audioManager.volume
  
  onMoved: function(newValue) {
    // Set volume through the adapter which calls systemState.volume.setVolume()
    // The Volume module's setVolume() sets changingVolume = true internally
    // which prevents OSD from appearing
    audioManager.setVolume(newValue)
  }
}
