import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../../shared/theme"

Item {
  id: root

  // Reference to system state
  required property var systemState

  property string ifname: "—"
  property string icon: "󰖪"
  property bool hovered: false

  // Width expands when hovered to show the text
  implicitWidth: hovered ? rowLayout.implicitWidth : label.implicitWidth
  implicitHeight: Theme.barHeight
  
  // Smooth width transition
  Behavior on implicitWidth {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }

  RowLayout {
    id: rowLayout
    anchors.centerIn: parent
    spacing: Theme.spacing.sm

    // Icon (always visible)
    Text {
      id: label
      text: icon
      color: Theme.on_surface
      font.pixelSize: Theme.typography.sm
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
    }

    // Interface name (only visible on hover)
    Text {
      id: ifnameText
      text: ifname
      color: Theme.on_surface_variant
      font.pixelSize: Theme.typography.sm
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      visible: hovered && ifname !== "—"
      opacity: hovered ? 1.0 : 0.0
      
      Behavior on opacity {
        NumberAnimation {
          duration: 250 
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  // MouseArea to detect hover
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    
    onEntered: root.hovered = true
    onExited: root.hovered = false

    cursorShape: Qt.PointingHandCursor

    onClicked: {
      root.systemState.network.openNetworkManager()
    }
  }

  // ============================================================================
  // NETWORK STATE MONITORING (using SystemStateManager)
  // ============================================================================
  
  Component.onCompleted: {
    updateNetworkDisplay()
  }
  
  Connections {
    target: root.systemState.network
    enabled: root.systemState && root.systemState.network
    
    function onWifiSignalStrengthChanged() {
      updateNetworkDisplay()
    }
    
    function onInterfaceNameChanged() {
      updateNetworkDisplay()
    }
    
    function onWifiEnabledChanged() {
      updateNetworkDisplay()
    }
    
    function onWifiConnectedChanged() {
      updateNetworkDisplay()
    }
    
    function onConnectionTypeChanged() {
      updateNetworkDisplay()
    }
    
    function onWifiSsidChanged() {
      updateNetworkDisplay()
    }
    
    function onReadyChanged() {
      updateNetworkDisplay()
    }
  }
  
  // Update network display
  function updateNetworkDisplay() {
    var network = root.systemState.network
    
    if (!network || !network.ready) {
      root.icon = "󰖪"
      root.ifname = "—"
      return
    }
    
    // Get icon from network module
    root.icon = network.networkIcon
    
    // Get interface name or status
    if (network.connectionType === "wifi" && network.wifiConnected) {
      root.ifname = network.wifiSsid || network.interfaceName
    } else if (network.connectionType === "ethernet") {
      root.ifname = "Ethernet"
    } else if (!network.wifiEnabled) {
      root.ifname = "Disabled"
    } else {
      root.ifname = "Disconnected"
    }
  }
}
