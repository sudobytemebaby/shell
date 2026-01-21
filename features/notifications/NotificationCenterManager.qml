import QtQuick
import Quickshell

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // List of notifications - no limit anymore!
  property var notifications: []
  
  // Function to add a notification to our history
  function addNotification(notification) {
    // Get current date/time
    var now = new Date()
    var dateStr = String(now.getMonth() + 1).padStart(2, '0') + "." + 
                  String(now.getDate()).padStart(2, '0') + "." + 
                  now.getFullYear()
    var timeStr = String(now.getHours()).padStart(2, '0') + ":" + 
                  String(now.getMinutes()).padStart(2, '0')
    
    // Create a plain object copy of the notification data
    var notifCopy = {
      summary: notification.summary,
      body: notification.body,
      appName: notification.appName,
      appIcon: notification.appIcon,
      date: dateStr,
      time: timeStr,
      id: notification.id
    }
    
    // Add to the beginning of the array (newest first)
    var newNotifs = [notifCopy].concat(notifications)
    
    notifications = newNotifs
  }
  
  // Function to clear all notifications
  function clearAll() {
    notifications = []
  }
  
  // Function to remove a single notification
  function removeNotification(index) {
    var newNotifs = notifications.slice()
    newNotifs.splice(index, 1)
    notifications = newNotifs
  }
}
