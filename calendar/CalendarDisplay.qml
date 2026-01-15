import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "../components"
import "cal_modules" as CalModules

AnimatedLazyLoader {
  id: loader

  required property var manager

  // Bind to manager visibility
  show: manager.visible

  // Animation config - snappy like control center
  openDuration: 280
  closeDuration: 150
  openEasingType: Easing.OutBack
  closeEasingType: Easing.OutCubic
  openOvershoot: 0.8

  PanelWindow {
    id: calendarWindow

    anchors {
      top: true
      right: true
    }

    margins {
      top: Theme.spacing.md + (Theme.component.barHeight * loader.animationProgress)
      right: Theme.spacing.md
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: loader.manager.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0
      implicitWidth = 360
      implicitHeight = 520
    }

    contentItem {
      focus: true

      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        loader.manager.visible = false
      }
    }

    // Main container with Material 3 style
    Rectangle {
      id: background
      anchors.fill: parent
      radius: Theme.radius.xl
      color: Theme.surface_container_transparent_medium
      border.width: 1
      border.color: Qt.lighter(Theme.surface_container, 1.3)

      // Open: scale pop, Close: fade out
      scale: loader.isClosing ? 1 : (0.85 + (0.15 * loader.animationProgress))
      opacity: loader.isClosing ? loader.animationProgress : 1
      transformOrigin: Item.Top
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.padding.lg
        }
        spacing: Theme.spacing.md
        
        // ========== HEADER ==========
        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          spacing: Theme.spacing.sm
          
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding.xs
            text: "Calendar"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
          
          // Close button
          Text {
            Layout.rightMargin: Theme.padding.sm
            text: "✕"
            color: Theme.fg
            font.pixelSize: Theme.typography.lg
            font.family: Theme.fontFamily
            opacity: closeMouseArea.containsMouse ? 0.7 : 1

            Behavior on opacity {
              NumberAnimation { duration: 200 }
            }

            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: loader.manager.visible = false
            }
          }
        }
        
        // ========== CURRENT TIME & DATE ==========
        CalModules.TimeDisplay {
          Layout.fillWidth: true
          Layout.preferredHeight: 120
          calendarManager: loader.manager
        }
        
        // ========== CALENDAR NAVIGATION ==========
        CalModules.CalendarNavigation {
          Layout.fillWidth: true
          calendarManager: loader.manager
        }
        
        // ========== CALENDAR GRID ==========
        CalModules.CalendarGrid {
          Layout.fillWidth: true
          Layout.fillHeight: true
          calendarManager: loader.manager
        }
        
        // ========== TODAY BUTTON ==========
        CalModules.TodayButton {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          calendarManager: loader.manager
        }
      }
    }
  }
}
