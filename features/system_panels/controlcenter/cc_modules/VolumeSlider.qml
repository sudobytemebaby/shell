import QtQuick
import "../../../../shared/components"

SliderCard {
  id: root

  required property var systemState

  icon: "󰕾"
  label: "Volume"
  value: systemState.volume.volume

  onMoved: newValue => systemState.volume.setVolume(newValue)
}
