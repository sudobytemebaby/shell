import QtQuick
import "../../../../shared/theme"

/**
 * EmojiGridItem - Individual emoji cell component
 *
 * Displays a single emoji with Material 3 styling, including:
 * - Selected state highlighting
 * - Hover state feedback
 * - Click animation (scale effect)
 * - Smooth color transitions
 */
Item {
  id: root

  // ========== PROPERTIES ==========

  property string emoji: ""        // The emoji character to display
  property string name: ""          // Emoji name (currently unused but available for tooltips)
  property int itemIndex: 0         // Index in the grid
  property bool isSelected: false   // Whether this emoji is currently selected (keyboard navigation)

  // ========== SIGNALS ==========

  signal clicked()  // Emitted when user clicks this emoji

  // ========== UI IMPLEMENTATION ==========

  Rectangle {
    anchors {
      fill: parent
      margins: Theme.spacing.xs
    }
    radius: Theme.radius.xl

    // Dynamic color based on state
    color: {
      if (root.isSelected) return Theme.primary_container
      if (itemMouseArea.containsMouse) return Theme.surface_container_high
      return Theme.surface_container
    }

    // Click animation - slight scale down when pressed
    scale: itemMouseArea.pressed ? 0.95 : 1.0

    // Smooth color transition animations
    Behavior on color {
      ColorAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }

    // Smooth scale transition for click feedback
    Behavior on scale {
      NumberAnimation {
        duration: 100
        easing.type: Easing.OutCubic
      }
    }

    // Emoji text display - centered in cell
    Text {
      anchors.centerIn: parent
      text: root.emoji
      color: Theme.on_surface
      font.pixelSize: 32
      font.family: Theme.typography.fontFamily
    }

    // Mouse interaction area
    MouseArea {
      id: itemMouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor

      onClicked: {
        root.clicked()
      }
    }
  }
}
