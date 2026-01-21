import QtQuick
import Quickshell
import Quickshell.Io
import "../" as Core

// Network State Module - loopback filtering
Scope {
  id: module
  
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  
  property bool userInteracting: false
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  property bool wifiEnabled: false
  property bool wifiConnected: false
  property string wifiSsid: ""
  property int wifiSignalStrength: 0  // 0-100
  property string connectionType: "unknown"  // "wifi", "ethernet", "none", "unknown"
  property string interfaceName: ""
  property bool ready: false
  property bool changingState: false

  // ============================================================================
  // CACHED COMPUTED PROPERTIES (Noctalia Pattern)
  // ============================================================================

  readonly property string networkIcon: {
    if (connectionType === "ethernet") {
      return "󰈀"  // Ethernet icon
    } else if (connectionType === "wifi" && wifiConnected) {
      // WiFi icons based on signal strength
      if (wifiSignalStrength >= 75) return "󰤨"
      if (wifiSignalStrength >= 50) return "󰤥"
      if (wifiSignalStrength >= 25) return "󰤢"
      return "󰤟"
    } else if (!wifiEnabled) {
      return "󰤭"  // WiFi disabled
    } else {
      return "󰤮"  // Disconnected
    }
  }

  readonly property string statusText: {
    if (!wifiEnabled) return "Disabled"
    if (connectionType === "ethernet") return "Ethernet"
    if (connectionType === "wifi" && wifiConnected) {
      return wifiSsid || "Connected"
    }
    if (connectionType === "none") return "Disconnected"
    return "Unknown"
  }

  readonly property string detailedStatus: {
    if (!wifiEnabled) return "WiFi is disabled"
    if (connectionType === "ethernet") return "Connected via Ethernet"
    if (connectionType === "wifi" && wifiConnected) {
      return "Connected to " + (wifiSsid || "WiFi") + " (" + wifiSignalStrength + "%)"
    }
    if (connectionType === "none") return "No network connection"
    return "Unknown connection state"
  }

  // ============================================================================
  // EXTERNAL CHANGE SIGNAL
  // ============================================================================
  
  signal networkChangedExternally(bool wifiEnabled, bool wifiConnected, string ssid)
  
  // ============================================================================
  // WIFI RADIO STATE READER
  // ============================================================================
  
  Process {
    id: wifiRadioProcess
    command: ["sh", "-c", "nmcli radio wifi 2>/dev/null"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var state = data.trim().toLowerCase()
        var wasEnabled = module.wifiEnabled
        
        module.wifiEnabled = (state === "enabled")
        
        // If WiFi is enabled, check connections
        if (module.wifiEnabled) {
          activeConnectionProcess.running = true
        } else {
          module.wifiConnected = false
          module.wifiSsid = ""
          module.wifiSignalStrength = 0
          module.connectionType = "none"
          module.interfaceName = ""
        }
        
        module.ready = true
        
        // Emit change if needed
        if (!module.changingState && !module.userInteracting && wasEnabled !== module.wifiEnabled) {
          module.networkChangedExternally(module.wifiEnabled, module.wifiConnected, module.wifiSsid)
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[Network] Error checking WiFi radio:", data.trim())
        }
      }
    }
  }
  
  // ============================================================================
  // ACTIVE CONNECTION CHECKER - with grep to filter loopback
  // ============================================================================
  
  Process {
    id: activeConnectionProcess
    // Filter loopback in the command itself, just like the bash script!
    command: ["sh", "-c", "nmcli -g DEVICE,TYPE connection show --active 2>/dev/null | grep -v '^lo:' | head -n1"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data || !data.trim()) {
          module.wifiConnected = false
          module.connectionType = "none"
          module.interfaceName = ""
          module.wifiSsid = ""
          module.wifiSignalStrength = 0
          return
        }
        
        // Format: DEVICE:TYPE (e.g., "wlan0:802-11-wireless")
        var parts = data.trim().split(':')
        if (parts.length >= 2) {
          var device = parts[0]
          var type = parts[1]
          
          if (type === "802-11-wireless" || type === "wifi") {
            module.connectionType = "wifi"
            module.interfaceName = device
            module.wifiConnected = true
            // Get WiFi details
            wifiDetailsProcess.running = true
          } else if (type === "802-3-ethernet" || type === "ethernet") {
            module.connectionType = "ethernet"
            module.interfaceName = device
            module.wifiConnected = false
            module.wifiSsid = ""
            module.wifiSignalStrength = 0
          } else {
            module.connectionType = "unknown"
            module.interfaceName = device
            module.wifiConnected = false
            module.wifiSsid = ""
            module.wifiSignalStrength = 0
          }
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[Network] Error checking connections:", data.trim())
        }
      }
    }
  }
  
  // ============================================================================
  // WIFI DETAILS READER (SSID and Signal)
  // ============================================================================
  
  Process {
    id: wifiDetailsProcess
    command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes'"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data || !data.trim()) {
          return
        }
        
        var line = data.trim()
        var parts = line.split(":")
        
        if (parts.length >= 2) {
          // Format: yes:SSID
          var oldSsid = module.wifiSsid
          module.wifiSsid = parts[1]
          
          // Get signal separately
          signalProcess.running = true
          
          // Emit change if SSID changed
          if (!module.changingState && !module.userInteracting && oldSsid !== module.wifiSsid && oldSsid !== "") {
            module.networkChangedExternally(module.wifiEnabled, module.wifiConnected, module.wifiSsid)
          }
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[Network] Error getting WiFi SSID:", data.trim())
        }
      }
    }
  }
  
  // ============================================================================
  // SIGNAL STRENGTH READER
  // ============================================================================
  
  Process {
  id: signalProcess
  command: ["sh", "-c", "nmcli -t -f ACTIVE,SIGNAL dev wifi 2>/dev/null | awk -F: '/^yes/{print $2}'"]
  
  stdout: SplitParser {
    onRead: data => {
      if (!data || !data.trim()) {
        return
      }
      
      var strength = parseInt(data.trim())
      if (!isNaN(strength) && strength >= 0 && strength <= 100) {
        module.wifiSignalStrength = strength
      }
    }
  }
  
  stderr: SplitParser {
    onRead: data => {
      if (data && data.trim()) {
        console.error("[Network.Signal] Error:", data.trim())
      }
    }
  }
}
  
  // ============================================================================
  // POLLING TIMER
  // ============================================================================

  Timer {
    id: pollingTimer
    interval: 10000  // 10 seconds - network state changes are infrequent
    running: true
    repeat: true
    onTriggered: {
      if (!wifiRadioProcess.running) {
        wifiRadioProcess.running = true
      }
    }
  }
  
  // ============================================================================
  // STATE CHANGE RESET TIMER
  // ============================================================================
  
  Timer {
    id: stateChangeResetTimer
    interval: 500
    onTriggered: {
      module.changingState = false
    }
  }
  
  // ============================================================================
  // CONTROL FUNCTIONS
  // ============================================================================
  
  function toggleWifi() {
    setWifi(!wifiEnabled)
  }
  
  function setWifi(enabled) {
    changingState = true
    stateChangeResetTimer.restart()
    
    // Update state optimistically
    wifiEnabled = enabled
    if (!enabled) {
      wifiConnected = false
      wifiSsid = ""
      wifiSignalStrength = 0
      connectionType = "none"
      interfaceName = ""
    }
    
    var cmd = enabled ? ["nmcli", "radio", "wifi", "on"] : ["nmcli", "radio", "wifi", "off"]
    
    Core.ProcessUtils.runCommand(
      module,
      cmd,
      () => {
        // Force state refresh after a short delay
        refreshTimer.start()
      },
      (code, error) => {
        console.error("[Network] Failed to set WiFi state:", error)
        // Still refresh state even on error
        refreshTimer.start()
      }
    )
  }
  
  // Refresh timer to avoid race conditions after toggle
  Timer {
    id: refreshTimer
    interval: 500
    onTriggered: {
      if (!wifiRadioProcess.running) {
        wifiRadioProcess.running = true
      }
    }
  }
  
  function openNetworkManager() {
    Core.ProcessUtils.runCommandAsync(module, ["kitty", "--class", "floating_term_m", "-e", "impala"])
  }

  // ============================================================================
  // UTILITY FUNCTIONS (Legacy - use cached properties instead)
  // ============================================================================

  function getNetworkIcon() {
    return module.networkIcon
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
    wifiRadioProcess.running = true
  }

  // ============================================================================
  // CLEANUP (Noctalia Pattern)
  // ============================================================================

  Component.onDestruction: {
    // Stop timers
    pollingTimer.stop()
    stateChangeResetTimer.stop()
    refreshTimer.stop()

    // Stop any running processes
    if (wifiRadioProcess.running) wifiRadioProcess.running = false
    if (activeConnectionProcess.running) activeConnectionProcess.running = false
    if (wifiDetailsProcess.running) wifiDetailsProcess.running = false
    if (signalProcess.running) signalProcess.running = false
  }
}
