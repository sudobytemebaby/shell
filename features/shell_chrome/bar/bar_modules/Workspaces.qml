import QtQuick
import Quickshell.Hyprland
import "../../../../shared/theme"

/**
 * Workspaces - Minimalist MD3 Indicator
 * 
 * A clean, no-nonsense workspace switcher with snappy, precise transitions.
 */
Row {
  id: root
  spacing: Theme.spacing.sm
  height: Theme.barHeight
  
  Repeater {
    model: 5

    Rectangle {
      id: indicator
      required property int index
      
      readonly property int wsId: index + 1
      readonly property bool isFocused: Hyprland.focusedWorkspace?.id === wsId
      readonly property bool isOccupied: {
        for (const ws of Hyprland.workspaces.values) {
          if (ws.id === wsId) return true;
        }
        return false;
      }
      
      anchors.verticalCenter: parent.verticalCenter
      
      // Dimensions: Understated pill for focus, simple dots for others
      width: isFocused ? 18 : (isOccupied ? 8 : 8)
      height: isFocused ? 8 : (isOccupied ? 8 : 8)
      radius: height / 2
      
      color: isFocused ? Theme.primary : (isOccupied ? Theme.on_surface_variant : Theme.surface_container_highest)
      
      // --- Snappy, Predictable Transitions ---
      Behavior on width {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
      }
      
      Behavior on color {
        ColorAnimation { duration: 200 }
      }
      
      MouseArea {
        id: ma
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => Hyprland.dispatch("workspace " + wsId)
      }
      
      // Minimal hover: Just a very slight scale shift
      scale: ma.containsMouse ? 1.1 : 1.0
      Behavior on scale { NumberAnimation { duration: 150 } }
    }
  }
}
