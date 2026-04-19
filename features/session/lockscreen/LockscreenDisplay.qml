import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../../../shared/theme"
import "lockscreen_components" as Components

// ============================================================================
// LOCKSCREEN DISPLAY
// Main lockscreen UI - uses lazy loading for better performance
// Handles Wayland session lock surface and keyboard focus management
// ============================================================================

Scope {
  id: root
  required property var manager
  required property var systemState

  // ============================================================================
  // LOADER FOR LAZY LOADING
  // ============================================================================

  Loader {
    id: loader
    active: manager.displayActive

    sourceComponent: Component {
      Item {
        id: lockContainer

        // Track if lockscreen is fully ready (wallpaper loaded)
        property bool isReady: false

        // ============================================================================
        // LOCK CONTEXT (PAM MANAGEMENT)
        // ============================================================================

        Components.LockContext {
          id: lockContext

          onUnlocked: {
            sessionLock.locked = false
            lockContext.currentText = ""
            manager.scheduleDisplayUnload()
          }

          onFailed: {
            lockContext.currentText = ""
          }
        }

        // ============================================================================
        // SESSION LOCK
        // ============================================================================

        WlSessionLock {
          id: sessionLock
          locked: root.manager.locked

          WlSessionLockSurface {
            id: lockSurface
            color: "#000000"  // Pure black for seamless fade-in

            // ============================================================================
            // UI LAYOUT
            // ============================================================================

            // Wallpaper background with gradient overlay
            Components.WallpaperBackground {
              id: wallpaperBg
              anchors.fill: parent
              wallpaperPath: root.manager.wallpaperPath

              onWallpaperReadyChanged: {
                if (wallpaperReady) {
                  // Delay slightly to ensure everything is rendered
                  readyTimer.start()
                }
              }
            }

            // Timer to mark lockscreen as ready after wallpaper loads
            Timer {
              id: readyTimer
              interval: 50
              repeat: false
              onTriggered: {
                lockContainer.isReady = true
              }
            }

            // Main content overlay (fades in when ready)
            Item {
              id: mainOverlay
              anchors.fill: parent
              opacity: 0

              // Smooth fade-in animation
              Behavior on opacity {
                NumberAnimation {
                  duration: Config.lockscreen.fadeInDuration
                  easing.type: Easing.InOutCubic
                }
              }

              // Fade in when wallpaper is ready
              Connections {
                target: lockContainer
                function onIsReadyChanged() {
                  if (lockContainer.isReady) {
                    mainOverlay.opacity = 1.0
                  }
                }
              }

              // Mouse area to trigger focus on cursor movement (workaround for Wayland focus issues)
              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onPositionChanged: {
                  if (passwordInput) {
                    passwordInput.forceActiveFocus()
                  }
                }
              }

              // Hidden input that receives actual text
              TextInput {
                id: passwordInput
                width: 0
                height: 0
                visible: false
                enabled: !lockContext.unlockInProgress || lockContext.waitingForPassword
                text: lockContext.currentText
                onTextChanged: lockContext.currentText = text

                Keys.onPressed: function (event) {
                  if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    lockContext.tryUnlock()
                  } else if (event.key === Qt.Key_Escape) {
                    text = ""
                  }
                }

                Component.onCompleted: forceActiveFocus()
              }

              // Power widgets (suspend, reboot, poweroff) - positioned on the right
              Components.PowerWidgets {
                anchors {
                  right: parent.right
                  top: parent.top
                  rightMargin: Config.spacing.xl
                  topMargin: Config.spacing.xl
                }
              }

              // Time display
              Components.TimeDisplay {
                id: timeDisplay
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -parent.height * 0.20
              }

              // Bottom widgets container
              Item {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Config.spacing.xl * 3
                width: parent.width
                height: bottomWidgetsLayout.implicitHeight

                ColumnLayout {
                  id: bottomWidgetsLayout
                  anchors.horizontalCenter: parent.horizontalCenter
                  spacing: Config.spacing.md

                  // Media widget (only shows if media is playing)
                  Components.MediaWidget {
                    Layout.alignment: Qt.AlignHCenter
                    systemState: root.systemState
                  }

                  // Status indicators (user, battery, keyboard)
                  Components.StatusIndicators {
                    Layout.alignment: Qt.AlignHCenter
                    systemState: root.systemState
                  }

                  // Status messages (error or authenticating) - positioned above password input
                  Components.StatusMessages {
                    id: statusMessages
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Config.spacing.lg

                    isAuthenticating: lockContext.unlockInProgress
                    errorVisible: lockContext.showFailure
                    errorText: lockContext.errorMessage
                    infoVisible: lockContext.showInfo
                    infoText: lockContext.infoMessage
                  }

                  // Password input
                  Components.PasswordInput {
                    id: passwordBox
                    Layout.alignment: Qt.AlignHCenter

                    lockContext: lockContext
                    passwordInput: passwordInput
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
