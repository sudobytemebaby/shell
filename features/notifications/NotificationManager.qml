import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
  id: manager
  
  // Reference to the notification center manager
  required property var notificationCenterManager
  
  // Queue of notification data to display
  // Each item is { id, summary, body, appName, timestamp }
  property ListModel notificationQueue: ListModel {}
  
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
    
    notificationQueue.append(notifData)
  }
  
  // Function to remove a notification from the queue
  function removeFromQueue(notifId) {
    for (var i = 0; i < notificationQueue.count; i++) {
      if (notificationQueue.get(i).id === notifId) {
        notificationQueue.remove(i, 1)
        break
      }
    }
  }
}
