import QtQuick
import Quickshell
import "../../theme"

LazyLoader {
  id: root

  // Required: controls when the content should be shown
  required property bool show

  // Scale range: content scales from scaleFrom → 1.0 on open
  property real scaleFrom: 0.88

  // Animation state (driven independently)
  property real _opacity: 0
  property real _scale: scaleFrom

  // Content bindings for consumers
  readonly property real contentScale: _scale
  readonly property real contentOpacity: _opacity

  // Internal state tracking
  property bool isClosing: false

  // Keep loaded while visible or animating closed
  active: show || isClosing

  // Animations wrapped in QtObject since LazyLoader doesn't support direct children
  property QtObject _anims: QtObject {
    // OPEN: scale + opacity in parallel, overlapping
    property ParallelAnimation openAnim: ParallelAnimation {
      NumberAnimation {
        target: root; property: "_opacity"
        from: 0; to: 1
        duration: Config.animations.slow
        easing.type: Easing.OutCubic
      }
      NumberAnimation {
        target: root; property: "_scale"
        from: root.scaleFrom; to: 1.0
        duration: Config.animations.slower
        easing.type: Easing.OutCubic
      }
    }

    // CLOSE: fast opacity fade, no scale change
    property NumberAnimation closeAnim: NumberAnimation {
      target: root; property: "_opacity"
      to: 0
      duration: Config.animations.fast
      easing.type: Easing.OutQuad
      onFinished: {
        root._scale = root.scaleFrom
        root.isClosing = false
      }
    }
  }

  onShowChanged: {
    if (show) {
      _anims.closeAnim.stop()
      _anims.openAnim.start()
    } else {
      _anims.openAnim.stop()
      isClosing = true
      _anims.closeAnim.start()
    }
  }
}
