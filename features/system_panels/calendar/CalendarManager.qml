import QtQuick
import Quickshell

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Current date/time properties - updated every second
  property date currentDate: new Date()
  
  // Formatted strings for display
  readonly property string dayOfWeek: Qt.locale().dayName(currentDate.getDay(), Locale.LongFormat)
  readonly property string dateString: Qt.formatDate(currentDate, "dd.MM.yyyy")
  readonly property string timeString: Qt.formatTime(currentDate, "hh:mm:ss")
  
  // Calendar navigation - defaults to current month/year
  property int displayMonth: currentDate.getMonth()
  property int displayYear: currentDate.getFullYear()
  
  // Timer to update current date every second
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      manager.currentDate = new Date()
    }
  }
  
  // Functions for calendar navigation
  function nextMonth() {
    displayMonth++
    if (displayMonth > 11) {
      displayMonth = 0
      displayYear++
    }
  }
  
  function previousMonth() {
    displayMonth--
    if (displayMonth < 0) {
      displayMonth = 11
      displayYear--
    }
  }
  
  function goToToday() {
    var now = new Date()
    displayMonth = now.getMonth()
    displayYear = now.getFullYear()
  }
  
  // Reset to current month when opening
  onVisibleChanged: {
    if (visible) {
      goToToday()
    }
  }
}
