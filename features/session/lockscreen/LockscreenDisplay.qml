import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../../../shared/theme"
import "lockscreen_components" as Components

Scope {
  required property var manager
  
  WlSessionLock {
    id: sessionLock
    
    locked: manager.locked
    
    WlSessionLockSurface {
      id: lockSurface
      color: "transparent"
      
      // ============================================================================
      // PAM AUTHENTICATION
      // ============================================================================
      
      property bool isAuthenticating: false
      property bool pamNeedsRestart: false
      property bool authSuccess: false
      property bool errorVisible: false
      property string errorMessage: "Authentication failed"
      
      Timer {
        id: pamRestartTimer
        interval: 100
        onTriggered: {
          console.log("Restarting PAM session, active:", pam.active)
          if (!pam.active && lockSurface.pamNeedsRestart) {
            lockSurface.pamNeedsRestart = false
            pam.start()
          } else if (lockSurface.pamNeedsRestart) {
            // PAM still active, try again
            pamRestartTimer.restart()
          }
        }
      }
      
      Timer {
        id: successTimer
        interval: 800
        onTriggered: {
          manager.unlock()
        }
      }
      
      PamContext {
        id: pam
        config: "login"
        
        onActiveChanged: {
          console.log("PAM active state changed:", active)
        }
        
        onPamMessage: {
          console.log("PAM message:", message, "responseRequired:", responseRequired, "active:", active)
          if (responseRequired) {
            lockSurface.isAuthenticating = false
            passwordBox.focusInput()
          }
        }
        
        onCompleted: result => {
          console.log("PAM completed with result:", result, "Success?", result === PamResult.Success)
          
          if (result === PamResult.Success) {
            lockSurface.pamNeedsRestart = false
            lockSurface.isAuthenticating = false
            lockSurface.authSuccess = true
            lockSurface.errorVisible = false
            passwordBox.clearPassword()
            successTimer.restart()
          } else {
            // Authentication failed - show error and restart PAM
            console.log("Authentication failed, will restart PAM")
            lockSurface.isAuthenticating = false
            passwordBox.clearPassword()
            lockSurface.errorVisible = true
            lockSurface.errorMessage = "Authentication failed"
            passwordBox.triggerShake()
            errorTimer.restart()
            
            // Mark that PAM needs restart and schedule it
            lockSurface.pamNeedsRestart = true
            pamRestartTimer.restart()
            
            passwordBox.focusInput()
          }
        }
        
        onError: error => {
          console.error("PAM error:", error)
          lockSurface.isAuthenticating = false
          passwordBox.clearPassword()
          lockSurface.errorMessage = "System error: " + error
          lockSurface.errorVisible = true
          errorTimer.restart()
          
          // Mark that PAM needs restart and schedule it
          lockSurface.pamNeedsRestart = true
          pamRestartTimer.restart()
          
          passwordBox.focusInput()
        }
      }
      
      // ============================================================================
      // UI LAYOUT
      // ============================================================================
      
      // Blurred background layer
      Components.BlurredBackground {
        anchors.fill: parent
        captureSource: lockSurface.screen
      }
      
      // Dark overlay for better contrast
      Rectangle {
        id: mainOverlay
        anchors.fill: parent
        color: Theme.scrim_transparent
        opacity: 0
        
        // Smooth fade-in animation
        Behavior on opacity {
          NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
          }
        }
        
        // Fade in when lock surface is ready
        Component.onCompleted: opacity = 1.0
        
        // Click to focus password field
        MouseArea {
          anchors.fill: parent
          onClicked: passwordBox.focusInput()
        }
        
        // Time display
        Components.TimeDisplay {
          id: timeDisplay
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          anchors.verticalCenterOffset: -parent.height * 0.20
        }
        
        // Password input container at bottom
        Components.PasswordInput {
          id: passwordBox
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          anchors.bottomMargin: Theme.spacing.xl * 4
          
          pam: pam
          isAuthenticating: lockSurface.isAuthenticating
          authSuccess: lockSurface.authSuccess
          pamNeedsRestart: lockSurface.pamNeedsRestart
          errorVisible: lockSurface.errorVisible
          
          onAuthenticationRequested: password => {
            lockSurface.isAuthenticating = true
            lockSurface.errorVisible = false
            pam.respond(password)
          }
          
          onPamRestartNeeded: {
            lockSurface.pamNeedsRestart = false
            pamRestartTimer.stop()
            pam.start()
          }
          
          onErrorOccurred: {
            lockSurface.errorVisible = false
          }
        }
        
        // Status messages (error or authenticating) - positioned above input
        Components.StatusMessages {
          id: statusMessages
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: passwordBox.top
          anchors.bottomMargin: Theme.spacing.md
          
          isAuthenticating: lockSurface.isAuthenticating
          authSuccess: lockSurface.authSuccess
          errorVisible: lockSurface.errorVisible
          errorText: lockSurface.errorMessage
        }
        
        // Error timer
        Timer {
          id: errorTimer
          interval: 3000
          onTriggered: lockSurface.errorVisible = false
        }
      }
    }
  }
}
