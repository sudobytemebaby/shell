import QtQuick
import "../../../../shared/components"

IconButton {
  required property var systemState
  
  // Add property change debugging
  Component.onCompleted: {
    console.log("[WiFiToggle] Initial state - wifiEnabled:", systemState.network.wifiEnabled, 
                "wifiConnected:", systemState.network.wifiConnected,
                "SSID:", systemState.network.wifiSsid)
  }
  
  // Watch for changes
  Connections {
    target: systemState.network
    
    function onWifiEnabledChanged() {
      console.log("[WiFiToggle] wifiEnabled changed to:", systemState.network.wifiEnabled)
    }
    
    function onWifiConnectedChanged() {
      console.log("[WiFiToggle] wifiConnected changed to:", systemState.network.wifiConnected)
    }
    
    function onWifiSsidChanged() {
      console.log("[WiFiToggle] SSID changed to:", systemState.network.wifiSsid)
    }
  }
  
  icon: systemState.network.getNetworkIcon()
  title: "WI-FI"
  subtitle: systemState.network.getStatusText()
  
  isStateful: true
  isActive: systemState.network.wifiEnabled && systemState.network.wifiConnected
  
  onClicked: systemState.network.toggleWifi()
}
