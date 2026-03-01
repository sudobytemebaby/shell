import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../../shared/theme"

Item {
  id: root
  
  // Reference to system state
  required property var systemState

  property string icon: ""
  property string percentage: "N/A"
  property color iconColor: Theme.on_surface
  property bool hovered: false

  // Width expands when hovered to show the percentage
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
    spacing: Theme.spacing.xs // Tighter spacing for MD3 feel

    // Icon (always visible)
    Text {
      id: iconText
      text: icon
      color: root.iconColor
      font.pixelSize: Theme.typography.sm
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      
      // Add subtle spacing between charging symbol and battery if both are present
      // This is handled automatically by the font but we can fine-tune if needed.
    }

    // Percentage (only visible on hover)
    Text {
      id: percentageText
      text: percentage
      color: Theme.on_surface_variant
      font.pixelSize: Theme.typography.sm
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      visible: hovered && percentage !== "N/A"
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
    cursorShape: Qt.PointingHandCursor
    
    onEntered: root.hovered = true
    onExited: root.hovered = false

    onClicked: {
      Quickshell.execDetached({
        command: ["sh", "-c", "~/.local/bin/tui-battery"]
      })
    }
  }
  
  // ============================================================================
  // BATTERY STATE MONITORING (using SystemStateManager)
  // ============================================================================
  
  Connections {
    target: root.systemState.battery
    enabled: root.systemState && root.systemState.battery
    
    function onPercentageChanged() {
      updateBatteryDisplay()
    }
    
    function onIsChargingChanged() {
      updateBatteryDisplay()
    }
    
    function onReadyChanged() {
      updateBatteryDisplay()
    }
  }
  
  // Update battery display
  function updateBatteryDisplay() {
    var battery = root.systemState.battery
    
    if (!battery || !battery.ready || !battery.isLaptopBattery) {
      root.icon = ""  // Default horizontal battery icon
      root.percentage = "N/A"
      return
    }
    
    // Get icon based on percentage and charging state
    root.icon = battery.getBatteryIcon(battery.percentage, battery.isCharging)
    
    // Format percentage
    root.percentage = Math.round(battery.percentage * 100) + "%"
    
    // Update color (red if low and not charging)
    root.iconColor = (battery.percentage <= 0.1 && !battery.isCharging) ? Theme.error : Theme.on_surface
  }
  
  // Initial update
  Component.onCompleted: {
    updateBatteryDisplay()
  }
}
