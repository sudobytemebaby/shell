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
          var baseOffset = Config.bar.height + Config.spacing.md
          var perNotifOffset = 140
          return baseOffset + (loader.notificationIndex * perNotifOffset)
        }
        
        anchors {
          top: true
          right: true
        }

        margins {
          top: stackOffset - shadowPad
          right: Config.spacing.md - shadowPad
        }
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        color: "transparent"
        mask: null
        
        Component.onCompleted: {
          exclusiveZone = 0
        }

        // Extra padding around card for shadow to render into
        property int shadowPad: 20

        implicitWidth: 340 + (shadowPad * 2)
        implicitHeight: wrapper.height + (shadowPad * 2)

        // ----------------------------------------------------------------------
        // Content Wrapper (for Animations)
        // ----------------------------------------------------------------------
        Item {
          id: wrapper
          x: notifWindow.shadowPad
          y: notifWindow.shadowPad
          width: 340
          height: background.height
          opacity: 0

          layer.enabled: true
          layer.smooth: true
          layer.effect: PaneShadow {}

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
            height: notifContent.implicitHeight + (Config.padding.lg * 2)
            radius: Config.radius.lg

            // Use transparent_medium for blur effect consistency
            color: Config.paneBackground

            border.width: Config.paneBorderWidth
            border.color: Theme.surface_container

            property bool hovered: false

            AColor on color {}
            
            ColumnLayout {
              id: notifContent
              anchors {
                fill: parent
                margins: Config.padding.lg
              }

              spacing: Config.spacing.md
              
              // Header row - app icon + name + close
              RowLayout {
                Layout.fillWidth: true
                spacing: Config.spacing.sm
                
                // App icon 
                IconCircle {
                  Layout.preferredWidth: 28
                  Layout.preferredHeight: 28
                  icon: "󰂚"
                  bgColor: Theme.primary_container
                  iconColor: Theme.primary
                  iconSize: Config.typography.md
                }
                
                // App name
                Text {
                  Layout.fillWidth: true
                  text: loader.notifApp || "Notification"
                  color: Theme.on_surface
                  font.pixelSize: Config.typography.sm
                  font.family: Config.typography.sans
                  font.weight: Config.typography.weightMedium
                  elide: Text.ElideRight
                  maximumLineCount: 1
                }
                
                // Close button
                Text {
                  text: "✕"
                  font.pixelSize: Config.typography.sm
                  font.family: Config.typography.sans
                  color: mouseArea.containsMouse ? Theme.outline : Theme.on_surface_variant

                  MouseArea {
                    id: mouseArea
                    width: 24
                    height: 24
                    anchors.centerIn: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: fadeOut.start()
                  }
                }
              }
              
              // Content - summary + body
              ColumnLayout {
                Layout.fillWidth: true
                spacing: Config.spacing.xs
                
                // Summary - bold and prominent
                Text {
                  Layout.fillWidth: true
                  text: loader.notifSummary
                  color: Theme.on_surface
                  font.pixelSize: Config.typography.md
                  font.family: Config.typography.sans
                  font.weight: Config.typography.weightMedium
                  wrapMode: Text.Wrap
                  maximumLineCount: 2
                  elide: Text.ElideRight
                }
                
                // Body - muted and compact
                Text {
                  Layout.fillWidth: true
                  text: loader.notifBody
                  color: Theme.on_surface_variant
                  font.pixelSize: Config.typography.sm
                  font.family: Config.typography.sans
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
