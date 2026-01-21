import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"

Item {
  id: root
  
  property var groups: []
  property string selectedGroup: ""
  signal groupSelected(string group)
  
  // Horizontal scrolling list of group buttons
  ListView {
    anchors.fill: parent
    orientation: ListView.Horizontal
    spacing: Theme.spacing.sm
    clip: true
    
    model: {
      // Add "All" option at the beginning
      var allGroups = ["All"]
      return allGroups.concat(root.groups)
    }
    
    delegate: Rectangle {
      required property string modelData
      required property int index
      
      height: parent.height
      width: groupText.width + Theme.padding.lg * 2
      radius: Theme.radius.full
      
      color: {
        var isSelected = (modelData === "All" && root.selectedGroup === "") || 
                         (modelData === root.selectedGroup)
        if (isSelected) return Theme.primary_container
        if (groupMouseArea.containsMouse) return Theme.surface_container_high
        return Theme.surface_container
      }
      
      scale: groupMouseArea.pressed ? 0.95 : 1.0
      
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
      
      Text {
        id: groupText
        anchors.centerIn: parent
        text: modelData
        color: {
          var isSelected = (modelData === "All" && root.selectedGroup === "") || 
                           (modelData === root.selectedGroup)
          return isSelected ? Theme.on_primary_container : Theme.on_surface
        }
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        font.weight: {
          var isSelected = (modelData === "All" && root.selectedGroup === "") || 
                           (modelData === root.selectedGroup)
          return isSelected ? Theme.typography.weightMedium : Theme.typography.weightNormal
        }
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
      
      MouseArea {
        id: groupMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
          if (modelData === "All") {
            root.groupSelected("")
          } else {
            root.groupSelected(modelData)
          }
        }
      }
    }
  }
}
