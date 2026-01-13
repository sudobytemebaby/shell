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
      
      PamContext {
        id: pam
        config: "login"
        
        onPamMessage: {
          if (responseRequired) {
            passwordInput.forceActiveFocus()
          }
        }
        
        onCompleted: result => {
          if (result === PamResult.Success) {
            manager.unlock()
          } else {
            passwordInput.text = ""
            passwordInput.forceActiveFocus()
            errorText.visible = true
            shakeAnimation.restart()
            errorTimer.restart()
          }
        }
        
        onError: error => {
          console.error("PAM error:", error)
          passwordInput.text = ""
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
        anchors.fill: parent
        color: Theme.scrim_transparent_heavy
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
        
        // Main lockscreen content
        Column {
          anchors.centerIn: parent
          spacing: Theme.spacing.xl
          opacity: 0
          
          // Smooth fade-in animation with slight delay
          Behavior on opacity {
            NumberAnimation {
              duration: 500
              easing.type: Easing.OutCubic
            }
          }
          
          Component.onCompleted: opacity = 1.0
          
          // Time display
          Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacing.sm
            
            Text {
              id: timeText
              anchors.horizontalCenter: parent.horizontalCenter
              font.family: Theme.typography.fontFamily
              font.pixelSize: Theme.typography.xxxl * 2
              font.weight: Theme.typography.weightBold
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
          
          // Spacer
          Item { width: 1; height: Theme.spacing.xxl }
          
          // Password input container
          Rectangle {
            id: passwordBox
            anchors.horizontalCenter: parent.horizontalCenter
            width: 200
            height: Theme.component.inputHeight + Theme.padding.md
            radius: Theme.radius.lg
            color: Theme.surface_container_transparent_heavy
            border.color: passwordInput.activeFocus ? Theme.primary : Theme.outline
            border.width: 2
            
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
            
            Behavior on border.color {
              ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
              }
            }
            
            Row {
              anchors.fill: parent
              anchors.margins: Theme.padding.md
              spacing: Theme.spacing.md
              
              // Lock icon
              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: pam.active ? "" : ""
                font.family: Theme.typography.fontFamily
                font.pixelSize: Theme.typography.xl
                color: Theme.on_surface
              }
              
              // Password input
              TextInput {
                id: passwordInput
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.spacing.xl * 4
                color: Theme.on_surface
                font.pixelSize: Theme.typography.lg
                font.family: Theme.typography.fontFamily
                echoMode: pam.responseVisible ? TextInput.Normal : TextInput.Password
                verticalAlignment: TextInput.AlignVCenter
                
                Component.onCompleted: {
                  forceActiveFocus()
                  if (!pam.active) {
                    pam.start()
                  }
                }
                
                Keys.onReturnPressed: {
                  if (text.length > 0 && pam.responseRequired) {
                    pam.respond(text)
                    text = ""
                  } else if (!pam.active) {
                    pam.start()
                  }
                }
                
                Keys.onEscapePressed: {
                  text = ""
                }
                
                // Placeholder text
                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  visible: passwordInput.text.length === 0
                  text: pam.message || "Enter password"
                  color: Theme.on_surface_variant
                  font.family: Theme.typography.fontFamily
                  font.pixelSize: Theme.typography.lg
                  opacity: 0.5
                }
              }
            }
          }
          
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
          
          // PAM message (if not an error)
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: pam.message
            color: Theme.on_surface
            font.family: Theme.typography.fontFamily
            font.pixelSize: Theme.typography.sm
            visible: pam.message && !pam.messageIsError
            opacity: 0.7
          }
        }
        
        // Status indicator at bottom
        Text {
          anchors.bottom: parent.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottomMargin: Theme.spacing.xl * 2
          
          text: sessionLock.secure ? "Locked" : "Locking..."
          color: Theme.on_surface_variant
          font.family: Theme.typography.fontFamily
          font.pixelSize: Theme.typography.sm
          opacity: 0.5
        }
      }
    }
  }
}
