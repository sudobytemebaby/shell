import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../shared/theme"
import "../../shared/components"
import "../../shared/components/Modals"

Scope {
  id: root
  
  required property var manager
  
  // Track active popup windows
  property var windows: []

  // --------------------------------------------------------------------------
  // Queue Management
  // --------------------------------------------------------------------------
  Connections {
    target: manager.notificationQueue
    
    function onRowsInserted(parent, start, end) {
      for (var i = start; i <= end; i++) {
        var modelData = manager.notificationQueue.get(i)
        var windowObj = notificationWindowComponent.createObject(root, {
          notifId: modelData.id,
          notifSummary: modelData.summary,
          notifBody: modelData.body,
          notifApp: modelData.appName
        })
        windows.splice(i, 0, windowObj)
      }
      updateIndexes()
    }

    function onRowsRemoved(parent, start, end) {
      var removed = windows.splice(start, end - start + 1)
      for (var i = 0; i < removed.length; i++) {
        if (removed[i]) {
          removed[i].destroy()
        }
      }
      updateIndexes()
    }
  }

  // Update visual stacking order
  function updateIndexes() {
    for (var i = 0; i < windows.length; i++) {
      if (windows[i]) {
        windows[i].notificationIndex = i
      }
    }
  }
  
  // --------------------------------------------------------------------------
  // Popup Window Component
  // --------------------------------------------------------------------------
  Component {
    id: notificationWindowComponent
    
    LazyLoader {
      id: loader
      
      // Properties for this specific notification
      required property int notifId
      required property string notifSummary
      required property string notifBody
      required property string notifApp
      
      // Position in stack, managed by updateIndexes()
      property int notificationIndex: -1
      
      active: true
      
      PanelWindow {
        id: notifWindow
        
        // ----------------------------------------------------------------------
        // Window Configuration
        // ----------------------------------------------------------------------
        
        // Calculate Y position based on stack index (compact stacking)
        property real stackOffset: {
          var baseOffset = Theme.component.barHeight + Theme.spacing.md
          var perNotifOffset = 130 // Compact spacing
          return baseOffset + (loader.notificationIndex * perNotifOffset)
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
        }
        
        // Dynamic height binding - this will update as content changes
        implicitHeight: wrapper.height
        
        // Smooth position transitions when notifications above are removed
        Behavior on stackOffset {
          NumberAnimation {
            duration: 200 
            easing.type: Easing.OutCubic
          }
        }
        
        // ----------------------------------------------------------------------
        // Content Wrapper (for Animations)
        // ----------------------------------------------------------------------
        Item {
          id: wrapper
          width: 340
          height: background.height
          opacity: 0
          
          // Fade in
          NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 350
            easing.type: Easing.OutCubic
          }
          
          // --------------------------------------------------------------------
          // Notification Card
          // --------------------------------------------------------------------
          Rectangle {
            id: background
            width: parent.width
            height: notifContent.implicitHeight + (Theme.padding.lg * 2)
            radius: Theme.radius.lg
            
            // Use transparent_medium for blur effect consistency
            color: Theme.surface_transparent_medium
            
            border.width: 0.5
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
                CloseButton {
                  style: "rounded"
                  onClicked: fadeOut.start()
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
          }
        }
        
        // ----------------------------------------------------------------------
        // Animations & Logic
        // ----------------------------------------------------------------------
        
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
            // Just remove from model. The Connections handler will destroy it.
            root.manager.removeFromQueue(loader.notifId)
          })
        }
      }
    }
  }
}
