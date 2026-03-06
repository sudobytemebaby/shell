import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

// Volume State Module - Native PipeWire
// Manages audio volume state (speakers and microphone) via PipeWire.
// Monitors both programmatic and external changes (e.g., media keys).

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

  property bool changingVolume: false
  property bool changingMic: false

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

  // Device information
  readonly property string inputDevice: audioSourceNode?.description ?? "Unknown"

  // ============================================================================
  // CACHED COMPUTED PROPERTIES
  // ============================================================================

  readonly property string volumeIcon: {
    if (volumeMuted) return ""
    if (volume === 0) return ""
    if (volume < 0.33) return ""
    if (volume < 0.66) return ""
    return ""
  }

  readonly property string micIcon: micMuted ? "󰍭" : "󰍬"

  readonly property string statusText: {
    if (volumeMuted) return "Muted"
    return Math.round(volume * 100) + "%"
  }

  // ============================================================================
  // EXTERNAL CHANGE SIGNALS (for OSD)
  // ============================================================================

  // Emitted when volume changes from an EXTERNAL source
  // (e.g., media keys, other applications)
  // NOT emitted during user interaction OR our own programmatic changes
  signal volumeChangedExternally(real volume, bool muted)
  signal micChangedExternally(real volume, bool muted)

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

  Connections {
    target: module.audioSink
    enabled: module.audioSink !== null

    function onVolumeChanged() {
      if (!module.audioSink) return
      if (!module.userInteracting && !module.changingVolume) {
        module.volumeChangedExternally(module.audioSink.volume, module.audioSink.muted)
      }
    }

    function onMutedChanged() {
      if (!module.audioSink) return
      if (!module.userInteracting && !module.changingVolume) {
        module.volumeChangedExternally(module.audioSink.volume, module.audioSink.muted)
      }
    }
  }

  Connections {
    target: module.audioSource
    enabled: module.audioSource !== null

    function onVolumeChanged() {
      if (!module.audioSource) return
      if (!module.userInteracting && !module.changingMic) {
        module.micChangedExternally(module.audioSource.volume, module.audioSource.muted)
      }
    }

    function onMutedChanged() {
      if (!module.audioSource) return
      if (!module.userInteracting && !module.changingMic) {
        module.micChangedExternally(module.audioSource.volume, module.audioSource.muted)
      }
    }
  }

  // ============================================================================
  // PUBLIC FUNCTIONS - Speaker/Output
  // ============================================================================

  function setVolume(newVolume) {
    if (!audioSink) {
      console.error("[Volume] No audio sink available!")
      return
    }
    changingVolume = true
    volumeChangeResetTimer.restart()
    audioSink.volume = Math.max(0, Math.min(1, newVolume))
  }

  function toggleVolumeMute() {
    if (!audioSink) {
      console.error("[Volume] No audio sink available!")
      return
    }
    changingVolume = true
    volumeChangeResetTimer.restart()
    audioSink.muted = !audioSink.muted
  }

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

  function setMicVolume(newVolume) {
    if (!audioSource) {
      console.error("[Volume] No audio source available!")
      return
    }
    changingMic = true
    micChangeResetTimer.restart()
    audioSource.volume = Math.max(0, Math.min(1, newVolume))
  }

  function toggleMicMute() {
    if (!audioSource) {
      console.error("[Volume] No audio source available!")
      return
    }
    changingMic = true
    micChangeResetTimer.restart()
    audioSource.muted = !audioSource.muted
  }

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
  // CLEANUP
  // ============================================================================

  Component.onDestruction: {
    volumeChangeResetTimer.stop()
    micChangeResetTimer.stop()
  }
}
