import QtQuick
import Quickshell

// OsdManager - Manages on-screen display popups
// Listens to SystemStateManager's modules for external changes
Scope {
  id: manager
  
  // Reference to system state (single source of truth)
  required property var systemState

  // OSD type constants
  readonly property string typeNone: "none"
  readonly property string typeVolume: "volume"
  readonly property string typeMic: "mic"
  readonly property string typeBrightness: "brightness"

  // Current OSD display state
  property string currentType: typeNone
  property real currentValue: 0.0
  property bool currentMuted: false
  property string currentIcon: ""

  // Hide timer
  Timer {
    id: hideTimer
    interval: 2000
    running: false
    repeat: false
    
    onTriggered: {
      manager.currentType = manager.typeNone
    }
  }

  // Helper to show OSD
  function showOsd(type, value, muted, icon) {
    currentType = type
    currentValue = value
    currentMuted = muted
    currentIcon = icon
    
    hideTimer.restart()
  }
  
  // Helper to update current OSD value (for slider dragging)
  function updateCurrentValue(value) {
    currentValue = value
    hideTimer.restart()
  }

  // ============================================================================
  // VOLUME MODULE - Listen for external changes
  // ============================================================================
  
  Connections {
    target: manager.systemState ? manager.systemState.volume : null
    enabled: manager.systemState && manager.systemState.volume
    
    function onVolumeChangedExternally(volume, muted) {
      var icon = manager.systemState.volume.getVolumeIcon(volume, muted)
      manager.showOsd(manager.typeVolume, volume, muted, icon)
    }
    
    function onMicChangedExternally(volume, muted) {
      var icon = manager.systemState.volume.getMicIcon(muted)
      manager.showOsd(manager.typeMic, volume, muted, icon)
    }
  }
  
  // ============================================================================
  // BRIGHTNESS MODULE - Listen for external changes
  // ============================================================================
  
  Connections {
    target: manager.systemState ? manager.systemState.brightness : null
    enabled: manager.systemState && manager.systemState.brightness
    
    function onBrightnessChangedExternally(brightness) {
      var icon = manager.systemState.brightness.getBrightnessIcon(brightness)
      manager.showOsd(manager.typeBrightness, brightness, false, icon)
    }
  }
}
