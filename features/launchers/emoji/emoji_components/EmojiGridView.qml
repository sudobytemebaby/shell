import QtQuick
import "../../../../shared/theme"
import "../../../../shared/components/Animations"

/**
 * EmojiGridView - Scrollable grid container for emoji items
 *
 * Extends GridView with:
 * - Custom scrollbar with Material 3 styling
 * - Smooth scrolling configuration
 * - Auto-positioning based on selected index
 *
 * Note: This component is currently unused in favor of inline GridView in EmojiDisplay.qml
 * It's kept for potential future modularization.
 */
GridView {
  id: gridView

  // ========== PROPERTIES ==========

  property int selectedIndex: 0  // Currently selected emoji index

  // ========== CONFIGURATION ==========

  clip: true

  // Cell dimensions
  cellWidth: 70
  cellHeight: 70

  currentIndex: selectedIndex

  // Smooth scrolling configuration
  maximumFlickVelocity: 2000
  flickDeceleration: 1500

  // Auto-scroll to keep selected item visible
  onSelectedIndexChanged: {
    positionViewAtIndex(selectedIndex, GridView.Contain)
  }

  // ========== MATERIAL 3 SCROLLBAR ==========

  Rectangle {
    anchors {
      right: parent.right
      top: parent.top
      bottom: parent.bottom
      rightMargin: Config.spacing.xs
      topMargin: Config.spacing.xs
      bottomMargin: Config.spacing.xs
    }
    width: 6
    radius: Config.radius.sm
    color: "transparent"

    // Only show scrollbar when content exceeds viewport
    visible: gridView.contentHeight > gridView.height

    // Scrollbar track (subtle background)
    Rectangle {
      anchors.fill: parent
      radius: parent.radius
      color: Theme.outline_variant
      opacity: 0.3
    }

    // Scrollbar thumb (draggable indicator)
    Rectangle {
      width: parent.width

      // Calculate thumb height proportional to visible content ratio
      height: {
        if (gridView.contentHeight <= gridView.height) return 0
        var ratio = gridView.height / gridView.contentHeight
        return Math.max(40, parent.height * ratio)  // Minimum 40px thumb
      }

      // Calculate thumb position based on scroll progress
      y: {
        if (gridView.contentHeight <= gridView.height) return 0
        var maxY = parent.height - height
        var progress = gridView.contentY / (gridView.contentHeight - gridView.height)
        return maxY * progress
      }

      radius: parent.radius
      color: scrollThumbMouseArea.containsMouse ? Theme.primary : Theme.outline
      opacity: scrollThumbMouseArea.containsMouse ? 0.8 : 0.6

      // Smooth animations for thumb movement
      AExpand on y {}

      AColor on color {}

      AFade on opacity {}

      // Hover area for thumb with extended hit target
      MouseArea {
        id: scrollThumbMouseArea
        anchors.fill: parent
        anchors.margins: -4  // Expand hit area slightly
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
      }
    }
  }
}
