import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
  id: manager
  
  // Reference to the notification center manager
  required property var notificationCenterManager
  
  // Queue of notification data to display
  // Each item is { id, summary, body, appName, timestamp }
  property var notificationQueue: []
  
  // Counter for generating unique IDs
  property int notificationIdCounter: 0
  
  // The actual notification server
  NotificationServer {
    id: notifServer
    
    onNotification: notification => {
      // Add to notification center history
      notificationCenterManager.addNotification(notification)
      
      // Add to popup queue
      addToQueue(notification)
    }
  }
  
  // Function to add a notification to the queue
  function addToQueue(notification) {
    var notifData = {
      id: manager.notificationIdCounter++,
      summary: notification.summary,
      body: notification.body,
      appName: notification.appName,
      timestamp: Date.now()
    }
    
    var newQueue = notificationQueue.slice()
    newQueue.push(notifData)
    notificationQueue = newQueue
  }
  
  // Function to remove a notification from the queue
  function removeFromQueue(notifId) {
    var newQueue = []
    for (var i = 0; i < notificationQueue.length; i++) {
      if (notificationQueue[i].id !== notifId) {
        newQueue.push(notificationQueue[i])
      }
    }
    notificationQueue = newQueue
  }
}
