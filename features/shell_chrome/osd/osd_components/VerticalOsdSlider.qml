import QtQuick
import "../../../../shared/theme"

Item {
  id: root
  
  property real value: 0.5
  property bool isMuted: false
  property bool isDragging: false
  
  signal sliderMoved(real newValue)
  
  implicitWidth: 40
  implicitHeight: 120
  
  Row {
    anchors.centerIn: parent
    spacing: Theme.spacing.xs
    height: parent.height
    
    // Tick marks column
    Column {
      width: 12
      height: parent.height
      spacing: 0
      
      Repeater {
        model: 11
        
        Item {
          required property int index
          width: parent.width
          height: parent.height / 11
          
          Rectangle {
            anchors {
              right: parent.right
              verticalCenter: parent.verticalCenter
            }
            width: parent.parent.parent.children[0].children[index] && index % 5 === 0 ? 6 : 4
            height: 2
            radius: 1
            color: Theme.outline
            opacity: index % 5 === 0 ? 0.8 : 0.6
          }
        }
      }
    }
    
    // Track container
    Item {
      width: 20
      height: parent.height
      
      // Background track
      Rectangle {
        id: track
        anchors.centerIn: parent
        width: 6
        height: parent.height
        radius: Theme.radius.sm
        color: Theme.surface_container_highest
        
        // Filled portion
        Rectangle {
          anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
          }
          height: parent.height * root.value
          radius: parent.radius
          color: root.isMuted ? Theme.outline : Theme.primary
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }
      }
      
      // Draggable handle
      Rectangle {
        id: handle
        y: Math.max(0, Math.min(track.height - height, track.height - (track.height * root.value) - height / 2))
        anchors.horizontalCenter: track.horizontalCenter
        width: 16
        height: 16
        radius: Theme.radius.full
        color: root.isMuted ? Theme.outline : Theme.primary
        border.color: Theme.surface_container_low
        border.width: 2
        
        scale: handleArea.pressed || handleArea.containsMouse ? 1.2 : 1.0
        
        Behavior on color {
          ColorAnimation { duration: 200 }
        }
        
        Behavior on scale {
          NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
        
        MouseArea {
          id: handleArea
          anchors.fill: parent
          anchors.margins: -8
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          drag.target: handle
          drag.axis: Drag.YAxis
          drag.minimumY: -handle.height / 2
          drag.maximumY: track.height - handle.height / 2
          
          onPressed: {
            root.isDragging = true
          }
          
          onReleased: {
            root.isDragging = false
          }
          
          onPositionChanged: {
            if (drag.active) {
              var newValue = 1.0 - ((handle.y + handle.height / 2) / track.height)
              newValue = Math.max(0, Math.min(1, newValue))
              root.sliderMoved(newValue)
            }
          }
        }
      }
    }
  }
}