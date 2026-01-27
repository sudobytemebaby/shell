import QtQuick
import "../../../../shared/components"

SliderCard {
  id: root

  required property var systemState

  icon: "󰃠"
  label: "Brightness"
  value: systemState.brightness.brightness
  minimumValue: 0.01

  onMoved: newValue => systemState.brightness.setBrightness(newValue)
}
