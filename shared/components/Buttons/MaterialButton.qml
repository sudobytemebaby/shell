import QtQuick
import "../../theme"
import "../Animations"

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
  
  radius: Config.radius.lg

  color: mouseArea.pressed ? Theme.surface_container_highest : Theme.surface_container_highest

  // ============================================================================
  // ANIMATIONS
  // ============================================================================

  AColor on color {}

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
    font.pixelSize: Config.typography.xl
    font.family: Config.typography.sans
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
