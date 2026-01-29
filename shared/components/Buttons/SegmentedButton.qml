import QtQuick
import QtQuick.Layouts
import "../../theme"

/**
 * SegmentedButton
 *
 * A generic segmented toggle switch that supports multiple mutually exclusive options.
 *
 * PROPERTIES:
 * - options: Array of objects with 'icon' and 'text' properties.
 *   Example: [{ icon: "A", text: "Option A" }, { icon: "B", text: "Option B" }]
 * - currentIndex: The index of the currently selected option.
 *
 * SIGNALS:
 * - clicked(int index): Emitted when an option is selected.
 *
 * USAGE:
 * SegmentedButton {
 *   options: [
 *     { icon: "󰖔", text: "Dark" },
 *     { icon: "󰖙", text: "Light" }
 *   ]
 *   currentIndex: lightMode ? 1 : 0
 *   onClicked: index => { ... }
 * }
 */
Rectangle {
  id: root
  
  Layout.preferredWidth: 200
  Layout.preferredHeight: 40
  radius: Theme.radius.full
  color: Theme.surface_container_high
  border.width: 0.5
  border.color: Theme.surface_container_high

  /**
   * List of options to display.
   * Each item should be: { icon: string, text: string }
   */
  property var options: []

  /**
   * Currently active index
   */
  property int currentIndex: 0

  /**
   * Emitted when user selects an option
   * @param index The index of the selected option
   */
  signal clicked(int index)

  RowLayout {
    anchors.fill: parent
    spacing: 0

    Repeater {
      model: root.options

      Rectangle {
        required property var modelData
        required property int index

        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.margins: 4
        
        radius: Theme.radius.full
        
        // Active state: Tertiary container
        // Inactive state: Transparent
        color: index === root.currentIndex ? Theme.tertiary_container : "transparent"

        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }

        RowLayout {
          anchors.centerIn: parent
          spacing: Theme.spacing.xs

          Text {
            text: modelData.icon
            color: index === root.currentIndex ? Theme.on_tertiary_container : Theme.on_surface_variant
            font.pixelSize: Theme.typography.md
            font.family: Theme.typography.fontFamily
            
            Behavior on color { ColorAnimation { duration: 200 } }
          }

          Text {
            text: modelData.text
            color: index === root.currentIndex ? Theme.on_tertiary_container : Theme.on_surface_variant
            font.pixelSize: Theme.typography.sm
            font.family: Theme.typography.fontFamily
            font.weight: index === root.currentIndex ? Theme.typography.weightMedium : Theme.typography.weightNormal

            Behavior on color { ColorAnimation { duration: 200 } }
          }
        }

        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor

          onClicked: {
            if (root.currentIndex !== index) {
              root.clicked(index)
            }
          }
        }
      }
    }
  }
}
