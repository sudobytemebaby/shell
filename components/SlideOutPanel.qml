import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"

/**
 * SlideOutPanel - A panel that slides out from a bar edge
 * Inspired by Noctalia shell's SmartPanel pattern
 */
Item {
  id: root

  // Required properties
  required property bool show
  property Component panelContent: null

  // Panel dimensions
  property real preferredWidth: 360
  property real preferredHeight: 630

  // Bar configuration
  property string barPosition: "top" // "top", "bottom", "left", "right"
  property real barHeight: Theme.barHeight
  property real barMargin: Theme.spacingM

  // Animation configuration
  property int openDuration: 300
  property int closeDuration: 200

  // Internal state
  property bool isPanelOpen: false
  property bool isPanelVisible: false
  property bool isClosing: false
  property bool sizeAnimationComplete: false

  // Signals
  signal opened()
  signal closed()

  // Control functions
  function open() {
    isPanelOpen = true
    isPanelVisible = true
    isClosing = false
    sizeAnimationComplete = false
  }

  function close() {
    isClosing = true
    sizeAnimationComplete = false
  }

  // Watch for show property changes
  onShowChanged: {
    if (show && (!isPanelOpen || isClosing)) {
      open()
    } else if (!show && isPanelOpen && !isClosing) {
      close()
    }
  }

  // Finalize close after animations complete
  function finalizeClose() {
    isPanelOpen = false
    isPanelVisible = false
    isClosing = false
    closed()
  }

  PanelWindow {
    id: panelWindow

    // Position based on bar location
    anchors {
      top: barPosition === "top"
      bottom: barPosition === "bottom"
      left: barPosition === "left" || barPosition === "top" || barPosition === "bottom"
      right: barPosition === "right"
    }

    margins {
      top: barPosition === "top" ? barMargin + barHeight : barMargin
      bottom: barPosition === "bottom" ? barMargin + barHeight : barMargin
      left: barMargin
      right: barMargin
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: (root.isPanelOpen && !root.isClosing) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: "transparent"
    mask: null

    visible: root.isPanelVisible

    implicitWidth: root.preferredWidth
    implicitHeight: root.preferredHeight

    Component.onCompleted: {
      exclusiveZone = 0
    }

    contentItem {
      focus: true

      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          root.close()
          event.accepted = true
        }
      }
    }

    // Panel background with slide animation
    Item {
      id: panelContainer
      anchors.fill: parent

      // Calculate animation properties based on bar position
      readonly property bool animateHeight: barPosition === "top" || barPosition === "bottom"
      readonly property bool animateWidth: barPosition === "left" || barPosition === "right"
      readonly property bool animateFromEnd: barPosition === "bottom" || barPosition === "right"

      // Target dimensions
      readonly property real targetWidth: parent.width
      readonly property real targetHeight: parent.height

      // Current animated dimensions
      readonly property real currentWidth: {
        if (!animateWidth) return targetWidth
        if (isClosing && sizeAnimationComplete) return 0
        if (isPanelVisible) return targetWidth
        return 0
      }

      readonly property real currentHeight: {
        if (!animateHeight) return targetHeight
        if (isClosing && sizeAnimationComplete) return 0
        if (isPanelVisible) return targetHeight
        return 0
      }

      width: currentWidth
      height: currentHeight

      // Position based on animation direction
      x: {
        if (!animateWidth) return 0
        if (animateFromEnd) {
          return targetWidth - currentWidth
        }
        return 0
      }

      y: {
        if (!animateHeight) return 0
        if (animateFromEnd) {
          return targetHeight - currentHeight
        }
        return 0
      }

      // Opacity animation
      opacity: {
        if (isClosing) return 0
        if (isPanelVisible && sizeAnimationComplete) return 1
        return 0
      }

      Behavior on width {
        NumberAnimation {
          duration: root.isClosing ? root.closeDuration : root.openDuration
          easing.type: Easing.OutCubic

          onRunningChanged: {
            if (!running && root.isClosing && panelContainer.currentWidth === 0) {
              Qt.callLater(root.finalizeClose)
            }
          }
        }
      }

      Behavior on height {
        NumberAnimation {
          duration: root.isClosing ? root.closeDuration : root.openDuration
          easing.type: Easing.OutCubic

          onRunningChanged: {
            if (!running && root.isClosing && panelContainer.currentHeight === 0) {
              Qt.callLater(root.finalizeClose)
            }
          }
        }
      }

      Behavior on opacity {
        NumberAnimation {
          duration: root.isClosing ? 150 : 200
          easing.type: Easing.OutQuad
        }
      }

      // Load panel content
      Loader {
        id: contentLoader
        anchors.fill: parent
        sourceComponent: root.panelContent
        active: root.isPanelOpen

        onLoaded: {
          // Trigger visibility and animations
          Qt.callLater(function() {
            root.isPanelVisible = true
            opacityTrigger.start()
            root.opened()
          })
        }
      }
    }

    // Timer to trigger opacity fade after size animation starts
    Timer {
      id: opacityTrigger
      interval: root.openDuration * 0.4
      repeat: false
      onTriggered: {
        root.sizeAnimationComplete = true
      }
    }
  }
}
