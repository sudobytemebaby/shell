import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"
import "../../../../shared/theme"

Card {
  id: root
  
  required property var calendarManager
  
  padding: Theme.padding.md
  
  ColumnLayout {
    anchors.fill: parent
    spacing: Theme.spacing.xs
    
    // Time (big)
    Text {
      Layout.fillWidth: true
      text: root.calendarManager.timeString
      color: Theme.on_surface
      font.pixelSize: Theme.typography.xxxl + 8
      font.family: Theme.typography.fontFamilyDisplay
      font.weight: 600
      horizontalAlignment: Text.AlignHCenter
    }
    
    // Day of week
    Text {
      Layout.fillWidth: true
      text: root.calendarManager.dayOfWeek
      color: Theme.on_surface
      font.pixelSize: Theme.typography.md
      font.family: Theme.typography.fontFamilyDisplay
      font.weight: Theme.typography.weightMedium
      horizontalAlignment: Text.AlignHCenter
      opacity: 0.9
    }
    
    // Date
    Text {
      Layout.fillWidth: true
      text: root.calendarManager.dateString
      color: Theme.on_surface_variant
      font.pixelSize: Theme.typography.sm
      font.family: Theme.typography.fontFamilyDisplay
      horizontalAlignment: Text.AlignHCenter
      opacity: 0.8
    }
  }
}
