import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../../shared/components"
import "../../../../shared/theme"

Card {
  id: root
  
  required property var calendarManager
  
  padding: Theme.padding.lg
  
  ColumnLayout {
    anchors.fill: parent
    spacing: 2
    
    // Day names header
    DayOfWeekRow {
      Layout.fillWidth: true
      locale: Qt.locale()
      
      delegate: Text {
        required property string shortName
        
        text: shortName
        color: Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        font.weight: Theme.typography.weightMedium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: 0.8
      }
    }
    
    // Calendar grid
    MonthGrid {
      id: monthGrid
      Layout.fillWidth: true
      Layout.fillHeight: true
      
      month: root.calendarManager.displayMonth
      year: root.calendarManager.displayYear
      locale: Qt.locale()
      
      delegate: Rectangle {
        required property var model
        
        radius: height / 2
        color: {
          var now = new Date()
          var isToday = model.day === now.getDate() && 
                        model.month === now.getMonth() && 
                        model.year === now.getFullYear()
          
          if (isToday) return Theme.primary
          if (dateMouseArea.containsMouse && model.month === monthGrid.month) {
            return Theme.surface_container_high
          }
          return "transparent"
        }
        
        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
        
        Text {
          anchors.centerIn: parent
          text: model.day
          color: {
            var now = new Date()
            var isToday = model.day === now.getDate() && 
                          model.month === now.getMonth() && 
                          model.year === now.getFullYear()
            
            if (isToday) return Theme.on_primary
            if (model.month !== monthGrid.month) return Theme.on_surface_variant
            return Theme.on_surface
          }
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamily
          font.weight: {
            var now = new Date()
            var isToday = model.day === now.getDate() && 
                          model.month === now.getMonth() && 
                          model.year === now.getFullYear()
            return isToday ? Theme.typography.weightMedium : Theme.typography.weightNormal
          }
          opacity: model.month === monthGrid.month ? 1.0 : 0.3
          
          Behavior on color {
            ColorAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }
        }
        
        MouseArea {
          id: dateMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: model.month === monthGrid.month ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
      }
    }
  }
}
