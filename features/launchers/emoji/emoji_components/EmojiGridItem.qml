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
      margins: Config.spacing.xs
    }
    radius: Config.radius.xl

    // Dynamic color based on state
    color: {
      root.isSelected ? Theme.primary_container : "transparent"
    }

    // Emoji text display - centered in cell
    Text {
      anchors.centerIn: parent
      text: root.emoji
      color: Theme.on_surface
      font.pixelSize: 32
      font.family: Config.typography.sans
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
