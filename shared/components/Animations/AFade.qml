import QtQuick
import "../../theme"

Behavior {
  enabled: !Config.animations.disabled
  NumberAnimation {
    duration: Config.animations.normal
    easing.type: Easing.OutCubic
  }
}
