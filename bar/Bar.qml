import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme"
import "bar_modules" as Modules

PanelWindow {
  id: barWindow
  
  // Accept managers from shell.qml
  required property var controlCenterManager 
  required property var notificationCenterManager
  required property var calendarManager
  required property var systemState 
  
  anchors.top: true
  anchors.left: true
  anchors.right: true
  implicitHeight: Theme.barHeight
  color: Theme.surface_transparent_heavy

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    radius: 0
    
    RowLayout {
      anchors.fill: parent
      
      // Margins from right and left of the first modules
      anchors.leftMargin: Theme.spacingM
      anchors.rightMargin: Theme.spacingM

      // Left Section - Workspaces
      RowLayout {
        Layout.alignment: Qt.AlignLeft
        spacing: Theme.spacingL
        
        Modules.ControlCenterButton{
          controlCenterManager: barWindow.controlCenterManager
        }
        
        Modules.Workspaces {}

        Modules.Keyboard {}
      }

      // Center Spacer
      Item {
        Layout.fillWidth: true
      }

      // Right Section - System Info
      RowLayout {
        Layout.alignment: Qt.AlignRight
        spacing: Theme.spacingL

        Modules.Battery {
          systemState: barWindow.systemState
        }

        Modules.Bluetooth{
          systemState: barWindow.systemState
        }

        Modules.Audio {
          systemState: barWindow.systemState
        }

        Modules.Network {
          systemState: barWindow.systemState
        }
        
        Modules.NotificationCenterButton {
          notificationCenterManager: barWindow.notificationCenterManager
        }
        
        Modules.Clock {
          calendarManager: barWindow.calendarManager
        }
      }
    }
  }
}
