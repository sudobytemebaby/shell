import QtQuick
import Quickshell

LazyLoader {
  id: root

  // Required: controls when the content should be shown
  required property bool show

  // Animation configuration
  property int openDuration: 250
  property int closeDuration: 150
  property real openEasingType: Easing.OutBack
  property real closeEasingType: Easing.OutQuint

  // Animation state - use this in your content to drive visual changes
  // 0 = fully closed, 1 = fully open
  property real animationProgress: 0

  // Internal state tracking
  property bool isClosing: false

  // Keep loaded while visible or animating closed
  active: show || isClosing

  // Animations wrapped in QtObject since LazyLoader doesn't support direct children
  property QtObject animations: QtObject {
    property NumberAnimation openAnimation: NumberAnimation {
      target: root
      property: "animationProgress"
      from: root.animationProgress
      to: 1
      duration: root.openDuration
      easing.type: root.openEasingType
    }

    property NumberAnimation closeAnimation: NumberAnimation {
      target: root
      property: "animationProgress"
      from: root.animationProgress
      to: 0
      duration: root.closeDuration
      easing.type: root.closeEasingType
      onFinished: {
        root.isClosing = false
      }
    }
  }

  // Watch for visibility changes
  onShowChanged: {
    if (show) {
      animations.closeAnimation.stop()
      animations.openAnimation.start()
    } else {
      animations.openAnimation.stop()
      isClosing = true
      animations.closeAnimation.start()
    }
  }

  // Public functions for manual control if needed
  function open() {
    animations.closeAnimation.stop()
    animations.openAnimation.start()
  }

  function close() {
    animations.openAnimation.stop()
    isClosing = true
    animations.closeAnimation.start()
  }
}
