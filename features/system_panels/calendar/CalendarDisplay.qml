import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components"
import "../../../shared/components/Modals"
import "../../../shared/components/Utils"
import "cal_modules" as CalModules

AnimatedLazyLoader {
  id: loader
  show: manager.visible

  required property var manager

  PanelWindow {
    id: calendarWindow

    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    visible: loader.active

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
      anchors.horizontalCenter: parent.horizontalCenter
      y: Config.calendar.posY
      width: Config.calendar.width
      height: Config.calendar.height

      scale: loader.contentScale
      opacity: loader.contentOpacity

      Rectangle {
        id: background
        anchors.fill: parent

        layer.enabled: true
        layer.smooth: true
        layer.effect: PaneShadow {}
        color: Config.paneBackground

        radius: Config.calendar.radius
        border.width: Config.paneBorderWidth
        border.color: Theme.surface_container

        // Prevent clicks on panel from closing it
        MouseArea {
          anchors.fill: parent
        }

        ColumnLayout {
          anchors {
            fill: parent
            margins: Config.padding.lg
          }
          spacing: Config.spacing.md

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
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            height: 1
            color: Theme.surface_container_high
            opacity: 0.7
          }

          // ========== CALENDAR NAVIGATION ==========
          CalModules.CalendarNavigation {
            Layout.fillWidth: true
            calendarManager: loader.manager
          }

          // Divider
          Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            height: 1
            color: Theme.surface_container_high
            opacity: 0.7
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
