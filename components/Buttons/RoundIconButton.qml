import QtQuick
import "../../theme"

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
  radius: variant === "media" ? (isPrimary ? size / 2 : size / 2) : Theme.radius.full

  color: {
    if (isPrimary) {
      if (variant === "media") {
        return mouseArea.containsMouse ? Theme.primary : Theme.primary_transparent
      } else {
        return mouseArea.pressed ? Qt.darker(Theme.primary, 1.2) : Theme.primary
      }
    } else {
      if (variant === "media") {
        return mouseArea.containsMouse ? Theme.surface : "transparent"
      } else {
        return mouseArea.containsMouse ? Qt.lighter(Theme.surface_container_low, 1.3) : Theme.surface_container_low_transparent_light
      }
    }
  }

  border.width: {
    if (isPrimary) {
      return variant === "media" ? 2 : 0
    } else {
      return 1
    }
  }

  border.color: {
    if (isPrimary) {
      return variant === "media" ? Theme.primary : "transparent"
    } else {
      if (variant === "media") {
        return mouseArea.containsMouse ? Theme.outline_variant : "transparent"
      } else {
        return Theme.surface_container_high
      }
    }
  }

  scale: mouseArea.pressed ? (isPrimary && variant === "media" ? 0.92 : 0.88) : 1.0

  // ============================================================================
  // ANIMATIONS
  // ============================================================================

  Behavior on color {
    ColorAnimation { duration: 150 }
  }

  Behavior on border.color {
    ColorAnimation { duration: 150 }
  }

  Behavior on scale {
    NumberAnimation {
      duration: 100
      easing.type: Easing.OutCubic
    }
  }

  // ============================================================================
  // SHADOW (Optional - for media variant)
  // ============================================================================

  Rectangle {
    visible: root.isPrimary && root.showShadow
    anchors.centerIn: parent
    width: parent.width + 4
    height: parent.height + 4
    radius: (width) / 2
    color: "transparent"
    border.width: 2
    border.color: Theme.scrim_transparent
    z: -1
    opacity: mouseArea.containsMouse ? 1 : 0.6

    Behavior on opacity {
      NumberAnimation { duration: 150 }
    }
  }

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
    font.pixelSize: isPrimary ? Theme.typography.xxl : Theme.typography.xl
    font.family: Theme.typography.fontFamily
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
