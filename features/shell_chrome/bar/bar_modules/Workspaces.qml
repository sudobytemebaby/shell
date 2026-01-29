import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../../../shared/theme"

RowLayout {
  spacing: Theme.spacing.sm

  implicitHeight: Theme.barHeight

  Repeater {
    model: 5

    Rectangle {
      required property int index
      id: workspaceRect
      
      // Use Layout properties for proper alignment
      Layout.preferredWidth: Theme.workspaceIndicatorSize
      Layout.preferredHeight: Theme.workspaceIndicatorSize
      Layout.alignment: Qt.AlignVCenter
      
      radius: Theme.radius.full
      
      // Color based on state
      color: {
        const focused = Hyprland.focusedWorkspace?.id === (index + 1)
        const ws = Hyprland.workspaces.values.find(w => w.id === index + 1)

        // Focused - accent color
        if (focused) return Theme.primary
        
        // Occupied - border color (visible but not bright)
        if (ws) return Theme.outline
        
        // Empty - very dim
        return Theme.surface_container_highest
      }
      
      // Smooth color transition
      Behavior on color {
        ColorAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }

      MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        onClicked: (mouse) => Hyprland.dispatch("workspace " + (index + 1))
        cursorShape: Qt.PointingHandCursor
      }
    }
  }
}
