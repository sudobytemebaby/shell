import QtQuick
import Quickshell
import "../../../../shared/theme"
import "../../../../shared/components/Animations"

Column {
  id: root
  
  spacing: Config.spacing.xs
  opacity: 0
  
  // Smooth fade-in animation
  AFade on opacity {}
  
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
    font.family: Config.typography.sans
    font.pixelSize: Config.typography.xxl * 4
    font.weight: Font.Medium
    color: Theme.on_surface

    text: Qt.formatDateTime(systemClock.date, "hh:mm")
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    text: Qt.formatDateTime(systemClock.date, "dddd, MMMM d")
    color: Theme.on_surface
    font.family: Config.typography.sans
    font.pixelSize: Config.typography.lg
    font.weight: Font.Normal
    opacity: 0.7
  }
}
