import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components/Modals"
import "cal_modules" as CalModules

LazyLoader {
  id: loader
  active: manager.visible

  required property var manager

  PanelWindow {
    id: calendarWindow

    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    visible: loader.manager.visible

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: loader.manager.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0
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
      onClicked: loader.manager.visible = false
    }

    Item {
      id: container
      x: parent.width - width - 28
      y: 28
      width: 360
      height: 520

      // Main container with Material 3 style
      Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.radius.xl
        color: Theme.surface_container_transparent_medium
        border.width: 0.5
        border.color: Theme.surface_container_high

        // Prevent clicks on panel from closing it
        MouseArea {
          anchors.fill: parent
        }

        ColumnLayout {
          anchors {
            fill: parent
            margins: Theme.padding.lg
          }
          spacing: Theme.spacing.md

          // ========== HEADER ==========
          ModalHeader {
            title: "Calendar"
            onCloseClicked: loader.manager.visible = false
          }

          // ========== CURRENT TIME & DATE ==========
          CalModules.TimeDisplay {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            calendarManager: loader.manager
          }

          // Divider
          Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            height: 1
            color: Theme.surface_container_high
            opacity: 0.7
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
}
