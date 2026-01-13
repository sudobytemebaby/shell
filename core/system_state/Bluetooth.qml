import QtQuick
import Quickshell
import Quickshell.Io
import "../" as Core

// Bluetooth State Module - SIMPLIFIED VERSION
Scope {
  id: module
  
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  
  property bool userInteracting: false
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  property bool powered: false
  property bool hasConnectedDevice: false
  property string connectedDeviceName: ""
  property int connectedDeviceCount: 0
  property var connectedDevices: []
  property bool ready: false
  property bool changingState: false
  
  // ============================================================================
  // EXTERNAL CHANGE SIGNAL
  // ============================================================================
  
  signal bluetoothChangedExternally(bool powered, bool hasDevice, string deviceName)
  
  // ============================================================================
  // BLUETOOTH STATE READER 
  // ============================================================================
  
  Process {
    id: bluetoothStateProcess
    // Use simple grep + awk that definitely works
    command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -i powered | awk '{print $NF}'"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) {
          return
        }
        
        var line = data.trim().toLowerCase()
        
        var wasPowered = module.powered
        
        // Check if powered (handles both "yes" and "on")
        module.powered = (line === "yes" || line === "on")
        
        // If powered, check devices
        if (module.powered) {
          connectedDevicesProcess.running = true
        } else {
          module.hasConnectedDevice = false
          module.connectedDeviceCount = 0
          module.connectedDeviceName = ""
          module.connectedDevices = []
        }
        
        module.ready = true
        
        // Emit change if needed
        if (!module.changingState && !module.userInteracting && wasPowered !== module.powered) {
          module.bluetoothChangedExternally(module.powered, module.hasConnectedDevice, module.connectedDeviceName)
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
  
  // Check connected devices
  Process {
    id: connectedDevicesProcess
    command: ["bluetoothctl", "devices", "Connected"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data || !data.trim()) {
          module.hasConnectedDevice = false
          module.connectedDeviceCount = 0
          module.connectedDeviceName = ""
          module.connectedDevices = []
          return
        }
        
        var lines = data.trim().split('\n').filter(line => line.includes('Device'))
        
        module.connectedDeviceCount = lines.length
        module.hasConnectedDevice = lines.length > 0
        
        if (lines.length > 0) {
          // Parse: "Device AA:BB:CC:DD:EE:FF Name Here"
          var firstLine = lines[0]
          var parts = firstLine.split(' ')
          if (parts.length >= 3) {
            module.connectedDeviceName = parts.slice(2).join(' ')
          }
          
          // Build array
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
          module.connectedDevices = devices
        } else {
          module.connectedDeviceName = ""
          module.connectedDevices = []
        }
      }
    }
  }
  
  // Poll every 2 seconds
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
      if (!bluetoothStateProcess.running) {
        bluetoothStateProcess.running = true
      }
    }
  }
  
  // Reset changing flag
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
  
  function togglePower() {
    setPower(!powered)
  }
  
  function setPower(enabled) {
    changingState = true
    stateChangeResetTimer.restart()
    
    Core.ProcessUtils.runCommand(
      module,
      ["bluetoothctl", "power", enabled ? "on" : "off"],
      () => {
        // Refresh state after change
        Qt.callLater(function() {
          if (!bluetoothStateProcess.running) {
            bluetoothStateProcess.running = true
          }
        })
      },
      (code, error) => {
        console.error("[Bluetooth] Failed to set power:", error)
        // Still refresh state
        Qt.callLater(function() {
          if (!bluetoothStateProcess.running) {
            bluetoothStateProcess.running = true
          }
        })
      }
    )
  }
  
  function connectDevice(address) {
    if (!address) return
    
    changingState = true
    stateChangeResetTimer.restart()
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["bluetoothctl", "connect", "' + address + '"] }',
      module
    )
    
    proc.exited.connect(function(code) {
      proc.destroy()
      Qt.callLater(function() {
        if (!bluetoothStateProcess.running) {
          bluetoothStateProcess.running = true
        }
      })
    })
    
    proc.running = true
  }
  
  function disconnectDevice(address) {
    if (!address) return
    
    changingState = true
    stateChangeResetTimer.restart()
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["bluetoothctl", "disconnect", "' + address + '"] }',
      module
    )
    
    proc.exited.connect(function(code) {
      proc.destroy()
      Qt.callLater(function() {
        if (!bluetoothStateProcess.running) {
          bluetoothStateProcess.running = true
        }
      })
    })
    
    proc.running = true
  }
  
  function openManager() {
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["kitty", "--class", "floating_term_s", "-e", "bluetui"] }',
      module
    )
    proc.startDetached()
    proc.destroy()
  }
  
  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================
  
  function getBluetoothIcon(powered, hasDevice) {
    if (!powered) return "󰂲"
    if (hasDevice) return "󰂯"
    return "󰂯"
  }
  
  function getStatusText() {
    if (!powered) return "Off"
    if (!hasConnectedDevice) return "On"
    if (connectedDeviceCount === 1) return connectedDeviceName
    return connectedDeviceCount + " devices"
  }
  
  function getDetailedStatus() {
    if (!powered) return "Bluetooth is off"
    if (!hasConnectedDevice) return "No devices connected"
    if (connectedDeviceCount === 1) return "Connected to " + connectedDeviceName
    return connectedDeviceCount + " devices connected"
  }
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    bluetoothStateProcess.running = true
  }
}
