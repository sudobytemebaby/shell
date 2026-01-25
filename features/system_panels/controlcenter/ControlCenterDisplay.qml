import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components"
import "cc_modules" as Modules

LazyLoader {
  id: loader
  active: manager.visible

  required property var manager
  required property var systemState

  PanelWindow {
    id: panelWindow

    // --------------------------------------------------------------------------
    // Window Configuration
    // --------------------------------------------------------------------------
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    // LazyLoader handles creation/destruction, so this is implicitly visible when loaded.
    // However, we explicitly set it to ensure properties are synced.
    visible: true

    WlrLayershell.layer: WlrLayer.Overlay
    // When loaded, we want exclusive focus
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"
    mask: null

    // Animation for window height changes (if any)
    Behavior on height {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
    }

    Component.onCompleted: {
      exclusiveZone = 0
    }

    // --------------------------------------------------------------------------
    // Input Handling
    // --------------------------------------------------------------------------
    contentItem {
      focus: true

      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
    }

    // --------------------------------------------------------------------------
    // Main Panel Container
    // --------------------------------------------------------------------------
    Item {
      id: container
      
      // Fixed positioning for now, could be dynamic
      x: 28
      y: 28
      width: 360
      
      // Dynamic height calculation based on media player state
      height: {
        const baseHeight = 600
        const mediaExpansion = loader.manager.media.playerActive ? 158 : 0
        return baseHeight + mediaExpansion
      }

      Behavior on height {
        NumberAnimation {
          duration: 150
          easing.type: Easing.OutCubic
        }
      }

      // Background & Content
      Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.radius.xl
        color: Theme.surface_container_transparent_heavy
        border.width: 0.5
        border.color: Theme.surface_container_high

        // Prevent clicks on panel from closing it (propagating to the window MouseArea)
        MouseArea {
          anchors.fill: parent
        }

        Column {
          anchors {
            fill: parent
            margins: Theme.padding.xl
          }
          spacing: Theme.spacing.md

          // ----------------------------------------------------------------------
          // Header Section
          // ----------------------------------------------------------------------
          RowLayout {
            width: parent.width
            height: 40
            spacing: Theme.spacing.sm

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
              color: Theme.fg
              font.pixelSize: Theme.typography.lg
              font.family: Theme.fontFamily
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

          // ----------------------------------------------------------------------
          // Quick Toggles Grid
          // ----------------------------------------------------------------------
          Card {
            width: parent.width
            height: togglesGrid.implicitHeight + (padding * 2)
            radius: Theme.radius.xl

            GridLayout {
              id: togglesGrid
              anchors.fill: parent
              columns: 3
              rowSpacing: Theme.spacing.sm
              columnSpacing: Theme.spacing.sm

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

              Modules.MicrophoneToggle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                systemState: loader.systemState
              }

              Modules.NightLightToggle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                nightLightManager: loader.manager.nightLight
              }

              Modules.ColorPickerToggle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                launcherManager: loader.manager.launcher
              }

              Modules.ScreenshotToggle{
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                launcherManager: loader.manager.launcher
              }
            }
          }

          // ----------------------------------------------------------------------
          // Sliders Section (Volume & Brightness)
          // ----------------------------------------------------------------------
          Column {
            width: parent.width
            spacing: Theme.spacing.md

            Modules.VolumeSlider {
              width: parent.width
              height: 108
              audioManager: loader.manager.audio
              systemState: loader.systemState
            }

            Modules.BrightnessSlider {
              width: parent.width
              height: 108
              brightnessManager: loader.manager.brightness
              systemState: loader.systemState
            }
          }

          // ----------------------------------------------------------------------
          // Media Player Section
          // ----------------------------------------------------------------------
          Modules.PlayerControl {
            width: parent.width
            height: loader.manager.media.playerActive ? 220 : 72
            mediaManager: loader.manager.media

            Behavior on height {
              NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
              }
            }
          }
        }
      }
    }
  }
}
