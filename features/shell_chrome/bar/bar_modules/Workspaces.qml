import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../../../shared/theme"

/**
 * Workspaces - Material You 3 Workspace Indicator
 * 
 * A minimalist, sophisticated workspace switcher following MD3 principles.
 * Features dynamic pill shapes, spring animations, and semantic coloring.
 */
RowLayout {
  id: root
  
  // Spacing between workspace indicators
  spacing: Theme.spacing.sm

  // Ensure the module fits within the bar's height constraints
  implicitHeight: Theme.barHeight

  Repeater {
    model: 5

    Rectangle {
      id: indicator
      required property int index
      
      readonly property int wsId: index + 1
      readonly property bool isFocused: Hyprland.focusedWorkspace?.id === wsId
      readonly property bool isOccupied: {
        // Efficiently check if the workspace exists in Hyprland's state
        return Hyprland.workspaces.values.some(w => w.id === wsId)
      }
      
      // --- Layout & Dimensions ---
      // Focused: Wide pill | Occupied: Standard dot | Empty: Small dot
      Layout.preferredWidth: isFocused ? 20 : (isOccupied ? 8 : 6)
      Layout.preferredHeight: isFocused ? 8 : (isOccupied ? 8 : 6)
      Layout.alignment: Qt.AlignVCenter
      
      radius: height / 2
      
      // --- Visual Style ---
      // Uses MD3 semantic tokens for a sophisticated look
      color: {
        if (isFocused) return Theme.primary
        if (isOccupied) return Theme.on_surface_variant
        return Theme.surface_container_highest
      }

      // --- Sophisticated Animations ---
      // Width uses a spring animation for that "Material" organic feel
      Behavior on Layout.preferredWidth {
        SpringAnimation {
          spring: 3
          damping: 0.4
          epsilon: 0.1
        }
      }
      
      // Height and color use smooth transitions
      Behavior on Layout.preferredHeight {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
      }
      
      Behavior on color {
        ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
      }
      
      // --- Interaction ---
      MouseArea {
        id: ma
        anchors.fill: parent
        // Expand hit area for better ergonomics without affecting visual layout
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: (mouse) => Hyprland.dispatch("workspace " + wsId)
      }
      
      // Subtle hover effects
      opacity: ma.containsMouse ? 1.0 : 0.9
      scale: ma.containsMouse ? 1.15 : 1.0
      
      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale {
        NumberAnimation {
          duration: 250
          easing.type: Easing.OutBack
        }
      }
    }
  }
}
