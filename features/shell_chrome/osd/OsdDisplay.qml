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
      left: true
      right: true
      bottom: true
    }

    exclusiveZone: 0
    implicitHeight: osdBackground.height + 28
    
    color: "transparent"
    mask: null
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    Rectangle {
      id: osdBackground
      anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        bottomMargin: 28
      }
      width: contentLayout.implicitWidth + (Theme.padding.sm * 2)
      height: contentLayout.implicitHeight + (Theme.padding.sm * 2)
      color: Theme.surface_transparent_medium
      radius: Theme.radius.xl
      border.width: 0.5
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
          leftMargin: Theme.padding.sm
          rightMargin: Theme.padding.xs
          topMargin: Theme.padding.sm
          bottomMargin: Theme.padding.sm
        }
        
        RowLayout {
          id: contentLayout
          anchors.centerIn: parent
          spacing: Theme.spacing.sm
          
          Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 36
            Layout.preferredHeight: 32

            IconCircle {
              anchors.centerIn: parent
              icon: loader.manager.currentIcon
              iconSize: Theme.typography.lg
              iconColor: osdSlider.isMuted ? Theme.outline : Theme.primary
              bgColor: osdSlider.isMuted ? Theme.surface_container_highest : Theme.primary_container
              Behavior on bgColor{
                ColorAnimation{
                  duration: 200
                }
              }
            }
          }

          ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: Theme.spacing.xs

            Components.HorizontalOsdSlider {
              id: osdSlider
              Layout.preferredWidth: 160

              value: loader.manager.currentValue
              isMuted: loader.manager.currentMuted

              onSliderMoved: function(newValue) {
                loader.manager.updateCurrentValue(newValue)

                if (loader.manager.currentType === loader.manager.typeVolume) {
                  loader.manager.systemState.volume.setVolume(newValue)
                } else if (loader.manager.currentType === loader.manager.typeBrightness) {
                  loader.manager.systemState.brightness.setBrightness(newValue)
                }
              }

              onIsDraggingChanged: {
                loader.userInteracting = isDragging || osdHoverArea.containsMouse

                if (loader.manager.systemState) {
                  loader.manager.systemState.userInteracting = isDragging
                }
              }
            }

            TickMarks {
              Layout.preferredWidth: 160
              tickCount: 11
            }
          }

          Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 30
            text: Math.round(loader.manager.currentValue * 100)
            color: Theme.on_surface
            font.pixelSize: Theme.typography.md
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
            horizontalAlignment: Text.AlignHCenter
          }
        }
      }
    }
  }
}
