import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

// Volume State Module - Enhanced with Device Detection
// Manages audio volume state (speakers and microphone) via PipeWire.
// Monitors both programmatic and external changes (e.g., media keys).
// Now includes device type detection (headphones vs speakers).
Scope {
  id: module
  
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  
  // Set by parent when user is interacting with controls
  // Prevents external change signals during user interaction
  property bool userInteracting: false
  
  // ============================================================================
  // INTERNAL STATE - Track if WE are making the change
  // ============================================================================
  
  // This prevents our own changes from triggering OSD
  property bool changingVolume: false
  property bool changingMic: false
  
  // ============================================================================
  // DEVICE DETECTION STATE
  // ============================================================================
  
  property string deviceName: "Unknown"
  property string deviceType: "speaker"  // "speaker", "headphones", or "unknown"
  property bool isHeadphones: false
  property string activeSinkName: ""
  property string activePort: ""
  
  // ============================================================================
  // PIPEWIRE INTEGRATION
  // ============================================================================
  
  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
  }
  
  // Audio sink (speakers/headphones)
  property var audioSinkNode: Pipewire.defaultAudioSink
  property var audioSink: audioSinkNode?.audio ?? null
  
  // Audio source (microphone)
  property var audioSourceNode: Pipewire.defaultAudioSource
  property var audioSource: audioSourceNode?.audio ?? null
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  // Speaker/output volume
  readonly property real volume: audioSink?.volume ?? 0.5
  readonly property bool volumeMuted: audioSink?.muted ?? false
  
  // Microphone/input volume
  readonly property real micVolume: audioSource?.volume ?? 0.5
  readonly property bool micMuted: audioSource?.muted ?? false
  
  // Device information (enhanced)
  readonly property string outputDevice: deviceName
  readonly property string inputDevice: audioSource?.description ?? "Unknown"
  
  // ============================================================================
  // EXTERNAL CHANGE SIGNALS (for OSD)
  // ============================================================================
  
  // Emitted when volume changes from an EXTERNAL source
  // (e.g., media keys, other applications)
  // NOT emitted during user interaction OR our own programmatic changes
  signal volumeChangedExternally(real volume, bool muted)
  signal micChangedExternally(real volume, bool muted)
  
  // ============================================================================
  // DEVICE DETECTION - Get default sink name
  // ============================================================================
  
  Process {
    id: sinkNameProcess
    command: ["pactl", "get-default-sink"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var sinkName = data.trim()
        module.activeSinkName = sinkName
        
        // Chain to get active port
        activePortProcess.running = true
        
        // Chain to get device description
        deviceDescriptionProcess.running = true
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[Volume] Error getting sink name:", data.trim())
        }
      }
    }
  }
  
  // ============================================================================
  // DEVICE DETECTION - Get active port
  // ============================================================================
  
  Process {
    id: activePortProcess
    command: ["sh", "-c", "pactl list sinks | awk -v sink=\"" + module.activeSinkName + "\" '$1 == \"Sink\" && $2 == \"#\" sink {found=1} found && /Active Port:/ {print $3; exit}'"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        module.activePort = data.trim()
        updateDeviceType()
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        // Ignore stderr from awk
      }
    }
  }
  
  // ============================================================================
  // DEVICE DETECTION - Get device description
  // ============================================================================
  
  Process {
    id: deviceDescriptionProcess
    command: ["sh", "-c", "pactl list sinks | awk -v sink=\"" + module.activeSinkName + "\" 'BEGIN{found=0} $0 ~ \"Name: \" sink {found=1} found && /device.description =/ {gsub(/\"/,\"\"); print $3; exit}'"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var rawName = data.trim()
        
        // Clean up the device name (same as your script)
        var cleanName = rawName
          .replace(/ Analog Stereo$/, "")
          .replace(/ Digital Stereo$/, "")
          .replace(/^.*HD Audio Controller /, "")
          .replace(/^Ryzen /, "")
        
        module.deviceName = cleanName || "Unknown"
        updateDeviceType()
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        // Ignore stderr
      }
    }
  }
  
  // ============================================================================
  // DEVICE TYPE DETECTION LOGIC
  // ============================================================================
  
  function updateDeviceType() {
    // Check active port first
    if (module.activePort.toLowerCase().indexOf("headphones") !== -1) {
      module.isHeadphones = true
      module.deviceType = "headphones"
      return
    }
    
    // Fallback to sink name check
    var sinkLower = module.activeSinkName.toLowerCase()
    if (sinkLower.indexOf("headphone") !== -1) {
      module.isHeadphones = true
      module.deviceType = "headphones"
      return
    }
    
    // USB devices without "speaker" are likely headphones
    if (sinkLower.indexOf("usb") !== -1 && sinkLower.indexOf("speaker") === -1) {
      module.isHeadphones = true
      module.deviceType = "headphones"
      return
    }
    
    // Default to speakers
    module.isHeadphones = false
    module.deviceType = "speaker"
  }
  
  // ============================================================================
  // DEVICE CHANGE DETECTION
  // ============================================================================
  
  // Watch for audio sink node changes (device switches)
  onAudioSinkNodeChanged: {
    // Device changed - refresh device info
    if (audioSinkNode !== null) {
      Qt.callLater(() => {
        if (!sinkNameProcess.running) {
          sinkNameProcess.running = true
        }
      })
    }
  }
  
  // ============================================================================
  // TIMERS - Reset internal change flags
  // ============================================================================
  
  Timer {
    id: volumeChangeResetTimer
    interval: 200
    onTriggered: module.changingVolume = false
  }
  
  Timer {
    id: micChangeResetTimer
    interval: 200
    onTriggered: module.changingMic = false
  }
  
  // ============================================================================
  // VOLUME MONITORING
  // ============================================================================
  
  // Watch for speaker volume changes
  Connections {
    target: module.audioSink
    enabled: module.audioSink !== null
    
    function onVolumeChanged() {
      if (!module.audioSink) return
      
      // Only emit signal if:
      // 1. User is NOT interacting with UI controls
      // 2. WE are not the ones making the change
      if (!module.userInteracting && !module.changingVolume) {
        module.volumeChangedExternally(
          module.audioSink.volume,
          module.audioSink.muted
        )
      }
    }
    
    function onMutedChanged() {
      if (!module.audioSink) return
      
      if (!module.userInteracting && !module.changingVolume) {
        module.volumeChangedExternally(
          module.audioSink.volume,
          module.audioSink.muted
        )
      }
    }
  }
  
  // Watch for microphone volume changes
  Connections {
    target: module.audioSource
    enabled: module.audioSource !== null
    
    function onVolumeChanged() {
      if (!module.audioSource) return
      
      if (!module.userInteracting && !module.changingMic) {
        module.micChangedExternally(
          module.audioSource.volume,
          module.audioSource.muted
        )
      }
    }
    
    function onMutedChanged() {
      if (!module.audioSource) return
      
      if (!module.userInteracting && !module.changingMic) {
        module.micChangedExternally(
          module.audioSource.volume,
          module.audioSource.muted
        )
      }
    }
  }
  
  // ============================================================================
  // PUBLIC FUNCTIONS - Speaker/Output
  // ============================================================================
  
  // Set output volume level
  // @param newVolume - value between 0.0 and 1.0
  function setVolume(newVolume) {
    if (!audioSink) {
      console.error("[Volume] No audio sink available!")
      return
    }
    
    // Mark that WE are changing volume (prevents OSD)
    changingVolume = true
    volumeChangeResetTimer.restart()
    
    // Clamp between 0 and 1
    newVolume = Math.max(0, Math.min(1, newVolume))
    audioSink.volume = newVolume
  }
  
  // Toggle output mute state
  function toggleVolumeMute() {
    if (!audioSink) {
      console.error("[Volume] No audio sink available!")
      return
    }
    
    changingVolume = true
    volumeChangeResetTimer.restart()
    
    audioSink.muted = !audioSink.muted
  }
  
  // Set output mute state
  // @param muted - true to mute, false to unmute
  function setVolumeMute(muted) {
    if (!audioSink) {
      console.error("[Volume] No audio sink available!")
      return
    }
    
    changingVolume = true
    volumeChangeResetTimer.restart()
    
    audioSink.muted = muted
  }
  
  // ============================================================================
  // PUBLIC FUNCTIONS - Microphone/Input
  // ============================================================================
  
  // Set input volume level
  // @param newVolume - value between 0.0 and 1.0
  function setMicVolume(newVolume) {
    if (!audioSource) {
      console.error("[Volume] No audio source available!")
      return
    }
    
    changingMic = true
    micChangeResetTimer.restart()
    
    newVolume = Math.max(0, Math.min(1, newVolume))
    audioSource.volume = newVolume
  }
  
  // Toggle input mute state
  function toggleMicMute() {
    if (!audioSource) {
      console.error("[Volume] No audio source available!")
      return
    }
    
    changingMic = true
    micChangeResetTimer.restart()
    
    audioSource.muted = !audioSource.muted
  }
  
  // Set input mute state
  // @param muted - true to mute, false to unmute
  function setMicMute(muted) {
    if (!audioSource) {
      console.error("[Volume] No audio source available!")
      return
    }
    
    changingMic = true
    micChangeResetTimer.restart()
    
    audioSource.muted = muted
  }
  
  // ============================================================================
  // UTILITY FUNCTIONS - Enhanced with device-aware icons
  // ============================================================================
  
  // Get appropriate volume icon based on level, mute state, and device type
  function getVolumeIcon(volume, muted) {
    // Muted state
    if (muted) return "󰖁"
    
    // Headphones - use headphone icon
    if (module.isHeadphones) {
      return "󰋋"  // Headphones icon
    }
    
    // Speakers - use volume-based icons
    if (volume == 0) return "󰕿"
    if (volume < 0.33) return "󰕿"
    if (volume < 0.66) return "󰖀"
    return "󰕾"
  }
  
  // Get microphone icon based on mute state
  function getMicIcon(muted) {
    return muted ? "󰍭" : "󰍬"
  }
  
  // Get status text for display (e.g., "Headphones 75%")
  function getStatusText() {
    var percentage = Math.round(module.volume * 100) + "%"
    
    if (module.volumeMuted) {
      return "Muted"
    }
    
    return percentage
  }
  
  // Get detailed status (device name + volume)
  function getDetailedStatus() {
    var percentage = Math.round(module.volume * 100) + "%"
    
    if (module.volumeMuted) {
      return module.deviceName + " (Muted)"
    }
    
    return module.deviceName + " " + percentage
  }
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    // Get initial device info
    sinkNameProcess.running = true
  }
}
