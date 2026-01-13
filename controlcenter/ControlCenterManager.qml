import QtQuick
import Quickshell
import "managers" as Managers

// ControlCenterManager
// Now uses SystemStateManager's Network module instead of NetworkManager.
Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // NEW: Reference to system state (single source of truth)
  required property var systemState
  
  // Reference to power menu manager
  required property var powerMenuManager
  
  // ============================================================================
  // SUB-MANAGERS (Non-network/volume/brightness/bluetooth ones)
  // ============================================================================
  
  Managers.MediaManager {
    id: mediaManager
    controlCenterVisible: manager.visible
  }
  
  Managers.RecordingManager {
    id: recordingManager
  }
  
  Managers.UtilitiesManager {
    id: utilitiesManager
  }
  
  // ============================================================================
  // EXPOSE MANAGERS
  // ============================================================================
  
  readonly property var media: mediaManager
  readonly property var recording: recordingManager
  readonly property var utilities: utilitiesManager
  
  // ============================================================================
  // Audio Adapter (wraps Volume module)
  // ============================================================================
  // This makes the Volume module look like the old AudioManager
  // so we don't have to change VolumeSlider's API
  
  readonly property var audio: QtObject {
    // Expose volume from the module
    property real volume: manager.systemState.volume.volume
    
    // Wrap the module's setVolume function
    function setVolume(newVolume) {
      manager.systemState.volume.setVolume(newVolume)
    }
    
    // Optional: expose other functions if needed
    function toggleMute() {
      manager.systemState.volume.toggleVolumeMute()
    }
  }

  // ============================================================================
  // Brightness Adapter (wraps Brightness module)
  // ============================================================================
  readonly property var brightness: QtObject {
    property real brightness: manager.systemState.brightness.brightness

    function setBrightness(newBrightness) {
      manager.systemState.brightness.setBrightness(newBrightness)
    }
  }
}
