import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../Animations"

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
  
  Layout.preferredWidth: Config.sizes.segmentedWidth
  Layout.preferredHeight: Config.sizes.segmentedHeight
  radius: Config.radius.full
  color: Theme.surface_container_low
  border.width: 0.5
  border.color: Theme.surface_container

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
        Layout.margins: Config.spacing.xs + 2
        
        radius: Config.radius.full
        
        // Active state: Tertiary container
        // Inactive state: Transparent
        color: index === root.currentIndex ? Theme.tertiary_container : "transparent"

        RowLayout {
          anchors.centerIn: parent
          spacing: Config.spacing.xs

          Text {
            text: modelData.icon
            color: index === root.currentIndex ? Theme.on_tertiary_container : Theme.on_surface_variant
            font.pixelSize: Config.typography.md
            font.family: Config.typography.sans
            
            AColor on color {}
          }

          Text {
            text: modelData.text
            color: index === root.currentIndex ? Theme.on_tertiary_container : Theme.on_surface_variant
            font.pixelSize: Config.typography.sm
            font.family: Config.typography.sans
            font.weight: index === root.currentIndex ? Config.typography.weightMedium : Config.typography.weightNormal

            AColor on color {}
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
