import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// ----------------------------------------------------------------------------
// Notification Manager
// ----------------------------------------------------------------------------
// Acts as the bridge between the system notification service (Quickshell.Services.Notifications)
// and the UI components.
// 1. Listens for new notifications.
// 2. Pushes them to NotificationCenterManager (history).
// 3. Pushes them to a local queue for temporary popup display.

Scope {
  id: manager
  
  // Reference to the notification center manager (for history)
  required property var notificationCenterManager
  
  // Queue of notification data to display as popups
  // Each item is { id, summary, body, appName, timestamp }
  property ListModel notificationQueue: ListModel {}
  
  // Counter for generating unique IDs for our internal queue
  property int notificationIdCounter: 0
  
  // --------------------------------------------------------------------------
  // System Notification Server
  // --------------------------------------------------------------------------
  NotificationServer {
    id: notifServer
    
    onNotification: notification => {
      // Add to notification center history
      notificationCenterManager.addNotification(notification)
      
      // Add to popup queue for immediate display
      addToQueue(notification)
    }
  }
  
  // --------------------------------------------------------------------------
  // Queue Management
  // --------------------------------------------------------------------------

  // Add a notification to the popup queue
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
  
  // Remove a notification from the popup queue
  function removeFromQueue(notifId) {
    for (var i = 0; i < notificationQueue.count; i++) {
      if (notificationQueue.get(i).id === notifId) {
        notificationQueue.remove(i, 1)
        break
      }
    }
  }
}