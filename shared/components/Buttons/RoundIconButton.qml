import QtQuick
import "../../theme"
import "../Animations"

// Unified Round Icon Button Component
// Consolidates: RoundIconButton + MediaButton
Rectangle {
  id: root

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  required property string icon
  signal clicked()

  // Optional customization
  property bool isPrimary: false  // Main action button (bigger, more prominent)
  property bool showShadow: false  // Show subtle shadow (good for media controls)
  property string variant: "default"  // "default" or "media"

  property int size: isPrimary ? 48 : 40

  // ============================================================================
  // APPEARANCE
  // ============================================================================

  width: size
  height: size
  radius: variant === "media" ? (isPrimary ? size / 2 : size / 2) : Config.radius.full

  color: {
    if (isPrimary) {
      if (variant === "media") {
        return mouseArea.containsMouse ? Theme.primary : Theme.primary_transparent_medium
      } else {
        return mouseArea.pressed ? Qt.darker(Theme.primary, 1.2) : Theme.primary
      }
    } else {
      if (variant === "media") {
        return mouseArea.containsMouse ? Theme.surface : "transparent"
      } else {
        return mouseArea.containsMouse ? Theme.surface_container_low : Theme.surface
      }
    }
  }

  scale: mouseArea.pressed ? (isPrimary && variant === "media" ? 0.92 : 0.88) : 1.0

  // ============================================================================
  // ANIMATIONS
  // ============================================================================

  AColor on color {}

  Behavior on border.color {
    ColorAnimation { duration: 150 }
  }

  AScale on scale {}

  // ============================================================================
  // ICON
  // ============================================================================

  Text {
    anchors.centerIn: parent
    text: root.icon
    color: {
      if (isPrimary) {
        return variant === "media" ? Theme.on_surface : Theme.on_primary
      } else {
        return Theme.on_surface
      }
    }
    font.pixelSize: isPrimary ? Config.typography.xxl : Config.typography.xl
    font.family: Config.typography.sans
  }

  // ============================================================================
  // INTERACTION
  // ============================================================================

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    anchors.margins: -4  // Bigger hit area
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
