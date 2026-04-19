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

  property int size: isPrimary ? Config.sizes.buttonHeightLg : Config.sizes.buttonHeight

  // ============================================================================
  // APPEARANCE
  // ============================================================================

  width: size
  height: size
  radius: Config.radius.full

  color: {
    if (isPrimary) {
      if (variant === "media") {
        return mouseArea.containsMouse ? Theme.primary : Theme.primary_container
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
    // Integer-aligned centering for crisp rendering
    x: Math.round((parent.width - implicitWidth) / 2)
    y: Math.round((parent.height - implicitHeight) / 2)
    text: root.icon
    color: {
      if (isPrimary) {
        return variant === "media" ? Theme.on_surface : Theme.on_primary
      } else {
        return Theme.on_surface
      }
    }
    // Icon is 50% of container size
    font.pixelSize: Math.round(root.size * 0.5)
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
