import QtQuick
import "../../theme"

Rectangle {
  id: root

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  required property string icon
  signal clicked()

  property bool isActive: false

  // ============================================================================
  // APPEARANCE
  // ============================================================================

  implicitWidth: isActive ? 66 : 56
  implicitHeight: 56
  
  width: implicitWidth
  height: implicitHeight
  
  radius: isActive ? Theme.radius.full : Theme.radius.lg

  color: isActive ? Theme.primary : Theme.surface_container_high

  // ============================================================================
  // ANIMATIONS
  // ============================================================================

  Behavior on color { ColorAnimation { duration: 200 } }
  Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

  ParallelAnimation {
    id: pressAnimation
    NumberAnimation { target: root; property: "scale"; to: 1.0; duration: 200; easing.type: Easing.OutElastic }
    NumberAnimation { target: iconText; property: "scale"; to: 1.0; duration: 200; easing.type: Easing.OutElastic }
  }

  // ============================================================================
  // ICON
  // ============================================================================

  Text {
    id: iconText
    anchors.centerIn: parent
    text: root.icon
    color: isActive ? Theme.on_primary : Theme.on_primary_container
    font.pixelSize: Theme.typography.xl
    font.family: Theme.typography.fontFamily
  }

  // ============================================================================
  // INTERACTION
  // ============================================================================

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onPressed: (mouse) => {
      pressAnimation.start()
    }
    onClicked: root.clicked()
  }
}
