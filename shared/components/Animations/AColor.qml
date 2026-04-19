import QtQuick
import "../../theme"

Behavior {
  enabled: !Config.animations.disabled
  ColorAnimation {
    duration: Config.animations.slower
    easing.type: Easing.OutCubic
  }
}
