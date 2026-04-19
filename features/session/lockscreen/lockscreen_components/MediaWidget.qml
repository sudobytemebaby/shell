import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"
import "../../../../shared/components/Animations"
import "../../../../shared/components/Display"

// ============================================================================
// MEDIA WIDGET
// Shows currently playing media with album art and track info
// Only visible when media is playing
// ============================================================================

Rectangle {
  id: root

  required property var systemState

  // Use the shared Mpris state
  readonly property var mprisState: systemState.mpris

  readonly property bool hasMedia: mprisState.currentPlayer !== null
  readonly property bool isPlaying: mprisState.isPlaying
  readonly property string trackTitle: mprisState.title || "No media"
  readonly property string trackArtist: mprisState.artist || ""
  readonly property string albumArt: mprisState.artUrl || ""

  visible: hasMedia
  width: 380
  height: 60
  radius: Config.radius.lg
  color: Theme.surface
  clip: true

  RowLayout {
    anchors {
      fill: parent
      leftMargin: Config.spacing.md
      rightMargin: Config.spacing.md
      bottomMargin: Config.spacing.sm
      topMargin: Config.spacing.sm
    }

    spacing: Config.spacing.md

    // Album art
    Rectangle {
      Layout.preferredWidth: 38
      Layout.preferredHeight: 38
      radius: Config.radius.md
      color: Theme.surface_container_high

      NImageRounded {
        anchors.fill: parent
        imagePath: root.albumArt
        borderWidth: 0
        radius: Config.radius.md
        imageFillMode: Image.PreserveAspectCrop
        visible: root.albumArt !== ""
      }

      // Fallback icon
      Text {
        anchors.centerIn: parent
        text: "󰝚"
        font.pixelSize: Config.typography.xl
        font.family: Config.typography.sans
        color: Theme.on_surface_variant
        visible: root.albumArt === ""
      }
    }

    // Track info (with fixed width to prevent overlay)
    ColumnLayout {
      Layout.preferredWidth: 160
      Layout.fillHeight: true
      spacing: Config.spacing.xs

      Text {
        Layout.fillWidth: true
        text: root.trackTitle
        font.pixelSize: Config.typography.md
        font.family: Config.typography.sans
        font.weight: Config.typography.weightMedium
        color: Theme.on_surface
        elide: Text.ElideRight
      }

      Text {
        Layout.fillWidth: true
        text: root.trackArtist
        font.pixelSize: Config.typography.sm
        font.family: Config.typography.sans
        color: Theme.on_surface_variant
        elide: Text.ElideRight
        visible: root.trackArtist !== ""
      }
    }

    // Spacer to push controls to the right
    Item {
      Layout.fillWidth: true
    }

    // Media controls (right side, one line)
    RowLayout {
      spacing: Config.spacing.xs

      // Previous button
      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: Config.radius.full
        color: "transparent"

        Text {
          anchors.centerIn: parent
          text: "󰒮"
          font.pixelSize: Config.typography.lg
          color: Theme.on_surface
        }

        MouseArea {
          id: previousMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.mprisState.previous()
        }
      }

      // Play/Pause button
      Rectangle {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        radius: Config.radius.full
        color: playPauseMouseArea.containsMouse ? Theme.primary_container : Theme.primary

        Text {
          anchors.centerIn: parent
          text: root.isPlaying ? "󰏤" : "󰐊"
          font.pixelSize: Config.typography.xl
          color: Theme.on_primary
        }

        MouseArea {
          id: playPauseMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.mprisState.playPause()
        }

        AColor on color {}
      }

      // Next button
      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: Config.radius.full
        color: "transparent"

        Text {
          anchors.centerIn: parent
          text: "󰒭"
          font.pixelSize: Config.typography.lg
          color: Theme.on_surface
        }

        MouseArea {
          id: nextMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.mprisState.next()
        }
      }
    }
  }

  // Smooth fade in/out
  AFade on opacity {}
}
