import QtQuick
import "../../../../shared/theme"

GridView {
  id: gridView
  
  // Properties
  property var emojis: []
  property int selectedIndex: 0
  
  // Signals
  signal emojiSelected(string emoji)
  signal indexSelected(int index)
  
  clip: true
  
  cellWidth: 70
  cellHeight: 70
  
  model: emojis
  
  currentIndex: selectedIndex
  
  // Smooth scrolling
  maximumFlickVelocity: 2000
  flickDeceleration: 1500
  
  // Function to position view at index (exposed for keyboard nav)
  function positionViewAtIndex(index, mode) {
    GridView.positionViewAtIndex(index, mode)
  }
  
  // Watch for selectedIndex changes and position view accordingly
  onSelectedIndexChanged: {
    positionViewAtIndex(selectedIndex, GridView.Contain)
  }
  
  delegate: EmojiGridItem {
    required property var modelData
    required property int index
    
    width: gridView.cellWidth
    height: gridView.cellHeight
    
    emoji: modelData.emoji
    name: modelData.name
    itemIndex: index
    isSelected: index === gridView.selectedIndex
    
    onClicked: {
      gridView.indexSelected(index)
      gridView.emojiSelected(modelData.emoji)
    }
  }
  
  // ========== MATERIAL 3 SCROLLBAR ==========
  Rectangle {
    anchors {
      right: parent.right
      top: parent.top
      bottom: parent.bottom
      rightMargin: Theme.spacing.xs
      topMargin: Theme.spacing.xs
      bottomMargin: Theme.spacing.xs
    }
    width: 6
    radius: Theme.radius.sm
    color: "transparent"
    visible: gridView.contentHeight > gridView.height
    
    // Scrollbar track (subtle)
    Rectangle {
      anchors.fill: parent
      radius: parent.radius
      color: Theme.outline_variant
      opacity: 0.3
    }
    
    // Scrollbar thumb
    Rectangle {
      width: parent.width
      height: {
        if (gridView.contentHeight <= gridView.height) return 0
        var ratio = gridView.height / gridView.contentHeight
        return Math.max(40, parent.height * ratio)
      }
      y: {
        if (gridView.contentHeight <= gridView.height) return 0
        var maxY = parent.height - height
        var progress = gridView.contentY / (gridView.contentHeight - gridView.height)
        return maxY * progress
      }
      radius: parent.radius
      color: scrollThumbMouseArea.containsMouse ? Theme.primary : Theme.outline
      opacity: scrollThumbMouseArea.containsMouse ? 0.8 : 0.6
      
      Behavior on y {
        NumberAnimation {
          duration: 100
          easing.type: Easing.OutCubic
        }
      }
      
      Behavior on color {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      Behavior on opacity {
        NumberAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      MouseArea {
        id: scrollThumbMouseArea
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
      }
    }
  }
}
