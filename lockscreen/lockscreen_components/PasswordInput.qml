import QtQuick
import Quickshell.Services.Pam
import "../../theme"

Rectangle {
  id: root
  
  required property var pam
  required property bool isAuthenticating
  required property bool authSuccess
  required property bool pamNeedsRestart
  
  signal authenticationRequested(string password)
  signal pamRestartNeeded()
  signal errorOccurred()
  
  width: 120
  height: 40
  radius: Theme.radius.full
  color: "transparent"
  border.color: "transparent"
  border.width: 0
  opacity: authSuccess ? 0 : 1.0
  scale: authSuccess ? 0.9 : 1.0
  
  Behavior on opacity {
    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
  }
  
  Behavior on scale {
    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
  }
  
  // Shake animation on error
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
  
  function clearPassword() {
    passwordInput.text = ""
  }
  
  function focusInput() {
    passwordInput.forceActiveFocus()
  }
  
  Item {
    anchors.centerIn: parent
    width: 200
    height: 40
    
    // Hidden text input for actual password entry
    TextInput {
      id: passwordInput
      anchors.centerIn: parent
      width: parent.width
      color: "transparent"
      cursorDelegate: Item {}
      font.pixelSize: Theme.typography.sm
      font.family: Theme.typography.fontFamily
      echoMode: TextInput.Normal
      verticalAlignment: TextInput.AlignVCenter
      horizontalAlignment: TextInput.AlignHCenter
      enabled: !root.isAuthenticating && !root.authSuccess
      clip: true
      
      Component.onCompleted: {
        forceActiveFocus()
        if (!root.pam.active) {
          console.log("Starting initial PAM session")
          root.pam.start()
        } else {
          console.log("PAM already active on component load")
        }
      }
      
      Keys.onReturnPressed: {
        // Prevent multiple submissions
        if (root.isAuthenticating) {
          console.log("Already authenticating, ignoring input")
          return
        }
        
        if (text.length > 0) {
          if (root.pam.responseRequired && root.pam.active) {
            console.log("Submitting password to PAM (active:", root.pam.active, "responseRequired:", root.pam.responseRequired, ")")
            root.authenticationRequested(text)
            text = ""
          } else if (root.pam.active) {
            console.log("PAM active but not ready for response yet")
          } else {
            console.log("PAM not active, starting session")
            root.pamRestartNeeded()
          }
        }
      }
      
      Keys.onEscapePressed: {
        text = ""
        root.errorOccurred()
      }
    }
    
    // Visual password dots
    Row {
      anchors.centerIn: parent
      spacing: Theme.spacing.xs
      visible: passwordInput.text.length > 0
      
      Repeater {
        model: 20 // Max password length
        
        Rectangle {
          width: 8
          height: 8
          radius: 4
          color: Theme.on_surface
          visible: index < passwordInput.text.length
          opacity: 0
          scale: 0.5
          
          onVisibleChanged: {
            if (visible) {
              opacity = root.isAuthenticating ? 0.5 : 0.8
              scale = 1.0
            } else {
              opacity = 0
              scale = 0.5
            }
          }
          Behavior on scale {
            NumberAnimation {
              running: false
              duration: 200
              from: 0
              to: 1.0
              easing.type: Easing.Elastic
            }
          }
        }
      }
    }
    
    // Placeholder text
    Text {
      anchors.centerIn: parent
      visible: passwordInput.text.length === 0
      text: "Password"
      color: root.parent.errorVisible ? Theme.error : 
             root.isAuthenticating ? "transparent" :
             Theme.on_surface_variant
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
  
  property bool errorVisible: false
}
