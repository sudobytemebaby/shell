import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"
import "../../../../shared/components/Display"
import "../../../../shared/theme"

/**
 * PlayerControl - Modern media player widget for Control Center
 *
 * Apple Music inspired design with horizontal layout:
 * - Album art on the left (80x80px)
 * - Track info and progress bar in the center
 * - Playback controls and timestamps at the bottom
 * - Fixed height, no expanding animations
 * - Clean, minimal design with smooth transitions
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
    spacing: Theme.spacing.md

    // ====================================================================
    // MAIN CONTENT ROW (Album Art + Track Info)
    // ====================================================================

    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.spacing.lg

      // Album art
      Item {
        Layout.preferredWidth: 80
        Layout.preferredHeight: 80
        Layout.alignment: Qt.AlignVCenter

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

          icon: mediaManager.playerActive ? "󰝚" : "󰝛"
          iconSize: Theme.typography.xxl

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
        Layout.alignment: Qt.AlignVCenter
        spacing: 4

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
            return parent.width * (mediaManager.playerPosition / mediaManager.playerLength)
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
    // PLAYBACK CONTROLS & TIME
    // ====================================================================

    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.spacing.sm
      visible: mediaManager.playerActive

      opacity: mediaManager.playerActive ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
      }

      Text {
        text: mediaManager.formatTime(mediaManager.playerPosition)
        color: Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        opacity: 0.7
      }

      Item { Layout.fillWidth: true }

      RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spacing.sm

        RoundIconButton {
          size: 32
          icon: "󰒮"
          isPrimary: false
          onClicked: mediaManager.playerPrevious()
        }

        RoundIconButton {
          size: 36
          icon: mediaManager.playerPlaying ? "󰏤" : "󰼛"
          isPrimary: true
          onClicked: mediaManager.playerPlayPause()
        }

        RoundIconButton {
          size: 32
          icon: "󰒭"
          isPrimary: false
          onClicked: mediaManager.playerNext()
        }
      }

      Item { Layout.fillWidth: true }

      Text {
        text: mediaManager.formatTime(mediaManager.playerLength)
        color: Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        opacity: 0.7
      }
    }
  }
}
