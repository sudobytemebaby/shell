import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../../../shared/theme"

// ============================================================================
// MEDIA WIDGET
// Shows currently playing media with album art and track info
// Only visible when media is playing
// ============================================================================

Rectangle {
  id: root

  readonly property var activePlayer: Mpris.players.values.length > 0
    ? Mpris.players.values[0]
    : null

  readonly property bool hasMedia: activePlayer !== null
  readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
  readonly property string trackTitle: activePlayer?.trackTitle || "No media"
  readonly property string trackArtist: activePlayer?.trackArtist || ""
  readonly property string albumArt: activePlayer?.trackArtUrl || ""

  visible: hasMedia
  width: 280
  height: 60
  radius: Theme.radius.lg
  color: Theme.surface_container
  clip: true

  RowLayout {
    anchors.fill: parent
    anchors.margins: Theme.spacing.sm
    spacing: Theme.spacing.md

    // Album art
    Rectangle {
      Layout.preferredWidth: 44
      Layout.preferredHeight: 44
      radius: Theme.radius.md
      color: Theme.surface_container_high
      clip: true

      Image {
        anchors.fill: parent
        source: root.albumArt
        fillMode: Image.PreserveAspectCrop
        visible: root.albumArt !== ""
      }

      // Fallback icon
      Text {
        anchors.centerIn: parent
        text: "󰝚"
        font.pixelSize: Theme.typography.xl
        font.family: Theme.typography.fontFamily
        color: Theme.on_surface_variant
        visible: root.albumArt === ""
      }
    }

    // Track info
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: Theme.spacing.xs

      Text {
        Layout.fillWidth: true
        text: root.trackTitle
        font.pixelSize: Theme.typography.md
        font.family: Theme.typography.fontFamily
        font.weight: Theme.typography.weightMedium
        color: Theme.on_surface
        elide: Text.ElideRight
      }

      Text {
        Layout.fillWidth: true
        text: root.trackArtist
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        color: Theme.on_surface_variant
        elide: Text.ElideRight
        visible: root.trackArtist !== ""
      }
    }

    // Playing indicator
    Text {
      text: root.isPlaying ? "󰐊" : "󰏤"
      font.pixelSize: Theme.typography.lg
      font.family: Theme.typography.fontFamily
      color: root.isPlaying ? Theme.primary : Theme.on_surface_variant
      opacity: 0.7
    }
  }

  // Smooth fade in/out
  Behavior on opacity {
    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
  }
}
