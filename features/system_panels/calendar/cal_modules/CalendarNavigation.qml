import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"
import "../../../../shared/theme"

RowLayout {
  id: root
  
  required property var calendarManager
  
  spacing: Theme.spacing.sm
  
  // Previous month button
  RoundIconButton {
    Layout.preferredWidth: 40
    Layout.preferredHeight: 40
    icon: ""
    onClicked: root.calendarManager.previousMonth()
  }
  
  // Month/Year display
  Text {
    Layout.fillWidth: true
    text: {
      var monthName = Qt.locale().monthName(root.calendarManager.displayMonth, Locale.LongFormat)
      return monthName + " " + root.calendarManager.displayYear
    }
    color: Theme.on_surface
    font.pixelSize: Theme.typography.md
    font.family: Theme.typography.fontFamily
    font.weight: Theme.typography.weightMedium
    horizontalAlignment: Text.AlignHCenter
  }
  
  // Next month button
  RoundIconButton {
    Layout.preferredWidth: 40
    Layout.preferredHeight: 40
    icon: ""
    onClicked: root.calendarManager.nextMonth()
  }
}
