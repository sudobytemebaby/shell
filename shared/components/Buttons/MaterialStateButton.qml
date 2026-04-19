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

  property bool isActive: false

  // ============================================================================
  // APPEARANCE
  // ============================================================================

  implicitWidth: isActive ? Config._sc(66) : Config.sizes.buttonHeightXl
  implicitHeight: Config.sizes.buttonHeightXl
  
  width: implicitWidth
  height: implicitHeight
  
  radius: isActive ? Config.radius.full : Config.radius.lg

  color: isActive ? Theme.primary : Theme.surface_container_highest

  // ============================================================================
  // ANIMATIONS
  // ============================================================================

  AColor on color {}
  AExpand on implicitWidth {}
  AExpand on implicitHeight {}
  AExpand on radius {}

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
