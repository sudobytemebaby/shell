pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
  id: root
  
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  
  // System state manager reference (set by shell.qml)
  property var systemState: null
  
  // Notification manager reference (set by shell.qml)
  property var notificationManager: null
  
  // ============================================================================
  // CONFIGURATION
  // ============================================================================
  
  // Battery thresholds (as percentages 0.0-1.0)
  property real lowBatteryThreshold: 0.20  // 20%
  property real criticalBatteryThreshold: 0.10  // 10%
  property real emergencyBatteryThreshold: 0.05  // 5%
  
  // Notification state tracking
  property bool lowBatteryNotified: false
  property bool criticalBatteryNotified: false
  property bool emergencyBatteryNotified: false
  property bool fullyChargedNotified: false
  
  // ============================================================================
  // BATTERY MONITORING
  // ============================================================================
  
  // Monitor battery percentage changes
  property real lastPercentage: 0.0
  property var lastState: null

  // Watch for battery percentage changes
  Binding {
    target: root
    property: "lastPercentage"
    value: root.systemState?.battery?.percentage ?? 0.0
    when: root.systemState && root.systemState.battery.ready
  }

  // Watch for battery state changes
  Binding {
    target: root
    property: "lastState"
    value: root.systemState?.battery?.state ?? null
    when: root.systemState && root.systemState.battery.ready
  }

  // Trigger checks when properties change
  onLastPercentageChanged: {
    checkBatteryLevels()
  }

  onLastStateChanged: {
    // State changes include charging/discharging state changes
    resetLowBatteryNotifications()
    checkBatteryLevels()
  }
  
  // ============================================================================
  // BATTERY LEVEL CHECKING
  // ============================================================================
  
  function checkBatteryLevels() {
    if (!systemState?.battery.ready || !systemState.battery.isLaptopBattery) return
    
    const battery = systemState.battery
    const percentage = battery.percentage
    
    // Emergency battery notification (5%)
    if (percentage <= emergencyBatteryThreshold && !battery.isCharging && !emergencyBatteryNotified) {
      sendNotification(
        "Emergency Battery", 
        `Battery at ${Math.round(percentage * 100)}%. Connect charger immediately!`, 
        "critical"
      )
      emergencyBatteryNotified = true
    }
    
    // Critical battery notification (10%)
    else if (percentage <= criticalBatteryThreshold && !battery.isCharging && !criticalBatteryNotified) {
      sendNotification(
        "Critical Battery", 
        `Battery at ${Math.round(percentage * 100)}%. Connect charger soon!`, 
        "critical"
      )
      criticalBatteryNotified = true
    }
    
    // Low battery notification (20%)
    else if (percentage <= lowBatteryThreshold && !battery.isCharging && !lowBatteryNotified) {
      sendNotification(
        "Low Battery", 
        `Battery at ${Math.round(percentage * 100)}%. Consider connecting charger.`, 
        "warning"
      )
      lowBatteryNotified = true
    }
    
    // Fully charged notification
    else if (battery.isFullyCharged && !battery.isCharging && !fullyChargedNotified) {
      sendNotification(
        "Battery Fully Charged", 
        "Battery is fully charged. You can disconnect the charger.", 
        "normal"
      )
      fullyChargedNotified = true
    }
    
    // Reset fully charged notification when no longer fully charged
    else if (!battery.isFullyCharged) {
      fullyChargedNotified = false
    }
  }
  
  // ============================================================================
  // NOTIFICATION FUNCTIONS
  // ============================================================================
  
  function sendNotification(title, message, urgency) {
    if (!notificationManager) {
      console.log(`[BatteryNotifier] ${title}: ${message}`)
      return
    }
    
    // Create notification using QuickShell notification system
    const notification = {
      summary: title,
      body: message,
      appName: "BatteryNotifier",
      urgency: urgency || "normal"
    }
    
    // Send through notification manager
    notificationManager.addToQueue(notification)
    
    console.log(`[BatteryNotifier] Sent: ${title} - ${message}`)
  }
  
  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================
  
  function resetLowBatteryNotifications() {
    lowBatteryNotified = false
    criticalBatteryNotified = false
    emergencyBatteryNotified = false
  }
  
  function resetAllNotifications() {
    resetLowBatteryNotifications()
    fullyChargedNotified = false
  }
  
  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================
  
  // Manual notification trigger (for testing)
  function notify() {
    if (!systemState?.battery.ready) {
      sendNotification("Battery Test", "Battery module not ready", "normal")
      return
    }
    
    const battery = systemState.battery
    sendNotification(
      "Battery Status", 
      `Current: ${Math.round(battery.percentage * 100)}% - ${battery.statusText}`, 
      "normal"
    )
  }
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    console.log("[BatteryNotifier] Service initialized")
    console.log("[BatteryNotifier] Thresholds - Low: 20%, Critical: 10%, Emergency: 5%")
  }
}
