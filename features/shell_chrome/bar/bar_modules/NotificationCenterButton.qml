import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"
import "../../../../shared/components/Animations"

Item {
  id: root
  
  // Reference to the notification center manager
  required property var notificationCenterManager
  
  // Badge count for unread notifications
  property int notificationCount: notificationCenterManager.notifications.length
  
  property bool hovered: false
  
  implicitWidth: rowLayout.implicitWidth
  implicitHeight: Config.bar.height
  
  // Smooth width transition
  AExpand on implicitWidth {}
  
  RowLayout {
    id: rowLayout
    anchors.centerIn: parent
    spacing: Config.spacing.sm

    // Bell icon
    Text {
      id: iconText
      text: notificationCount > 0 ? "󱅫" : "󰂚"
      color: mouseArea.containsMouse ? Theme.outline : Theme.on_surface
      font.pixelSize: Config.typography.sm
      font.family: Config.typography.sans
      verticalAlignment: Text.AlignVCenter
      
      AColor on color {}
    }
    
    // Notification count badge
    Rectangle {
      Layout.preferredWidth: 12
      Layout.preferredHeight: 12
      radius: Config.radius.full
      color: Theme.on_surface_variant
      visible: notificationCount > 0

      Text {
        id: countText
        anchors.centerIn: parent
        text: notificationCount > 99 ? "99+" : notificationCount
        color: Theme.surface_container
        font.pixelSize: 8
        font.family: Config.typography.sans
        font.weight: Config.typography.weightBold
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
