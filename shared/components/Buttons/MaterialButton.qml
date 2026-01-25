import QtQuick
import "../../theme"

Rectangle {
  id: root

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  required property string icon
  signal clicked()

  // ============================================================================
  // APPEARANCE
  // ============================================================================

  implicitWidth: 56
  implicitHeight: 56
  
  width: implicitWidth
  height: implicitHeight
  
  radius: Theme.radius.lg

  color: mouseArea.pressed ? Theme.surface_container_highest : Theme.surface_container_high

  // ============================================================================
  // ANIMATIONS
  // ============================================================================

  Behavior on color { ColorAnimation { duration: 200 } }

  ParallelAnimation {
    id: pressAnimation
    NumberAnimation { target: root; property: "scale"; to: 0.92; duration: 100; easing.type: Easing.OutCubic }
    NumberAnimation { target: iconText; property: "scale"; to: 0.85; duration: 100; easing.type: Easing.OutCubic }
  }

  // ============================================================================
  // ICON
  // ============================================================================

  Text {
    id: iconText
    anchors.centerIn: parent
    text: root.icon
    color: Theme.on_surface
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