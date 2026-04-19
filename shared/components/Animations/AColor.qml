import QtQuick
import "../../theme"

Behavior {
  enabled: !Config.animations.disabled
  ColorAnimation {
    duration: Config.animations.slow
    easing.type: Easing.OutCubic
  }
}
