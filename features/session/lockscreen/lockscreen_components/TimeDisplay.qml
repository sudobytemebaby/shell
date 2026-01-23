import QtQuick
import Quickshell
import "../../../../shared/theme"

Column {
  id: root
  
  spacing: Theme.spacing.sm
  opacity: 0
  
  // Smooth fade-in animation
  Behavior on opacity {
    NumberAnimation {
      duration: 500
      easing.type: Easing.OutCubic
    }
  }
  
  Component.onCompleted: opacity = 1.0
  
  // System clock for time display
  SystemClock {
    id: systemClock
    enabled: true
    precision: SystemClock.Seconds
  }
  
  Text {
    id: timeText
    anchors.horizontalCenter: parent.horizontalCenter
    font.family: Theme.typography.fontFamilyDisplay
    font.pixelSize: Theme.typography.xxl * 4
    font.weight: Font.Medium
    color: Theme.on_surface

    text: Qt.formatDateTime(systemClock.date, "hh:mm")
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    text: Qt.formatDateTime(systemClock.date, "dddd, MMMM d")
    color: Theme.on_surface
    font.family: Theme.typography.fontFamilyDisplay
    font.pixelSize: Theme.typography.lg
    font.weight: Font.Normal
    opacity: 0.7
  }
}
