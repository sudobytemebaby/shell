import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../../shared/theme"

Item {
  id: root

  // Reference to system state
  required property var systemState

  property string icon: "󰂲"
  property string status: "Off"
  property bool hovered: false

  // Width expands when hovered to show the status
  implicitWidth: hovered ? rowLayout.implicitWidth : iconText.implicitWidth
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

    Text {
      id: iconText
      text: icon
      color: Theme.on_surface
      font.pixelSize: Theme.typography.sm
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      id: statusText
      text: status
      color: Theme.on_surface_variant
      font.pixelSize: Theme.typography.sm
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      visible: hovered && status !== "N/A"
      opacity: hovered ? 1.0 : 0.0
      
      Behavior on opacity {
        NumberAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true

    onEntered: root.hovered = true
    onExited: root.hovered = false 

    cursorShape: Qt.PointingHandCursor

    onClicked: {
      root.systemState.bluetooth.openManager()
    }
  }

  // ============================================================================
  // BLUETOOTH STATE MONITORING (using SystemStateManager)
  // ============================================================================
  
  Connections {
    target: root.systemState.bluetooth
    enabled: root.systemState && root.systemState.bluetooth
    
    function onPoweredChanged() {
      updateBluetoothDisplay()
    }
    
    function onHasConnectedDeviceChanged() {
      updateBluetoothDisplay()
    }
    
    function onConnectedDeviceNameChanged() {
      updateBluetoothDisplay()
    }
    
    function onReadyChanged() {
      updateBluetoothDisplay()
    }
  }
  
  // Update bluetooth display
  function updateBluetoothDisplay() {
    var bt = root.systemState.bluetooth
    
    if (!bt || !bt.ready) {
      root.icon = "󰂲"
      root.status = "N/A"
      return
    }
    
    // Get icon based on power and connection state
    root.icon = bt.getBluetoothIcon(bt.powered, bt.hasConnectedDevice)
    
    // Get status text
    root.status = bt.getStatusText()
  }
  
  // Initial update
  Component.onCompleted: {
    updateBluetoothDisplay()
  }
}
