import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "cc_modules" as Modules

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
    }

    margins {
      top: Theme.barHeight
      left: 16
    }

    visible: loader.manager.visible

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  color: "transparent"
  mask: null

    width: 360
    height: {
      let baseHeight = 630
      let mediaExpansion = loader.manager.media.playerActive ? 158 : 0
      return baseHeight + mediaExpansion
    }

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

    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
    }

    Item {
      id: container
      anchors.fill: parent

      y: loader.manager.visible ? 0 : -height
      opacity: loader.manager.visible ? 1 : 0

      Behavior on y {
        NumberAnimation {
          duration: loader.manager.visible ? 300 : 200
        easing.type: Easing.OutCubic
      }
    }

      Behavior on opacity {
        NumberAnimation {
          duration: loader.manager.visible ? 200 : 150
        easing.type: Easing.OutQuad
      }
    }

    // Main container with Material 3 style
    Rectangle {
      id: background
      anchors.fill: parent
      radius: Theme.radius.xl
      color: Theme.surface_container_transparent_medium
      border.width: 1
      border.color: Qt.lighter(Theme.bg1, 1.3)

      // Enable layering for the shadow effect
      layer.enabled: true
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.5)
        shadowBlur: 1.0
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 4
        shadowOpacity: 0.3
        blurMax: 32
      }

      // Prevent clicks on panel from closing it
      MouseArea {
        anchors.fill: parent
      }

      Column {
        anchors {
          fill: parent
          margins: Theme.padding.xl
        }

        // Spacing between modules
        spacing: Theme.spacing.md

        // ========== HEADER ==========
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
            font.weight: Theme.typography.weightMedium
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

        // ========== TOGGLES GRID ==========
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

          Modules.RecordingButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            recordingManager: loader.manager.recording
          }

          Modules.PowerButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            powerMenuManager: loader.manager.powerMenuManager
          }
        }

        // ========== SLIDERS SECTION ==========
        Column {
          width: parent.width
          spacing: 12

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

        // ========== MEDIA PLAYER ==========
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

        // ========== UTILITIES ==========
        Modules.UtilitiesGrid {
          width: parent.width
          height: 60
          utilitiesManager: loader.manager.utilities
        }
      }
    }
    }
  }
}
