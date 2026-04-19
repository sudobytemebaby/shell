import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../Animations"
import ".."

Rectangle {
  id: root

  // ========== PUBLIC API ==========
  required property string icon
  required property string title
  required property string subtitle
  signal clicked()

  // Optional: For stateful buttons (toggles)
  property bool isStateful: true      // Set to false for action-only buttons
  property bool isActive: false       // Only matters if isStateful is true

  // Optional: Custom colors (for special cases like recording)
  property color activeIconBg: Theme.primary_container
  property color activeIconColor: Theme.primary
  property color inactiveIconBg: Theme.surface_container_high
  property color inactiveIconColor: Theme.on_surface_variant

  // ========== APPEARANCE ==========
  radius: Config.radius.full
  color: "transparent"

  border.width: 0
  border.color: Theme.surface_container_high

  // ========== ANIMATIONS ==========
  AColor on color {}

  // ========== CONTENT ==========
  RowLayout {
    anchors {
      fill: parent
      topMargin: Config.padding.sm
      bottomMargin: Config.padding.sm
      leftMargin: Config.padding.lg
      rightMargin: Config.padding.lg
    }
    spacing: Config.spacing.sm

    // Icon container
    IconCircle {
      Layout.preferredWidth: 40
      Layout.preferredHeight: 40
      Layout.alignment: Qt.AlignVCenter

      icon: root.icon
      iconSize: Config.typography.xl

      // Color logic: if stateful,
      // use active/inactive colors.
      // If not, just use inactive
      bgColor: root.isStateful && root.isActive
               ? root.activeIconBg
               : root.inactiveIconBg

      iconColor: root.isStateful && root.isActive
                 ? root.activeIconColor
                 : root.inactiveIconColor

      scale: mouseArea.pressed ? 0.88 : 1.0

      AScale on scale {}
    }

    // Text content
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 2

      Text {
        text: root.title
        color: Theme.on_surface
        // If stateful, dim when inactive. If not stateful, always full opacity
        opacity: root.isStateful ? (root.isActive ? 1 : 0.8) : 1
        font.pixelSize: Config.typography.md
        font.family: Config.typography.sans
        font.weight: Config.typography.weightMedium

        AFade on opacity {}
      }

      Text {
        text: root.subtitle

        // If stateful and active, show accent color. Otherwise muted
        color: root.isStateful && root.isActive
               ? Theme.primary
               : Theme.on_surface_variant

        font.pixelSize: Config.typography.sm
        font.family: Config.typography.sans
        opacity: 0.8

        AColor on color {}
      }
    }
  }

  // ========== INTERACTION ==========
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
