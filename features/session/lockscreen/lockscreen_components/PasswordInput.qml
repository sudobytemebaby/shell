import QtQuick
import "../../../../shared/theme"

// ============================================================================
// PASSWORD INPUT (Visual Component)
// Displays password dots and placeholder text
// Note: Actual TextInput is in LockscreenDisplay.qml for proper focus handling
// ============================================================================

Item {
  id: root

  required property var lockContext      // Reference to LockContext for state
  required property TextInput passwordInput  // Reference to actual input

  width: 120
  height: 40

  // ============================================================================
  // SHAKE ANIMATION (triggered on failed authentication)
  // ============================================================================

  SequentialAnimation {
    id: shakeAnimation
    NumberAnimation {
      target: root
      property: "anchors.horizontalCenterOffset"
      from: 0; to: -10
      duration: 50
      easing.type: Easing.OutCubic
    }
    NumberAnimation {
      target: root
      property: "anchors.horizontalCenterOffset"
      from: -10; to: 10
      duration: 100
      easing.type: Easing.InOutCubic
    }
    NumberAnimation {
      target: root
      property: "anchors.horizontalCenterOffset"
      from: 10; to: 0
      duration: 50
      easing.type: Easing.InCubic
    }
  }

  function triggerShake() {
    shakeAnimation.restart()
  }

  // Connect to lockContext failed signal to trigger shake
  Connections {
    target: root.lockContext ?? null
    enabled: root.lockContext !== null && root.lockContext !== undefined
    function onFailed() {
      root.triggerShake()
    }
  }

  Item {
    anchors.centerIn: parent
    width: 200
    height: 40

    // Visual password dots
    Row {
      anchors.centerIn: parent
      spacing: Theme.spacing.xs
      visible: root.passwordInput ? root.passwordInput.text.length > 0 : false

      Repeater {
        model: 20 // Max password length

        Rectangle {
          width: 8
          height: 8
          radius: 4
          color: Theme.on_surface
          visible: root.passwordInput ? index < root.passwordInput.text.length : false
          opacity: 0
          scale: 0.5

          onVisibleChanged: {
            if (visible) {
              opacity = (root.lockContext && root.lockContext.unlockInProgress) ? 0.5 : 0.8
              scale = 1.0
            } else {
              opacity = 0
              scale = 0.5
            }
          }

          Behavior on opacity {
            NumberAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }

          Behavior on scale {
            NumberAnimation {
              duration: 200
              easing.type: Easing.OutBack
            }
          }
        }
      }
    }

    // Placeholder text
    Text {
      anchors.centerIn: parent
      visible: root.passwordInput ? root.passwordInput.text.length === 0 : true
      text: "Password"
      color: {
        if (root.lockContext) {
          if (root.lockContext.showFailure) return Theme.error
          if (root.lockContext.unlockInProgress) return "transparent"
        }
        return Theme.on_surface_variant
      }
      font.family: Theme.typography.fontFamily
      font.pixelSize: Theme.typography.sm
      opacity: 0.5

      Behavior on color {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
    }
  }
}
