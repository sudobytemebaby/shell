import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"
import "../../../../shared/theme"

Card {
  id: root
  
  required property var calendarManager
  
  padding: Config.padding.md
  
  ColumnLayout {
    anchors.fill: parent
    spacing: Config.spacing.xs
    
    // Time (big)
    Text {
      Layout.fillWidth: true
      text: root.calendarManager.timeString
      color: Theme.on_surface
      font.pixelSize: Config.typography.xxxl + 8
      font.family: Config.typography.sans
      font.weight: 600
      horizontalAlignment: Text.AlignHCenter
    }
    
    // Day of week
    Text {
      Layout.fillWidth: true
      text: root.calendarManager.dayOfWeek
      color: Theme.on_surface
      font.pixelSize: Config.typography.md
      font.family: Config.typography.sans
      font.weight: Config.typography.weightMedium
      horizontalAlignment: Text.AlignHCenter
      opacity: 0.9
    }
    
    // Date
    Text {
      Layout.fillWidth: true
      text: root.calendarManager.dateString
      color: Theme.on_surface_variant
      font.pixelSize: Config.typography.sm
      font.family: Config.typography.sans
      horizontalAlignment: Text.AlignHCenter
      opacity: 0.8
    }
  }
}
