import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.visible
  
  PanelWindow {
    id: powerMenuWindow
    
    // Fill screen - power menu will be centered
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    color: "transparent"
    mask: null
    
    Component.onCompleted: {
      console.log("[PowerMenu] Window loaded")
      exclusiveZone = 0
    }
    
    // Selection state
    property int selectedIndex: 0
    
    // Handle keyboard navigation
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
          if (powerMenuWindow.selectedIndex > 0) {
            powerMenuWindow.selectedIndex--
          } else {
            powerMenuWindow.selectedIndex = loader.manager.powerOptions.length - 1
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
          if (powerMenuWindow.selectedIndex < loader.manager.powerOptions.length - 1) {
            powerMenuWindow.selectedIndex++
          } else {
            powerMenuWindow.selectedIndex = 0
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          var selected = loader.manager.powerOptions[powerMenuWindow.selectedIndex]
          loader.manager.executePowerOption(selected)
          event.accepted = true
        }
      }
    }
    
    // Click outside to close
    MouseArea {
      anchors.fill: parent
      onClicked: {
        loader.manager.visible = false
      }
    }
    
    // Power menu container - centered
    Rectangle {
      id: container
      x: (parent.width - 700) / 2
      y: (parent.height - 450) / 2
      width: 700
      height: 450
      radius: Theme.radiusXLarge
      color: Theme.bg1transparentLauncher
      
      // Prevent clicks on container from closing
      MouseArea {
        anchors.fill: parent
      }
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.spacingL
        }
        spacing: Theme.spacingL
        
        // Header
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.spacingS
          
          Text {
            Layout.fillWidth: true
            text: "Power Options"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeXL
            font.family: Theme.fontFamily
            font.bold: true
          }
          
          // Close button
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radiusLarge
            color: closeMouseArea.containsMouse ? Theme.bg2 : "transparent"
            
            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.fg
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
            }
            
            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              
              onClicked: {
                loader.manager.visible = false
              }
            }
          }
        }
        
        // Power options grid - 2x3
        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 3
          rowSpacing: Theme.spacingM
          columnSpacing: Theme.spacingM
          
          Repeater {
            model: loader.manager.powerOptions
            
            delegate: Rectangle {
              required property var modelData
              required property int index
              
              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.preferredHeight: 140
              
              radius: Theme.radiusXLarge
              color: {
                if (index === powerMenuWindow.selectedIndex) return modelData.color
                if (optionMouseArea.containsMouse) return Theme.bg2
                return Theme.bg2transparent
              }
              
              Behavior on color {
                ColorAnimation {
                  duration: 200
                  easing.type: Easing.OutCubic
                }
              }
              
              ColumnLayout {
                anchors {
                  fill: parent
                  margins: Theme.spacingM
                }
                spacing: Theme.spacingM
                
                Item { Layout.fillHeight: true }
                
                // Icon
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.icon
                  color: index === powerMenuWindow.selectedIndex ? Theme.bg1 : Theme.fg
                  font.pixelSize: 48
                  font.family: Theme.fontFamily
                  
                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }
                
                // Name
                Text {
                  Layout.fillWidth: true
                  text: modelData.name
                  color: index === powerMenuWindow.selectedIndex ? Theme.bg1 : Theme.fg
                  font.pixelSize: Theme.fontSizeL
                  font.family: Theme.fontFamily
                  font.bold: true
                  horizontalAlignment: Text.AlignHCenter
                  
                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }
                
                // Description
                Text {
                  Layout.fillWidth: true
                  text: modelData.description
                  color: index === powerMenuWindow.selectedIndex ? Theme.bg2 : Theme.fgMuted
                  font.pixelSize: Theme.fontSizeS
                  font.family: Theme.fontFamily
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  
                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }
                
                Item { Layout.fillHeight: true }
              }
              
              MouseArea {
                id: optionMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                  powerMenuWindow.selectedIndex = index
                  loader.manager.executePowerOption(modelData)
                }
                
                onEntered: {
                  powerMenuWindow.selectedIndex = index
                }
              }
            }
          }
        }
        
        // Footer hint
        Text {
          Layout.fillWidth: true
          text: "Arrow keys Navigate • Enter Execute • Esc Cancel"
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeS
          font.family: Theme.fontFamily
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }
}
