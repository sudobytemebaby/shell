import QtQuick.Effects

MultiEffect {
  property real blur: 1.2
  property real vOffset: 2
  property real hOffset: 0

  shadowEnabled: true
  shadowColor: "#80000000"
  shadowBlur: blur
  shadowVerticalOffset: vOffset
  shadowHorizontalOffset: hOffset
  shadowOpacity: 1.0
  shadowScale: 1.02
}
