import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../theme"

Item {
  id: root
  
  required property var captureSource
  
  // Background screenshot for blur
  ScreencopyView {
    id: screenshotSource
    width: root.width
    height: root.height
    visible: false
    captureSource: root.captureSource
    
    // Capture a single frame when the component is created
    Component.onCompleted: captureFrame()
  }
  
  // Blurred background layer
  MultiEffect {
    id: blurredBackground
    source: screenshotSource
    anchors.fill: parent
    visible: screenshotSource.hasContent
    opacity: 0
    
    blurEnabled: true
    blur: 1.0
    blurMax: 64
    blurMultiplier: 1.0
    autoPaddingEnabled: false
    
    // Optional: add slight desaturation for a nicer effect
    saturation: -0.3
    brightness: -0.1
    
    // Smooth fade-in animation
    Behavior on opacity {
      NumberAnimation {
        duration: 400
        easing.type: Easing.OutCubic
      }
    }
    
    // Trigger fade-in when content is ready
    onVisibleChanged: {
      if (visible) opacity = 1.0
    }
  }
}
