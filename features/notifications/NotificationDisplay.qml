import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../shared/theme"
import "../../shared/components"

Scope {
  id: root
  
  required property var manager
  
  // Component for a single notification popup
  Component {
    id: notificationWindowComponent
    
    LazyLoader {
      id: loader
      
      // Properties for this specific notification
      required property int notifId
      required property string notifSummary
      required property string notifBody
      required property string notifApp
      required property int index  // Position in stack
      
      active: true
      
      PanelWindow {
        id: notifWindow
        
        // Calculate Y position based on stack index (compact stacking)
        property real stackOffset: {
          var baseOffset = Theme.component.barHeight + Theme.spacing.md
          var perNotifOffset = 160 // Compact spacing
          return baseOffset + (loader.index * perNotifOffset)
        }
        
        anchors {
          top: true
          right: true
        }
        
        margins {
          top: stackOffset
          right: Theme.spacing.md
        }
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        color: "transparent"
        mask: null
        
        Component.onCompleted: {
          exclusiveZone = 0
          implicitWidth = 340
          // Let height be determined by content binding below
        }
        
        // Dynamic height binding - this will update as content changes
        implicitHeight: wrapper.height
        
        // Smooth position transitions when notifications above are removed
        Behavior on stackOffset {
          NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
          }
        }
        
        // Wrapper item for fade animation
        Item {
          id: wrapper
          width: 340
          height: background.height  // Size to background
          opacity: 0
          
          // Fade in
          NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 200
            easing.type: Easing.OutCubic
          }
          
          // Main notification container - Material 3 minimalistic
          Rectangle {
            id: background
            width: parent.width
            height: notifContent.implicitHeight + (Theme.padding.lg * 2)
            radius: Theme.radius.lg
            
            // Use transparent_medium for blur effect consistency
            color: hovered 
                   ? Qt.darker(Theme.surface_container_transparent_medium, 1.1) 
                   : Theme.surface_container_transparent_medium
            
            border.width: 1
            border.color: Theme.surface_container_high
            
            property bool hovered: false
            
            Behavior on color {
              ColorAnimation { duration: 200 }
            }
            
            ColumnLayout {
              id: notifContent
              anchors {
                fill: parent
                margins: Theme.padding.lg
              }

              spacing: Theme.spacing.md
              
              // Header row - app icon + name + close
              RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.sm
                
                // App icon 
                IconCircle {
                  Layout.preferredWidth: 28
                  Layout.preferredHeight: 28
                  icon: "󰂚"
                  bgColor: Theme.primary_container
                  iconColor: Theme.primary
                  iconSize: Theme.typography.md
                }
                
                // App name
                Text {
                  Layout.fillWidth: true
                  text: loader.notifApp || "Notification"
                  color: Theme.on_surface
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamily
                  font.weight: Theme.typography.weightMedium
                  elide: Text.ElideRight
                  maximumLineCount: 1
                }
                
                // Close button
                Text {
                  text: "✕"
                  color: Theme.on_surface_variant
                  font.pixelSize: Theme.typography.md
                  font.family: Theme.typography.fontFamily
                  opacity: closeArea.containsMouse ? 1 : 0.7

                  Behavior on opacity { 
                    NumberAnimation { duration: 150 } 
                  }

                  MouseArea {
                    id: closeArea
                    anchors.centerIn: parent
                    width: 32
                    height: 32
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: fadeOut.start()
                  }
                }
              }
              
              // Content - summary + body
              ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.xs
                
                // Summary - bold and prominent
                Text {
                  Layout.fillWidth: true
                  text: loader.notifSummary
                  color: Theme.on_surface
                  font.pixelSize: Theme.typography.md
                  font.family: Theme.typography.fontFamily
                  font.weight: Theme.typography.weightMedium
                  wrapMode: Text.Wrap
                  maximumLineCount: 2
                  elide: Text.ElideRight
                }
                
                // Body - muted and compact
                Text {
                  Layout.fillWidth: true
                  text: loader.notifBody
                  color: Theme.on_surface_variant
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamily
                  wrapMode: Text.Wrap
                  maximumLineCount: 3
                  elide: Text.ElideRight
                  visible: text !== ""
                  opacity: 0.8
                }
              }
            }
            
            // Hover detection
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              propagateComposedEvents: true
              
              onEntered: background.hovered = true
              onExited: background.hovered = false
              
              onClicked: mouse => {
                mouse.accepted = false
              }
            }
          }
        }
        
        // Fade out animation
        NumberAnimation {
          id: fadeOut
          target: wrapper
          property: "opacity"
          to: 0
          duration: 150
          easing.type: Easing.InCubic
          
          onFinished: {
            loader.active = false
          }
        }
        
        // Auto-dismiss timer
        Timer {
          id: dismissTimer
          interval: 5000
          running: true
          onTriggered: {
            fadeOut.start()
          }
        }
      }
      
      // Clean up when dismissed
      onActiveChanged: {
        if (!active) {
          Qt.callLater(function() {
            root.manager.removeFromQueue(loader.notifId)
            loader.destroy()
          })
        }
      }
    }
  }
  
  // Instantiator to create windows for each notification in the queue
  Instantiator {
    model: root.manager.notificationQueue
    
    delegate: Item {
      required property var modelData
      required property int index
      
      Component.onCompleted: {
        var windowObj = notificationWindowComponent.createObject(root, {
          notifId: modelData.id,
          notifSummary: modelData.summary,
          notifBody: modelData.body,
          notifApp: modelData.appName,
          index: index
        })
      }
    }
  }
}
