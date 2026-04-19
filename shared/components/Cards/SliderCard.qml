import QtQuick
import QtQuick.Layouts
import "../../theme"
import ".."

Card {
  id: root

  // Public API
  property string icon: ""
  property string label: ""
  required property real value        // 0.0 to 1.0
  signal moved(real newValue)         // Custom signal to avoid conflict

  // Optional customization
  property real minimumValue: 0.0
  property real maximumValue: 1.0
  property int tickCount: 11          // 0%, 10%, ..., 100%

  color: "transparent"
  border.width: 0

  ColumnLayout {
    anchors.fill: parent
    spacing: Config.spacing.md

    // Header row: icon + label + percentage
    RowLayout {
      Layout.fillWidth: true
      spacing: Config.spacing.sm
      
      // Label
      Text {
        Layout.fillWidth: true
        text: root.label
        color: Theme.on_surface
        font.pixelSize: Config.typography.md
        font.family: Config.typography.sans
        font.weight: Font.Medium
      }

      // Percentage
      Text {
        text: Math.round(root.value * 100) + "%"
        color: Theme.outline
        font.pixelSize: Config.typography.md
        font.family: Config.typography.sans
        font.weight: Font.Medium
      }
    }
    
    // Slider + tick marks
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Config.spacing.xs

      HorizontalSlider {
        Layout.fillWidth: true
        value: root.value
        minimumValue: root.minimumValue
        maximumValue: root.maximumValue
        tickCount: root.tickCount
        onMoved: newValue => root.moved(newValue)
      }
      
      TickMarks {
        Layout.fillWidth: true
        tickCount: root.tickCount
      }
    }
  }
}
