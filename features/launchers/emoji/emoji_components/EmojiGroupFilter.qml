import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"

/**
 * EmojiGroupFilter - Category filter buttons
 *
 * Displays a horizontal list of emoji category buttons including:
 * - "All" button (clears filter)
 * - Individual category buttons for each emoji group
 * - Visual feedback for selected category
 * - Material 3 styled buttons with hover/press states
 */
Item {
  id: root

  // ========== PROPERTIES ==========

  property var groups: []            // Array of emoji category names
  property string selectedGroup: ""  // Currently selected category (empty = "All")

  // ========== SIGNALS ==========

  signal groupSelected(string group)  // Emitted when user selects a category

  // ========== CACHED MODEL ==========

  // Cache the combined groups array to avoid recreating it on every binding re-evaluation
  // This is more efficient than computing ["All"] + groups in the model binding
  readonly property var groupsWithAll: {
    var allGroups = ["All"]
    return allGroups.concat(root.groups)
  }

  // ========== UI IMPLEMENTATION ==========

  // Horizontal scrolling list of category filter buttons
  ListView {
    anchors.fill: parent
    orientation: ListView.Horizontal
    spacing: Theme.spacing.sm
    clip: true

    model: root.groupsWithAll

    delegate: Rectangle {
      // Required properties from model
      required property string modelData
      required property int index

      // Computed property for selection state
      // "All" is selected when selectedGroup is empty, otherwise check for exact match
      readonly property bool isSelected: (modelData === "All" && root.selectedGroup === "") ||
                                         (modelData === root.selectedGroup)

      height: parent.height
      width: groupText.width + Theme.padding.lg * 2
      radius: Theme.radius.full

      // Dynamic color based on state
      color: {
        if (isSelected) return Theme.primary_container
        if (groupMouseArea.containsMouse) return Theme.surface_container_high
        return Theme.surface_container
      }

      // Click animation - slight scale down when pressed
      scale: groupMouseArea.pressed ? 0.95 : 1.0

      // Smooth color transition
      Behavior on color {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }

      // Smooth scale transition for click feedback
      Behavior on scale {
        NumberAnimation {
          duration: 100
          easing.type: Easing.OutCubic
        }
      }

      // Button text label
      Text {
        id: groupText
        anchors.centerIn: parent
        text: modelData
        color: isSelected ? Theme.on_primary_container : Theme.on_surface
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        font.weight: isSelected ? Theme.typography.weightMedium : Theme.typography.weightNormal

        // Smooth text color transition
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }

      // Mouse interaction area
      MouseArea {
        id: groupMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
          // "All" button clears the filter (empty string)
          // Other buttons set the filter to their category name
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
