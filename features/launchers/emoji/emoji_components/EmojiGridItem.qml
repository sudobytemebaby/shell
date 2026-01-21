import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"

Item {
  id: root
  
  // Properties
  property string emoji: ""
  property string name: ""
  property int itemIndex: 0
  property bool isSelected: false
  
  // Signal
  signal clicked()
  
  Rectangle {
    anchors {
      fill: parent
      margins: Theme.spacing.xs
    }
    radius: Theme.radius.xl
    
    color: {
      if (root.isSelected) return Theme.primary_container
      if (itemMouseArea.containsMouse) return Theme.surface_container_high
      return Theme.surface_container
    }
    
    scale: itemMouseArea.pressed ? 0.95 : 1.0
    
    Behavior on color {
      ColorAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
    
    Behavior on border.color {
      ColorAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
    
    Behavior on scale {
      NumberAnimation {
        duration: 100
        easing.type: Easing.OutCubic
      }
    }
    
    ColumnLayout {
      anchors.fill: parent
      spacing: Theme.spacing.xs
      
      // Emoji
      Text {
        Layout.fillWidth: true
        Layout.fillHeight: true
        text: root.emoji
        color: Theme.on_surface
        font.pixelSize: 32
        font.family: Theme.typography.fontFamily
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    
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
