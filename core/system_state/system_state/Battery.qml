import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery State Module
// Manages battery state using native UPower integration.
// Monitors battery percentage, charging state, and provides utility functions.
Scope {
  id: module
  
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  
  // Set by parent when user is interacting with controls
  // (Not used for battery, but included for consistency with other modules)
  property bool userInteracting: false
  
  // ============================================================================
  // UPOWER INTEGRATION
  // ============================================================================
  
  // Get the display device (aggregate battery for laptops)
  property var batteryDevice: UPower.displayDevice
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  // Battery percentage (0.0 to 1.0)
  readonly property real percentage: batteryDevice?.percentage ?? 0.0
  
  // Current battery state (Charging, Discharging, FullyCharged, etc.)
  readonly property var state: batteryDevice?.state ?? UPowerDeviceState.Unknown
  
  // Whether device is charging
  readonly property bool isCharging: state === UPowerDeviceState.Charging
  
  // Whether device is discharging (on battery power)
  readonly property bool isDischarging: state === UPowerDeviceState.Discharging
  
  // Whether battery is fully charged
  readonly property bool isFullyCharged: state === UPowerDeviceState.FullyCharged
  
  // Whether battery is present
  readonly property bool isPresent: batteryDevice?.isPresent ?? false
  
  // Whether this is actually a laptop battery
  readonly property bool isLaptopBattery: batteryDevice?.isLaptopBattery ?? false
  
  // Time remaining until empty (in seconds, 0 if charging)
  readonly property real timeToEmpty: batteryDevice?.timeToEmpty ?? 0
  
  // Time remaining until full (in seconds, 0 if discharging)
  readonly property real timeToFull: batteryDevice?.timeToFull ?? 0
  
  // Battery health percentage
  readonly property real health: batteryDevice?.healthPercentage ?? 100.0
  
  // Current energy in watt-hours
  readonly property real energy: batteryDevice?.energy ?? 0.0
  
  // Maximum capacity in watt-hours
  readonly property real capacity: batteryDevice?.energyCapacity ?? 0.0
  
  // Current change rate in watts (positive = charging, negative = discharging)
  readonly property real changeRate: batteryDevice?.changeRate ?? 0.0
  
  // Icon name provided by UPower
  readonly property string iconName: batteryDevice?.iconName ?? ""
  
  // Whether device info is ready
  readonly property bool ready: batteryDevice?.ready ?? false

  // ============================================================================
  // CACHED COMPUTED PROPERTIES
  // ============================================================================

  readonly property string batteryIcon: {
    if (isCharging) {
      if (percentage >= 0.99) return "󰂋"
      if (percentage >= 0.90) return "󰂊"
      if (percentage >= 0.80) return "󰢞"
      if (percentage >= 0.70) return "󰂉"
      if (percentage >= 0.60) return "󰢝"
      if (percentage >= 0.50) return "󰂈"
      if (percentage >= 0.40) return "󰂇"
      if (percentage >= 0.30) return "󰂆"
      if (percentage >= 0.20) return "󰢜"
      if (percentage >= 0.10) return "󰂅"
      return "󰂅"
    }
    
    if (percentage >= 0.99) return "󰂂"
    if (percentage >= 0.90) return "󰂁"
    if (percentage >= 0.80) return "󰂀"
    if (percentage >= 0.70) return "󰁿"
    if (percentage >= 0.60) return "󰁾"
    if (percentage >= 0.50) return "󰁽"
    if (percentage >= 0.40) return "󰁼"
    if (percentage >= 0.30) return "󰁻"
    if (percentage >= 0.20) return "󰁺"
    if (percentage >= 0.10) return "󰁹"
    return "󰁹"
  }

  readonly property string statusText: {
    if (!isLaptopBattery) return "No Battery"
    if (!isPresent) return "Not Present"
    if (isFullyCharged) return "Fully Charged"
    if (isCharging) return "Charging"
    if (isDischarging) return "Discharging"
    return "Unknown"
  }

  // ============================================================================
  // LOGGING (for debugging)
  // ============================================================================
  
  Component.onCompleted: {
    console.log("[Battery] Module initialized")
    console.log("[Battery] Is laptop battery:", isLaptopBattery)
    console.log("[Battery] Initial percentage:", Math.round(percentage * 100) + "%")
    console.log("[Battery] State:", statusText)
  }
}
