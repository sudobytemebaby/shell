import QtQuick.Effects
import "../../theme"

MultiEffect {
  shadowEnabled: true
  shadowColor: Config.shadows.color
  shadowBlur: Config.shadows.blur
  shadowVerticalOffset: Config.shadows.verticalOffset
  shadowHorizontalOffset: Config.shadows.horizontalOffset
  shadowOpacity: 1.0
  shadowScale: 1.02
}
