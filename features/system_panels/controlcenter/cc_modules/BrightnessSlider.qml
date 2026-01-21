import QtQuick
import "../../../../shared/components"

SliderCard {
  id: root
  
  required property var brightnessManager
  required property var systemState
  
  icon: "󰃠"
  label: "Brightness"
  value: brightnessManager.brightness
  minimumValue: 0.01
  
  onMoved: function(newValue) {
    // Set brightness through the adapter which calls systemState.brightness.setBrightness()
    // The Brightness module's setBrightness() sets changingBrightness = true internally
    // which prevents OSD from appearing
    brightnessManager.setBrightness(newValue)
  }
}
