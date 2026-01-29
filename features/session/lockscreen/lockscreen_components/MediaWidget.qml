import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"
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
  radius: Theme.radius.lg
  color: Theme.surface_container
  clip: true

  RowLayout {
    anchors {
      fill: parent
      leftMargin: Theme.spacing.md
      rightMargin: Theme.spacing.md
      bottomMargin: Theme.spacing.sm
      topMargin: Theme.spacing.sm
    }

    spacing: Theme.spacing.md

    // Album art
    Rectangle {
      Layout.preferredWidth: 38
      Layout.preferredHeight: 38
      radius: Theme.radius.md
      color: Theme.surface_container_high

      NImageRounded {
        anchors.fill: parent
        imagePath: root.albumArt
        borderWidth: 0
        radius: Theme.radius.md
        imageFillMode: Image.PreserveAspectCrop
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

    // Track info (with fixed width to prevent overlay)
    ColumnLayout {
      Layout.preferredWidth: 160
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

    // Spacer to push controls to the right
    Item {
      Layout.fillWidth: true
    }

    // Media controls (right side, one line)
    RowLayout {
      spacing: Theme.spacing.xs

      // Previous button
      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: Theme.radius.full
        color: "transparent"

        Text {
          anchors.centerIn: parent
          text: "󰒮"
          font.pixelSize: Theme.typography.lg
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
        radius: Theme.radius.full
        color: playPauseMouseArea.containsMouse ? Theme.primary_container : Theme.primary

        Text {
          anchors.centerIn: parent
          text: root.isPlaying ? "󰏤" : "󰐊"
          font.pixelSize: Theme.typography.xl
          color: Theme.on_primary
        }

        MouseArea {
          id: playPauseMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.mprisState.playPause()
        }

        Behavior on color {
          ColorAnimation { duration: 150 }
        }
      }

      // Next button
      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: Theme.radius.full
        color: "transparent"

        Text {
          anchors.centerIn: parent
          text: "󰒭"
          font.pixelSize: Theme.typography.lg
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
  Behavior on opacity {
    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
  }
}
