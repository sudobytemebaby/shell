import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"
import "../../../../shared/components/Display"
import "../../../../shared/theme"

/**
 * PlayerControl - Compact media player widget for Control Center
 *
 * Compact design optimized for half-width layout (180x180px):
 * - Album art (56x56px) and track info in horizontal row at top
 * - Progress bar with timestamps in the middle
 * - Playback controls centered at the bottom
 * - Fixed size, clean minimal design with smooth transitions
 *
 * States:
 * - Idle: Shows "No Media Playing" with music icon
 * - Active: Shows full player with album art, track info, and controls
 */

Card {
  id: root
  padding: Theme.padding.lg

  required property var mediaManager

  ColumnLayout {
    anchors.fill: parent
    spacing: Theme.spacing.sm

    // ====================================================================
    // ALBUM ART & TRACK INFO COLUMN
    // ====================================================================

    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignHCenter
      spacing: Theme.spacing.sm

      // Album art
      Item {
        Layout.preferredWidth: 48
        Layout.preferredHeight: 48 
        Layout.alignment: Qt.AlignLeft

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

          radius: Theme.radius.full

          icon: mediaManager.playerActive ? "󰝚" : "󰝛"
          iconSize: Theme.typography.xl

          bgColor: mediaManager.playerActive
                   ? Theme.primary_container
                   : Theme.surface_container_highest

          iconColor: mediaManager.playerActive
                     ? Theme.primary
                     : Theme.on_surface_variant

          Behavior on bgColor {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
          }

          Behavior on iconColor {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
          }
        }
      }

      // Track info
      ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft
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
          horizontalAlignment: Text.AlignLeft
        }

        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive
                ? (mediaManager.playerArtist || "Unknown Artist")
                : "Idle"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.xs
          font.family: Theme.typography.fontFamily
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignLeft
          opacity: 0.7
        }
      }
    }

    // ====================================================================
    // PROGRESS BAR
    // ====================================================================

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: 4
      visible: mediaManager.playerActive
      opacity: mediaManager.playerActive ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
      }

      Rectangle {
        anchors.fill: parent
        color: Theme.surface_container_highest
        radius: 2
      }

      Rectangle {
        anchors {
          left: parent.left
          top: parent.top
          bottom: parent.bottom
        }
        width: {
          if (mediaManager.playerLength > 0) {
            let progress = Math.min(Math.max(mediaManager.playerPosition / mediaManager.playerLength, 0), 1)
            return Math.min(parent.width * progress, parent.width)
          }
          return 0
        }
        color: Theme.primary
        radius: 2

        Behavior on width {
          NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
          if (mediaManager.playerLength > 0) {
            let seekPosition = (mouse.x / width) * mediaManager.playerLength
            mediaManager.playerSeek(seekPosition)
          }
        }
      }
    }

    // ====================================================================
    // PLAYBACK CONTROLS
    // ====================================================================

    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignHCenter
      spacing: Theme.spacing.lg
      visible: mediaManager.playerActive
      opacity: mediaManager.playerActive ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
      }

      // Previous button
      Text {
        text: "󰒮"
        color: Theme.on_surface
        font.pixelSize: Theme.typography.xl
        font.family: Theme.typography.fontFamily
        opacity: prevMouseArea.containsMouse ? 0.7 : 1

        Behavior on opacity {
          NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        MouseArea {
          id: prevMouseArea
          anchors.fill: parent
          anchors.margins: -4
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: mediaManager.playerPrevious()
        }
      }

      // Play/Pause button
      Text {
        text: mediaManager.playerPlaying ? "󰏤" : "󰐊"
        color: Theme.on_surface
        font.pixelSize: Theme.typography.xxl
        font.family: Theme.typography.fontFamily
        opacity: playMouseArea.containsMouse ? 0.7 : 1

        Behavior on opacity {
          NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        MouseArea {
          id: playMouseArea
          anchors.fill: parent
          anchors.margins: -4
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: mediaManager.playerPlayPause()
        }
      }

      // Next button
      Text {
        text: "󰒭"
        color: Theme.on_surface
        font.pixelSize: Theme.typography.xl
        font.family: Theme.typography.fontFamily
        opacity: nextMouseArea.containsMouse ? 0.7 : 1

        Behavior on opacity {
          NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        MouseArea {
          id: nextMouseArea
          anchors.fill: parent
          anchors.margins: -4
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: mediaManager.playerNext()
        }
      }
    }
  }
}
