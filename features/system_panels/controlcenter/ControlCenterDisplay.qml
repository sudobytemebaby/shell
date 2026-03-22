import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components"
import "../../../shared/components/Modals"
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
      height: 620

      Rectangle {
        id: background

        layer.enabled: true
        layer.smooth: true

        layer.effect: MultiEffect {
          shadowEnabled: true
          shadowColor: "#80000000"
          shadowBlur: 1.0
          shadowVerticalOffset: 6
          shadowHorizontalOffset: 0
          shadowOpacity: 1
          shadowScale: 1.02
        }

        anchors.fill: parent
        radius: Theme.radius.xl
        color: Theme.surface_transparent_medium
        border.width: 0.5
        border.color: Theme.surface_container

        MouseArea {
          anchors.fill: parent
        }

        ColumnLayout {
          anchors {
            fill: parent
            margins: Theme.padding.xl
          }
          spacing: Theme.spacing.md

          // ====================================================================
          // HEADER
          // ====================================================================

          ModalHeader {
            title: "Control Center"
            onCloseClicked: loader.manager.visible = false
          }

          // ====================================================================
          // QUICK TOGGLES GRID
          // ====================================================================
          // WiFi, Bluetooth, Night Mode, Microphone controls

          GridLayout {
            Layout.fillWidth: true
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
            Layout.fillWidth: true
            height: 210
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
          // MEDIA PLAYER & QUICK ACTIONS
          // ====================================================================
          RowLayout {
            Layout.fillWidth: true
            height: 168
            spacing: Theme.spacing.sm

            // MPRIS media controls (playback, album art, etc.)
            Modules.PlayerControl {
              Layout.fillWidth: true
              Layout.fillHeight: true
              mediaManager: loader.manager.media
            }

            // Quick action button grid (2x2)
            Modules.QuickActions {
              Layout.fillWidth: true
              Layout.fillHeight: true
              quickActionsManager: loader.manager.quickActions
            }
          }
        }
      }
    }
  }
}
