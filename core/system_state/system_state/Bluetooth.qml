import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import "../" as Core

// Bluetooth State Module - Event-Driven with Native Quickshell API
// Uses Quickshell.Bluetooth for reactive state monitoring without polling
Scope {
  id: module

  // ============================================================================
  // DEPENDENCIES
  // ============================================================================

  property bool userInteracting: false

  // ============================================================================
  // NATIVE BLUETOOTH ADAPTER (Event-Driven - NO POLLING!)
  // ============================================================================

  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter

  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================

  // Primary state from native API (reactive property bindings)
  readonly property bool powered: adapter ? adapter.enabled : fallbackPowered
  readonly property bool blocked: adapter?.state === BluetoothAdapterState.Blocked
  readonly property bool discovering: adapter ? adapter.discovering : false

  // Connected devices computed from adapter
  readonly property var connectedDevices: {
    if (!adapter || !adapter.devices) return []

    var devices = []
    var deviceValues = adapter.devices.values

    for (var i = 0; i < deviceValues.length; i++) {
      var dev = deviceValues[i]
      if (dev && dev.connected) {
        devices.push({
          name: dev.name || "Unknown Device",
          address: dev.address || "",
          icon: "󰂯"
        })
      }
    }

    return devices
  }

  readonly property bool hasConnectedDevice: connectedDevices.length > 0
  readonly property int connectedDeviceCount: connectedDevices.length
  readonly property string connectedDeviceName: {
    if (connectedDeviceCount === 0) return ""
    return connectedDevices[0].name || ""
  }

  readonly property bool ready: adapter !== null || fallbackReady
  property bool changingState: false

  // ============================================================================
  // FALLBACK STATE (Only used if native API unavailable)
  // ============================================================================

  property bool fallbackPowered: false
  property bool fallbackReady: false

  // ============================================================================
  // REACTIVE STATE MONITORING (Event-Driven!)
  // ============================================================================

  Connections {
    target: adapter
    enabled: adapter !== null

    // Triggers when adapter power state changes
    function onStateChanged() {
      console.log("[Bluetooth] State changed:", adapter.state)

      if (!module.changingState && !module.userInteracting) {
        module.bluetoothChangedExternally(
          module.powered,
          module.hasConnectedDevice,
          module.connectedDeviceName
        )
      }
    }

    // Triggers when enabled property changes
    function onEnabledChanged() {
      console.log("[Bluetooth] Enabled changed:", adapter.enabled)

      if (!module.changingState && !module.userInteracting) {
        module.bluetoothChangedExternally(
          module.powered,
          module.hasConnectedDevice,
          module.connectedDeviceName
        )
      }
    }

    // Triggers when discovery state changes
    function onDiscoveringChanged() {
      console.log("[Bluetooth] Discovery changed:", adapter.discovering)
    }
  }

  // Monitor device list changes (when devices connect/disconnect)
  Connections {
    target: adapter?.devices
    enabled: adapter !== null && adapter.devices !== null

    function onCountChanged() {
      console.log("[Bluetooth] Device count changed:", adapter.devices.values.length)

      if (!module.changingState && !module.userInteracting) {
        module.bluetoothChangedExternally(
          module.powered,
          module.hasConnectedDevice,
          module.connectedDeviceName
        )
      }
    }
  }

  // ============================================================================
  // FALLBACK POLLING (ONLY if native API unavailable)
  // ============================================================================

  Process {
    id: bluetoothStateProcess
    command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -i powered | awk '{print $NF}'"]

    stdout: SplitParser {
      onRead: data => {
        if (!data) return

        var line = data.trim().toLowerCase()
        var wasPowered = module.fallbackPowered

        module.fallbackPowered = (line === "yes" || line === "on")

        // If powered, check devices
        if (module.fallbackPowered) {
          connectedDevicesProcess.running = true
        }

        module.fallbackReady = true

        // Emit change if needed
        if (!module.changingState && !module.userInteracting && wasPowered !== module.fallbackPowered) {
          module.bluetoothChangedExternally(
            module.powered,
            module.hasConnectedDevice,
            module.connectedDeviceName
          )
        }
      }
    }

    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[Bluetooth] Error:", data.trim())
        }
      }
    }
  }

  // Fallback connected devices check
  Process {
    id: connectedDevicesProcess
    command: ["bluetoothctl", "devices", "Connected"]

    property var fallbackDevices: []

    stdout: SplitParser {
      onRead: data => {
        if (!data || !data.trim()) {
          connectedDevicesProcess.fallbackDevices = []
          return
        }

        var lines = data.trim().split('\n').filter(line => line.includes('Device'))
        var devices = []

        for (var i = 0; i < lines.length; i++) {
          var lineParts = lines[i].split(' ')
          if (lineParts.length >= 3) {
            devices.push({
              name: lineParts.slice(2).join(' '),
              address: lineParts[1],
              icon: "󰂯"
            })
          }
        }

        connectedDevicesProcess.fallbackDevices = devices
      }
    }
  }

  // Fallback polling timer - only runs if native API unavailable
  Timer {
    id: fallbackPollTimer
    interval: 30000  // 30 seconds (much longer than before)
    running: adapter === null  // Only runs if no native adapter
    repeat: true

    onTriggered: {
      if (!bluetoothStateProcess.running) {
        bluetoothStateProcess.running = true
      }
    }
  }

  // ============================================================================
  // TIMERS
  // ============================================================================

  // Reset changing flag after user action
  Timer {
    id: stateChangeResetTimer
    interval: 500
    onTriggered: {
      module.changingState = false
    }
  }

  // ============================================================================
  // CACHED COMPUTED PROPERTIES (Noctalia Pattern)
  // ============================================================================

  readonly property string bluetoothIcon: {
    if (!powered) return "󰂲"
    if (hasConnectedDevice) return "󰂯"
    return "󰂯"
  }

  readonly property string statusText: {
    if (!powered) return "Off"
    if (!hasConnectedDevice) return "On"
    if (connectedDeviceCount === 1) return connectedDeviceName
    return connectedDeviceCount + " devices"
  }

  readonly property string detailedStatus: {
    if (!powered) return "Bluetooth is off"
    if (!hasConnectedDevice) return "No devices connected"
    if (connectedDeviceCount === 1) return "Connected to " + connectedDeviceName
    return connectedDeviceCount + " devices connected"
  }

  // ============================================================================
  // EXTERNAL CHANGE SIGNAL
  // ============================================================================

  signal bluetoothChangedExternally(bool powered, bool hasDevice, string deviceName)

  // ============================================================================
  // CONTROL FUNCTIONS
  // ============================================================================

  function togglePower() {
    setPower(!powered)
  }

  function setPower(enabled) {
    changingState = true
    stateChangeResetTimer.restart()

    // Try native API first
    if (adapter) {
      try {
        adapter.enabled = enabled
        console.log("[Bluetooth] Set power via native API:", enabled)
        return
      } catch (e) {
        console.error("[Bluetooth] Failed to set enabled via native API:", e)
      }
    }

    // Fallback to bluetoothctl
    console.log("[Bluetooth] Using bluetoothctl fallback for power:", enabled)
    Core.ProcessUtils.runCommand(
      module,
      ["bluetoothctl", "power", enabled ? "on" : "off"],
      () => {
        console.log("[Bluetooth] Power command succeeded")
        // Native API will update automatically via Connections
        // Fallback will update on next poll
      },
      (code, error) => {
        console.error("[Bluetooth] Failed to set power:", error)
        changingState = false
      }
    )
  }

  function connectDevice(address) {
    if (!address) return

    changingState = true
    stateChangeResetTimer.restart()

    // Try native API first
    if (adapter && adapter.devices) {
      var deviceValues = adapter.devices.values
      for (var i = 0; i < deviceValues.length; i++) {
        var dev = deviceValues[i]
        if (dev && dev.address === address) {
          try {
            dev.connect()
            console.log("[Bluetooth] Connecting via native API:", dev.name)
            return
          } catch (e) {
            console.error("[Bluetooth] Failed to connect via native API:", e)
          }
        }
      }
    }

    // Fallback to bluetoothctl
    console.log("[Bluetooth] Using bluetoothctl fallback for connect:", address)
    Core.ProcessUtils.runCommand(
      module,
      ["bluetoothctl", "connect", address],
      () => {
        console.log("[Bluetooth] Connect command succeeded")
      },
      (code, error) => {
        console.error("[Bluetooth] Failed to connect:", error)
        changingState = false
      }
    )
  }

  function disconnectDevice(address) {
    if (!address) return

    changingState = true
    stateChangeResetTimer.restart()

    // Try native API first
    if (adapter && adapter.devices) {
      var deviceValues = adapter.devices.values
      for (var i = 0; i < deviceValues.length; i++) {
        var dev = deviceValues[i]
        if (dev && dev.address === address) {
          try {
            dev.disconnect()
            console.log("[Bluetooth] Disconnecting via native API:", dev.name)
            return
          } catch (e) {
            console.error("[Bluetooth] Failed to disconnect via native API:", e)
          }
        }
      }
    }

    // Fallback to bluetoothctl
    console.log("[Bluetooth] Using bluetoothctl fallback for disconnect:", address)
    Core.ProcessUtils.runCommand(
      module,
      ["bluetoothctl", "disconnect", address],
      () => {
        console.log("[Bluetooth] Disconnect command succeeded")
      },
      (code, error) => {
        console.error("[Bluetooth] Failed to disconnect:", error)
        changingState = false
      }
    )
  }

  function openManager() {
    Core.ProcessUtils.runCommandAsync(
      module,
      ["kitty", "--class", "floating_term_s", "-e", "bluetui"]
    )
  }

  // ============================================================================
  // UTILITY FUNCTIONS (Legacy - use cached properties instead)
  // ============================================================================

  function getBluetoothIcon(powered, hasDevice) {
    return module.bluetoothIcon
  }

  function getStatusText() {
    return module.statusText
  }

  function getDetailedStatus() {
    return module.detailedStatus
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  Component.onCompleted: {
    if (adapter) {
      console.log("[Bluetooth] Initialized with native Quickshell.Bluetooth API")
      console.log("[Bluetooth] Adapter:", adapter.name || "default")
      console.log("[Bluetooth] Adapter ID:", adapter.adapterId || "unknown")
      console.log("[Bluetooth] Initial state:", adapter.enabled ? "enabled" : "disabled")
      console.log("[Bluetooth] Initial devices:", adapter.devices ? adapter.devices.values.length : 0)
    } else {
      console.warn("[Bluetooth] Native API unavailable, using fallback polling mode (30s interval)")
      bluetoothStateProcess.running = true
    }
  }

  // ============================================================================
  // CLEANUP (Noctalia Pattern)
  // ============================================================================

  Component.onDestruction: {
    // Stop timers
    fallbackPollTimer.stop()
    stateChangeResetTimer.stop()

    // Stop any running fallback processes
    if (bluetoothStateProcess.running) bluetoothStateProcess.running = false
    if (connectedDevicesProcess.running) connectedDevicesProcess.running = false
  }
}
