import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../theme"

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
            passwordInput.forceActiveFocus()
          }
        }
        
        onCompleted: result => {
          console.log("PAM completed with result:", result, "Success?", result === PamResult.Success)
          
          if (result === PamResult.Success) {
            lockSurface.pamNeedsRestart = false
            lockSurface.isAuthenticating = false
            lockSurface.authSuccess = true
            errorText.visible = false
            passwordInput.text = ""
            successTimer.restart()
          } else {
            // Authentication failed - show error and restart PAM
            console.log("Authentication failed, will restart PAM")
            lockSurface.isAuthenticating = false
            passwordInput.text = ""
            errorText.visible = true
            shakeAnimation.restart()
            errorTimer.restart()
            
            // Mark that PAM needs restart and schedule it
            lockSurface.pamNeedsRestart = true
            pamRestartTimer.restart()
            
            passwordInput.forceActiveFocus()
          }
        }
        
        onError: error => {
          console.error("PAM error:", error)
          lockSurface.isAuthenticating = false
          passwordInput.text = ""
          errorText.text = "System error: " + error
          errorText.visible = true
          errorTimer.restart()
          
          // Mark that PAM needs restart and schedule it
          lockSurface.pamNeedsRestart = true
          pamRestartTimer.restart()
          
          passwordInput.forceActiveFocus()
        }
      }
      
      // ============================================================================
      // UI LAYOUT
      // ============================================================================
      
      // Background screenshot for blur
      ScreencopyView {
        id: screenshotSource
        width: lockSurface.width
        height: lockSurface.height
        visible: false
        captureSource: lockSurface.screen
        
        // Capture a single frame when the lock surface is created
        Component.onCompleted: captureFrame()
      }
      
      // Blurred background layer
      Item {
        anchors.fill: parent
        
        MultiEffect {
          id: blurredBackground
          source: screenshotSource
          width: parent.width
          height: parent.height
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
          onClicked: passwordInput.forceActiveFocus()
        }
        
        // System clock for time display
        SystemClock {
          id: systemClock
          enabled: true
          precision: SystemClock.Seconds
        }
        
        // Time display
        Column {
          id: timeDisplay
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          anchors.verticalCenterOffset: -parent.height * 0.20
          spacing: Theme.spacing.sm
          opacity: 0
          
          // Smooth fade-in animation
          Behavior on opacity {
            NumberAnimation {
              duration: 500
              easing.type: Easing.OutCubic
            }
          }
          
          Component.onCompleted: opacity = 1.0
          
          Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: Theme.typography.fontFamily
            font.pixelSize: Theme.typography.xxl * 4
            font.weight: Theme.typography.weightMedium
            color: Theme.on_surface
            
            text: Qt.formatDateTime(systemClock.date, "hh:mm")
          }
          
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(systemClock.date, "dddd, MMMM d")
            color: Theme.on_surface
            font.family: Theme.typography.fontFamily
            font.pixelSize: Theme.typography.lg
            font.weight: Theme.typography.weightMedium
            opacity: 0.7
          }
        }
        
        // Password input container at bottom
        Rectangle {
          id: passwordBox
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          anchors.bottomMargin: Theme.spacing.xl * 4
          width: 120
          height: 40
          radius: Theme.radius.full
          color: "transparent"
          border.color: "transparent"
          border.width: 0
          opacity: lockSurface.authSuccess ? 0 : 1.0
          scale: lockSurface.authSuccess ? 0.9 : 1.0
          
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
                target: passwordBox
                property: "anchors.horizontalCenterOffset"
                from: 0; to: -10
                duration: 50
                easing.type: Easing.OutCubic
              }
              NumberAnimation {
                target: passwordBox
                property: "anchors.horizontalCenterOffset"
                from: -10; to: 10
                duration: 100
                easing.type: Easing.InOutCubic
              }
              NumberAnimation {
                target: passwordBox
                property: "anchors.horizontalCenterOffset"
                from: 10; to: 0
                duration: 50
                easing.type: Easing.InCubic
              }
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
                enabled: !lockSurface.isAuthenticating && !lockSurface.authSuccess
                clip: true
                
                Component.onCompleted: {
                  forceActiveFocus()
                  if (!pam.active) {
                    console.log("Starting initial PAM session")
                    lockSurface.pamNeedsRestart = false
                    pam.start()
                  } else {
                    console.log("PAM already active on component load")
                  }
                }
                
                Keys.onReturnPressed: {
                  // Prevent multiple submissions
                  if (lockSurface.isAuthenticating) {
                    console.log("Already authenticating, ignoring input")
                    return
                  }
                  
                  if (text.length > 0) {
                    if (pam.responseRequired && pam.active) {
                      console.log("Submitting password to PAM (active:", pam.active, "responseRequired:", pam.responseRequired, ")")
                      lockSurface.isAuthenticating = true
                      errorText.visible = false
                      pam.respond(text)
                      text = ""
                    } else if (pam.active) {
                      console.log("PAM active but not ready for response yet")
                    } else {
                      console.log("PAM not active, starting session")
                      lockSurface.pamNeedsRestart = false
                      pamRestartTimer.stop()
                      pam.start()
                    }
                  }
                }
                
                Keys.onEscapePressed: {
                  text = ""
                  errorText.visible = false
                }
              }
              
              // Visual password dots
              Row {
                anchors.centerIn: parent
                spacing: Theme.spacing.xs
                visible: passwordInput.text.length > 0
                
                Repeater {
                  model: 32  // Max password length
                  
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
                        opacity = lockSurface.isAuthenticating ? 0.5 : 0.8
                        scale = 1.0
                      } else {
                        opacity = 0
                        scale = 0.5
                      }
                    }
                    
                    Behavior on opacity {
                      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
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
                visible: passwordInput.text.length === 0
                text: "Password"
                color: errorText.visible ? Theme.error : 
                       lockSurface.isAuthenticating ? Theme.primary :
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
          }
        
        // Status messages (error or authenticating) - positioned above input
        Column {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: passwordBox.top
          anchors.bottomMargin: Theme.spacing.md
          spacing: Theme.spacing.sm
          
          // Error message
          Text {
              id: errorText
              anchors.horizontalCenter: parent.horizontalCenter
              text: "Authentication failed"
              color: Theme.error
              font.family: Theme.typography.fontFamily
              font.pixelSize: Theme.typography.md
              visible: false
              opacity: visible ? 1.0 : 0
              
              Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
              }
              
              Timer {
                id: errorTimer
                interval: 3000
                onTriggered: errorText.visible = false
              }
          }
          
          // Authenticating indicator
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "󰔟 Authenticating..."
            color: Theme.on_surface_variant
            font.family: Theme.typography.fontFamily
            font.pixelSize: Theme.typography.sm
            visible: lockSurface.isAuthenticating && !lockSurface.authSuccess
            opacity: 0.7
            
            SequentialAnimation on opacity {
              running: lockSurface.isAuthenticating && !lockSurface.authSuccess
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
            visible: lockSurface.authSuccess
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
              text: "󰄬 Unlocked"
              color: Theme.primary
              font.family: Theme.typography.fontFamily
              font.pixelSize: Theme.typography.lg
              font.weight: Theme.typography.weightBold
            }
          }
        }
      }
    }
  }
}
