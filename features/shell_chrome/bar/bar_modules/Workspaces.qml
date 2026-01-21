import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../../../shared/theme"

RowLayout {
  spacing: Theme.spacingS

  implicitHeight: Theme.barHeight

  Repeater {
    model: 5

    Text {
      required property int index
      id: iconText
      
      // Use Layout properties for proper alignment - NO childrenRect!
      Layout.preferredWidth: implicitWidth
      Layout.preferredHeight: Theme.barHeight
      Layout.alignment: Qt.AlignVCenter
      
      verticalAlignment: Text.AlignVCenter
      
      // Icon selection based on workspace state
      text: {
        const ws = Hyprland.workspaces.values.find(w => w.id === index + 1)
        const focused = Hyprland.focusedWorkspace?.id === (index + 1)
        
        // Focused workspace
        if (focused) return "󰄯"  // 
        
        // Occupied workspace
        if (ws) return "󰄯"

        // Empty workspace
        return "󰻃"  // 
      }
      
      // Color based on state
      color: {
        const focused = Hyprland.focusedWorkspace?.id === (index + 1)
        const ws = Hyprland.workspaces.values.find(w => w.id === index + 1)
        
        // Focused - accent color
        if (focused) return Theme.accent
        
        // Occupied - border color (visible but not bright)
        if (ws) return Theme.border
        
        // Empty - very dim
        return Theme.border
      }
      
      font.pixelSize: Theme.fontSizeS
      font.family: Theme.fontFamily
      
      // Smooth color transition
      Behavior on color {
        ColorAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }

      MouseArea {
        anchors.fill: parent
        anchors.margins: -4  // Larger clickable area
        onClicked: (mouse) => Hyprland.dispatch("workspace " + (iconText.index + 1))
        cursorShape: Qt.PointingHandCursor
      }
    }
  }
}
