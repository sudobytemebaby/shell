import QtQuick
import "../../theme"

Behavior {
  enabled: !Config.animations.disabled
  NumberAnimation {
    duration: Config.animations.slower
    easing.type: Easing.OutCubic
  }
}
