import QtQuick
import "../../theme"

Behavior {
  enabled: !Config.animations.disabled
  NumberAnimation {
    duration: Config.animations.fast
    easing.type: Easing.OutCubic
  }
}
