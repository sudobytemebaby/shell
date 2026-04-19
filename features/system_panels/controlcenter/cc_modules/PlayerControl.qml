import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"
import "../../../../shared/components/Display"
import "../../../../shared/theme"

/**
 * PlayerControl - Compact media player widget for Control Center
 *
 * Layout with background album art:
 * Background: Album art with dark overlay
 * Overlay: Track info and controls
 */

Card {
  id: root
  padding: 0

  required property var mediaManager

  // ====================================================================
  // BACKGROUND: ALBUM ART
  // ====================================================================

  // Dark overlay for better text contrast
  Rectangle {
    anchors.fill: parent
    color: Theme.surface_container
    radius: Config.radius.xl
    visible: mediaManager.playerActive && mediaManager.playerArtUrl !== ""
  }

  // ====================================================================
  // CONTENT OVERLAY
  // ====================================================================

  // Idle state - centered icon and text
  ColumnLayout {
    anchors.centerIn: parent
    width: parent.width - Config.padding.md * 2
    spacing: Config.spacing.md
    visible: !mediaManager.playerActive

    IconCircle {
      Layout.alignment: Qt.AlignHCenter
      Layout.preferredWidth: 60
      Layout.preferredHeight: 60

      radius: Config.radius.lg
      icon: "󰝛"
      iconSize: Config.typography.xxl
      bgColor: Theme.surface_container
      iconColor: Theme.on_surface_variant
    }

    Text {
      Layout.fillWidth: true
      text: "No Media Playing"
      color: Theme.on_surface
      font.pixelSize: Config.typography.md
      font.family: Config.typography.sans
      font.weight: Config.typography.weightMedium
      horizontalAlignment: Text.AlignHCenter
    }
  }

  // Active state
  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Config.padding.lg
    spacing: Config.spacing.md
    visible: mediaManager.playerActive

    // Track Info
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignBottom
      spacing: 2

      Text {
        Layout.fillWidth: true
        text: mediaManager.playerTitle || "Unknown Title"
        color: Theme.on_surface
        font.pixelSize: Config.typography.lg
        font.family: Config.typography.sans
        font.weight: Config.typography.weightMedium
        elide: Text.ElideRight
      }

      Text {
        Layout.fillWidth: true
        text: mediaManager.playerArtist || "Unknown Artist"
        color: Theme.on_surface_variant
        font.pixelSize: Config.typography.md
        font.family: Config.typography.sans
        elide: Text.ElideRight
        opacity: 0.8
      }
    }

    // ====================================================================
    // PROGRESS BAR
    // ====================================================================

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: 4

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

        AExpand on width {}
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
    // CONTROLS
    // ====================================================================

    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignHCenter
      spacing: Config.spacing.md

      // Previous
      Text {
        text: "󰒮"
        color: Theme.on_surface
        font.pixelSize: 24
        font.family: Config.typography.sans
        opacity: prevMouse.containsMouse ? 0.7 : 1

        AFade on opacity {}

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
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        radius: 20
        color: Theme.primary_container

        Text {
          anchors.centerIn: parent
          text: mediaManager.playerPlaying ? "󰏤" : "󰐊"
          color: Theme.primary
          font.pixelSize: 18
          font.family: Config.typography.sans
        }

        scale: playMouse.pressed ? 0.9 : (playMouse.containsMouse ? 1.05 : 1.0)
        AScale on scale {}

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
        font.family: Config.typography.sans
        opacity: nextMouse.containsMouse ? 0.7 : 1

        AFade on opacity {}

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
