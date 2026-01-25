import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components"
import "osd_components" as Components

LazyLoader {
  id: loader
  
  required property var manager
  
  // Track if user is interacting with OSD
  property bool userInteracting: false
  
  // Don't deactivate while user is interacting!
  active: manager.currentType !== manager.typeNone || userInteracting
  
  PanelWindow {
    id: osdWindow
    
    anchors {
      right: true
      top: true
    }
    
    margins {
      right: Theme.spacing.xl
      top: 300
    }
    
    exclusiveZone: 0
    implicitWidth: 60
    implicitHeight: 220
    
    color: "transparent"
    mask: null
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    Rectangle {
      anchors.fill: parent
      color: Theme.surface_container_transparent_heavy
      radius: Theme.radius.xl
      border.width: 1
      border.color: Theme.surface_container_high
      
      // Hover detection for the whole OSD
      MouseArea {
        id: osdHoverArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        
        // Update interaction state
        onContainsMouseChanged: {
          loader.userInteracting = containsMouse || osdSlider.isDragging
        }
        
        // Let clicks pass through to children
        onPressed: function(mouse) { mouse.accepted = false }
        onReleased: function(mouse) { mouse.accepted = false }
      }
      
      Item {
        anchors {
          fill: parent
          margins: Theme.padding.sm
        }
        
        ColumnLayout {
          anchors.centerIn: parent
          spacing: Theme.spacing.md
          
          IconCircle {
            Layout.alignment: Qt.AlignHCenter
            icon: loader.manager.currentIcon
            iconSize: Theme.typography.lg
            iconColor: Theme.primary
            bgColor: osdSlider.isMuted ? Theme.surface_container_highest : Theme.primary_container
            Behavior on bgColor{
              ColorAnimation{
                duration: 200
              }
            }
          }
          

          Components.VerticalOsdSlider {
            id: osdSlider
            Layout.alignment: Qt.AlignHCenter
            
            value: loader.manager.currentValue
            isMuted: loader.manager.currentMuted
            
            onSliderMoved: function(newValue) {
              // Update the manager's current value for display
              loader.manager.updateCurrentValue(newValue)
              
              // Apply the change to the appropriate module
              if (loader.manager.currentType === loader.manager.typeVolume) {
                loader.manager.systemState.volume.setVolume(newValue)
              } else if (loader.manager.currentType === loader.manager.typeBrightness) {
                loader.manager.systemState.brightness.setBrightness(newValue)
              }
            }
            
            onIsDraggingChanged: {
              // Update loader's interaction state
              loader.userInteracting = isDragging || osdHoverArea.containsMouse
              
              // Also update system state
              if (loader.manager.systemState) {
                loader.manager.systemState.userInteracting = isDragging
              }
            }
          }
          
          Text {
            Layout.alignment: Qt.AlignHCenter
            text: Math.round(loader.manager.currentValue * 100)
            color: Theme.on_surface
            font.pixelSize: Theme.typography.md
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
        }
      }
    }
  }
}
