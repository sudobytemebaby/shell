import QtQuick
import QtQuick.Layouts
import "../../../shared/theme"

// ----------------------------------------------------------------------------
// Weather Header
// ----------------------------------------------------------------------------
// Header bar for weather widget with title, refresh button, and close button.

RowLayout {
  Layout.fillWidth: true
  Layout.preferredHeight: 40
  spacing: Theme.spacing.sm

  // ==========================================================================
  // PROPERTIES
  // ==========================================================================

  required property string title
  signal closeClicked()
  signal refreshClicked()

  // ==========================================================================
  // TITLE TEXT
  // ==========================================================================

  Text {
    id: headerText
    Layout.fillWidth: true
    Layout.leftMargin: Theme.padding.xs

    text: title

    color: Theme.on_surface
    font.pixelSize: Theme.typography.xl
    font.family: Theme.typography.fontFamily
    font.weight: Theme.typography.weightMedium

    // Smooth fade transition when title changes
    Behavior on text {
      SequentialAnimation {
        NumberAnimation { target: headerText; property: "opacity"; to: 0; duration: 100 }
        PropertyAction { target: headerText; property: "text" }
        NumberAnimation { target: headerText; property: "opacity"; to: 1; duration: 100 }
      }
    }
  }

  // ==========================================================================
  // REFRESH BUTTON
  // ==========================================================================

  Rectangle {
    Layout.preferredWidth: 32
    Layout.preferredHeight: 32
    radius: Theme.radius.full
    color: refreshMouseArea.containsMouse ? Theme.surface_container_high : "transparent"

    Text {
      anchors.centerIn: parent
      text: "󰑐"
      color: Theme.on_surface
      font.pixelSize: Theme.typography.lg
      font.family: Theme.typography.fontFamily

      // Rotation animation on click
      RotationAnimation on rotation {
        id: refreshAnim
        from: 0
        to: 360
        duration: 500
        running: false
      }
    }

    MouseArea {
      id: refreshMouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        refreshAnim.start()
        refreshClicked()
      }
    }
  }

  // ==========================================================================
  // CLOSE BUTTON
  // ==========================================================================

  Rectangle {
    Layout.preferredWidth: 32
    Layout.preferredHeight: 32
    Layout.rightMargin: Theme.padding.xs
    radius: Theme.radius.full
    color: closeMouseArea.containsMouse ? Theme.surface_container_high : "transparent"

    Text {
      anchors.centerIn: parent
      text: "✕"
      color: Theme.on_surface
      font.pixelSize: Theme.typography.lg
      font.family: Theme.typography.fontFamily
    }

    MouseArea {
      id: closeMouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: closeClicked()
    }
  }
}
