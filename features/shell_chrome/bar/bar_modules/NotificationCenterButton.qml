import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"

Item {
  id: root
  
  // Reference to the notification center manager
  required property var notificationCenterManager
  
  // Badge count for unread notifications
  property int notificationCount: notificationCenterManager.notifications.length
  
  property bool hovered: false
  
  implicitWidth: rowLayout.implicitWidth
  implicitHeight: Theme.barHeight
  
  // Smooth width transition
  Behavior on implicitWidth {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }
  
  RowLayout {
    id: rowLayout
    anchors.centerIn: parent
    spacing: Theme.spacing.sm

    // Bell icon
    Text {
      id: iconText
      text: notificationCount > 0 ? "󱥁" : "󰍩"  // Bell with/without badge
      color: mouseArea.containsMouse ? Qt.darker(Theme.on_surface, 1.3) : Theme.on_surface
      font.pixelSize: Theme.typography.sm
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      
      Behavior on color {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
    }
    
    // Notification count badge
    Rectangle {
      Layout.preferredWidth: 12
      Layout.preferredHeight: 12
      radius: Theme.radius.full
      color: Theme.on_surface_variant
      visible: notificationCount > 0

      Text {
        id: countText
        anchors.centerIn: parent
        text: notificationCount > 99 ? "99+" : notificationCount
        color: Theme.surface_container
        font.pixelSize: 8
        font.family: Theme.fontFamily
        font.weight: Theme.typography.weightBold
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onEntered: root.hovered = true
    onExited: root.hovered = false
    
    onClicked: {
      notificationCenterManager.visible = !notificationCenterManager.visible
    }
  }
}
