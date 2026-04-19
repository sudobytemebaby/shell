import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../Animations"

/**
 * CloseButton
 *
 * Reusable close button component for modal dialogs and overlays.
 * Supports two visual styles: minimal (text only) and rounded (with background).
 *
 * FEATURES:
 * - Two visual styles: "minimal" and "rounded"
 * - Hover feedback with cursor change
 * - Optional hover background highlight
 * - Consistent sizing and styling
 *
 * USAGE:
 * ```qml
 * CloseButton {
 *   style: "rounded"  // or "minimal"
 *   onClicked: manager.visible = false
 * }
 * ```
 *
 * STYLES:
 * - minimal: Simple X text with no background (for clean headers)
 * - rounded: X in a circular button with hover background (for emphasized close)
 */
Item {
  id: root

  /**
   * Visual style variant
   * - "minimal": Text only, no background
   * - "rounded": Circular button with hover background
   */
  property string style: "minimal"

  /**
   * Emitted when the close button is clicked
   */
  signal clicked()

  // Size based on style
  Layout.preferredWidth: style === "rounded" ? 32 : implicitWidth
  Layout.preferredHeight: style === "rounded" ? 32 : implicitHeight
  Layout.rightMargin: style === "rounded" ? Config.padding.xs : Config.padding.sm

  implicitWidth: closeText.implicitWidth
  implicitHeight: closeText.implicitHeight

  // Background (only for rounded style)
  Rectangle {
    anchors.fill: parent
    radius: Config.radius.full
    visible: style === "rounded"
    color: mouseArea.containsMouse ? Theme.surface_container_high : "transparent"

  }

  // Close icon (X)
  Text {
    id: closeText
    anchors.centerIn: parent
    text: "✕"
    color: mouseArea.containsMouse ? Theme.outline : Theme.on_surface
    font.pixelSize: Config.typography.lg
    font.family: Config.typography.sans

    AColor on color {}
  }

  // Interactive area
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: root.clicked()
  }
}
