import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components"
import "cc_modules" as Modules

// ============================================================================
// CONTROL CENTER DISPLAY
// ============================================================================
// Main control center panel with toggles, sliders, and media controls

LazyLoader {
  id: loader
  active: manager.visible

  required property var manager
  required property var systemState

  PanelWindow {
    id: panelWindow

    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    visible: loader.manager.visible

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: loader.manager.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: "transparent"
    mask: null

    Behavior on height {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
    }

    Component.onCompleted: {
      exclusiveZone = 0
    }

    contentItem {
      focus: true

      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
      }
    }

    // Background overlay - click to close
    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
    }

    // ========================================================================
    // MAIN CONTAINER
    // ========================================================================

    Item {
      id: container
      x: 28
      y: 28
      width: 360
      height: 680

      Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.radius.xl
        color: Theme.surface_container_transparent_medium
        border.width: 0.5
        border.color: Theme.surface_container_high

        MouseArea {
          anchors.fill: parent
        }

        Column {
          anchors {
            fill: parent
            margins: Theme.padding.xl
          }
          spacing: Theme.spacing.md

          // ====================================================================
          // HEADER
          // ====================================================================

          RowLayout {
            width: parent.width
            height: 40
            spacing: 8

            Text {
              Layout.fillWidth: true
              Layout.leftMargin: Theme.padding.sm
              text: "Control Center"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.xl
              font.family: Theme.typography.fontFamily
              font.weight: 600
            }

            Text {
              Layout.rightMargin: Theme.padding.sm
              text: "✕"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.lg
              font.family: Theme.typography.fontFamily
              opacity: closeMouseArea.containsMouse ? 0.7 : 1

              Behavior on opacity {
                NumberAnimation { duration: 200 }
              }

              MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: loader.manager.visible = false
              }
            }
          }

          // ====================================================================
          // QUICK TOGGLES GRID
          // ====================================================================
          // WiFi, Bluetooth, Night Mode, Microphone controls

          GridLayout {
            width: parent.width
            columns: 2
            rowSpacing: 12
            columnSpacing: 12

            Modules.WiFiToggle {
              Layout.fillWidth: true
              Layout.preferredHeight: 64
              systemState: loader.systemState
            }

            Modules.BluetoothToggle {
              Layout.fillWidth: true
              Layout.preferredHeight: 64
              systemState: loader.systemState
            }

            Modules.NightModeToggle {
              Layout.fillWidth: true
              Layout.preferredHeight: 64
            }

            Modules.MicrophoneToggle {
              Layout.fillWidth: true
              Layout.preferredHeight: 64
              systemState: loader.systemState
            }
          }

          // ====================================================================
          // SLIDERS
          // ====================================================================
          // Volume and brightness controls

          Card {
            width: parent.width
            height: 220
            padding: Theme.padding.xs

            Column {
              anchors.fill: parent

              Modules.VolumeSlider {
                width: parent.width
                height: 100
                systemState: loader.systemState
              }

              Modules.BrightnessSlider {
                width: parent.width
                height: 100
                systemState: loader.systemState
              }
            }
          }

          // ====================================================================
          // MEDIA PLAYER
          // ====================================================================
          // MPRIS media controls (playback, album art, etc.)

          Modules.PlayerControl {
            width: parent.width
            height: 180
            mediaManager: loader.manager.media
          }
        }
      }
    }
  }
}
