import QtQuick
import Quickshell

// ----------------------------------------------------------------------------
// Notification Center Manager
// ----------------------------------------------------------------------------
// Manages the persistent history of notifications shown in the Notification Center panel.
// Stores notifications in a simple array (no persistence across reboots currently).

Scope {
  id: manager
  
  // Visibility state of the Notification Center panel
  property bool visible: false
  
  // List of notifications history
  // Structure: [{ summary, body, appName, appIcon, date, time, id }, ...]
  property var notifications: []
  
  // --------------------------------------------------------------------------
  // Actions
  // --------------------------------------------------------------------------

  // Add a notification to history
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
  
  // Clear all notifications
  function clearAll() {
    notifications = []
  }
  
  // Remove a single notification by index
  function removeNotification(index) {
    var newNotifs = notifications.slice()
    newNotifs.splice(index, 1)
    notifications = newNotifs
  }
}