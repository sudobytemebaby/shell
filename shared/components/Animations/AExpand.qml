import QtQuick
import "../../theme"

Behavior {
  enabled: !Config.animations.disabled
  NumberAnimation {
    duration: Config.animations.slow
    easing.type: Easing.OutCubic
  }
}
