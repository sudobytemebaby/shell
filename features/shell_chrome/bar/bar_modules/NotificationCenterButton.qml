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
    spacing: Theme.spacingS
    
    // Bell icon
    Text {
      id: iconText
      text: notificationCount > 0 ? "󱥁" : "󰍩"  // Bell with/without badge
      color: mouseArea.containsMouse ? Qt.darker(Theme.fg, 1.3) : Theme.fg
      font.pixelSize: Theme.fontSizeS
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
      Layout.preferredWidth: countText.implicitWidth + Theme.spacingS
      Layout.preferredHeight: 12
      radius: 8
      color: Qt.darker(Theme.fg, 1.2)
      visible: notificationCount > 0
      
      Text {
        id: countText
        anchors.centerIn: parent
        text: notificationCount > 99 ? "99+" : notificationCount
        color: Theme.bg1
        font.pixelSize: Theme.fontSizeXS - 3
        font.family: Theme.fontFamily
        font.bold: true
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
