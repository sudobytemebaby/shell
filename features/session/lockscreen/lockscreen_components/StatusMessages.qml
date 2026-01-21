import QtQuick
import "../../../../shared/theme"

Column {
  id: root
  
  required property bool isAuthenticating
  required property bool authSuccess
  required property bool errorVisible
  required property string errorText
  
  spacing: Theme.spacing.sm
  
  // Error message
  Text {
    id: errorMessage
    anchors.horizontalCenter: parent.horizontalCenter
    text: root.errorText
    color: Theme.error
    font.family: Theme.typography.fontFamily
    font.pixelSize: Theme.typography.md
    visible: root.errorVisible
    opacity: visible ? 1.0 : 0
    
    Behavior on opacity {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
  }
  
  // Authenticating indicator
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    text: "󰔟 Authenticating..."
    color: Theme.on_surface_variant
    font.family: Theme.typography.fontFamily
    font.pixelSize: Theme.typography.sm
    visible: root.isAuthenticating && !root.authSuccess
    opacity: 0.7
    
    SequentialAnimation on opacity {
      running: root.isAuthenticating && !root.authSuccess
      loops: Animation.Infinite
      NumberAnimation { from: 0.7; to: 0.3; duration: 600; easing.type: Easing.InOutCubic }
      NumberAnimation { from: 0.3; to: 0.7; duration: 600; easing.type: Easing.InOutCubic }
    }
  }
  
  // Success message
  Item {
    anchors.horizontalCenter: parent.horizontalCenter
    width: successText.width
    height: successText.height
    visible: root.authSuccess
    opacity: 0
    scale: 0.5
    
    Behavior on opacity {
      NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }
    
    Behavior on scale {
      NumberAnimation { duration: 400; easing.type: Easing.OutBack }
    }
    
    onVisibleChanged: {
      if (visible) {
        opacity = 1.0
        scale = 1.0
      } else {
        opacity = 0
        scale = 0.5
      }
    }
    
    Text {
      id: successText
      anchors.centerIn: parent
      text: " Unlocked"
      color: Theme.primary
      font.family: Theme.typography.fontFamily
      font.pixelSize: Theme.typography.lg
      font.weight: Theme.typography.weightBold
    }
  }
}
