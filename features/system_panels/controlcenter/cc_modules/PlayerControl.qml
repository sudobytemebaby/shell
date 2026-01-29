import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"
import "../../../../shared/components/Display"
import "../../../../shared/theme"

/**
 * PlayerControl - Compact media player widget for Control Center
 *
 * Layout:
 * [ Album Art | Title  ]
 * [           | Artist ]
 * [ ------------------ ] (Progress)
 * [   <<   |>   >>     ] (Controls)
 */

Card {
  id: root
  padding: Theme.padding.lg

  required property var mediaManager

  ColumnLayout {
    anchors.fill: parent
    spacing: Theme.spacing.md

    // ====================================================================
    // TOP ROW: ALBUM ART & INFO
    // ====================================================================

    RowLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true // Push controls to bottom if space allows
      spacing: Theme.spacing.md

      // Album Art
      Item {
        Layout.preferredWidth: 50
        Layout.preferredHeight: 50
        
        NImageRounded {
          anchors.fill: parent
          imagePath: mediaManager.playerArtUrl
          borderWidth: 0
          radius: Theme.radius.lg
          imageFillMode: Image.PreserveAspectCrop
          visible: mediaManager.playerActive && mediaManager.playerArtUrl !== ""
        }

        IconCircle {
          anchors.fill: parent
          visible: !mediaManager.playerActive || mediaManager.playerArtUrl === ""

          radius: Theme.radius.lg // Match image radius for consistency

          icon: mediaManager.playerActive ? "󰝚" : "󰝛"
          iconSize: Theme.typography.xl

          bgColor: mediaManager.playerActive
                   ? Theme.primary_container
                   : Theme.surface_container_highest

          iconColor: mediaManager.playerActive
                     ? Theme.primary
                     : Theme.on_surface_variant

          Behavior on bgColor { ColorAnimation { duration: 200 } }
          Behavior on iconColor { ColorAnimation { duration: 200 } }
        }
      }

      // Track Info
      ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive
                ? (mediaManager.playerTitle || "Unknown Title")
                : "No Media Playing"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamilyDisplay
          font.weight: Theme.typography.weightMedium
          elide: Text.ElideRight
        }

        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive
                ? (mediaManager.playerArtist || "Unknown Artist")
                : "Idle"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          elide: Text.ElideRight
          opacity: 0.8
        }
      }
    }

    // ====================================================================
    // MIDDLE: PROGRESS BAR
    // ====================================================================

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: 4
      visible: mediaManager.playerActive
      opacity: mediaManager.playerActive ? 1 : 0

      Behavior on opacity { NumberAnimation { duration: 200 } }

      // Background track
      Rectangle {
        anchors.fill: parent
        color: Theme.surface_container_highest
        radius: 2
      }

      // Active progress
      Rectangle {
        height: parent.height
        radius: 2
        color: Theme.primary
        
        width: {
          if (mediaManager.playerLength > 0) {
            let progress = Math.min(Math.max(mediaManager.playerPosition / mediaManager.playerLength, 0), 1)
            return Math.min(parent.width * progress, parent.width)
          }
          return 0
        }

        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
      }

      // Hit area for seeking
      MouseArea {
        anchors.fill: parent
        anchors.margins: -6 // Larger hit area
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
          if (mediaManager.playerLength > 0) {
            // Calculate seek position relative to the actual progress bar width
            let seekPosition = (mouse.x / width) * mediaManager.playerLength
            mediaManager.playerSeek(seekPosition)
          }
        }
      }
    }

    // ====================================================================
    // BOTTOM: CONTROLS
    // ====================================================================

    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignHCenter
      spacing: Theme.spacing.md
      visible: mediaManager.playerActive
      opacity: mediaManager.playerActive ? 1 : 0

      Behavior on opacity { NumberAnimation { duration: 200 } }

      // Previous
      Text {
        text: "󰒮"
        color: Theme.on_surface
        font.pixelSize: 20
        font.family: Theme.typography.fontFamily
        opacity: prevMouse.containsMouse ? 0.7 : 1

        MouseArea {
          id: prevMouse
          anchors.fill: parent
          anchors.margins: -8
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: mediaManager.playerPrevious()
        }
      }

      // Play/Pause (Larger)
      Rectangle {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        radius: 20
        color: Theme.primary_container

        Text {
          anchors.centerIn: parent
          text: mediaManager.playerPlaying ? "󰏤" : "󰐊"
          color: Theme.primary
          font.pixelSize: 18
          font.family: Theme.typography.fontFamily
        }

        scale: playMouse.pressed ? 0.9 : (playMouse.containsMouse ? 1.05 : 1.0)
        Behavior on scale { NumberAnimation { duration: 100 } }

        MouseArea {
          id: playMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: mediaManager.playerPlayPause()
        }
      }

      // Next
      Text {
        text: "󰒭"
        color: Theme.on_surface
        font.pixelSize: 24
        font.family: Theme.typography.fontFamily
        opacity: nextMouse.containsMouse ? 0.7 : 1

        MouseArea {
          id: nextMouse
          anchors.fill: parent
          anchors.margins: -8
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: mediaManager.playerNext()
        }
      }
    }
  }
}
