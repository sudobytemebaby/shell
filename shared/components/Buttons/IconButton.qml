import QtQuick
import QtQuick.Layouts
import "../../theme"
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
  property color inactiveIconBg: Theme.surface_container_highest
  property color inactiveIconColor: Theme.on_surface_variant

  // ========== APPEARANCE ==========
  radius: Theme.radius.xxl
  color: Theme.surface_container_transparent_light
  //color: "transparent"

  border.width: 0.5
  border.color: Theme.surface_container_high

  // ========== ANIMATIONS ==========
  Behavior on color {
    ColorAnimation { duration: 200 }
  }

  // ========== CONTENT ==========
  RowLayout {
    anchors {
      fill: parent
      topMargin: Theme.padding.sm
      bottomMargin: Theme.padding.sm
      leftMargin: Theme.padding.lg
      rightMargin: Theme.padding.lg
    }
    spacing: Theme.spacing.sm

    // Icon container
    IconCircle {
      Layout.preferredWidth: 40
      Layout.preferredHeight: 40
      Layout.alignment: Qt.AlignVCenter

      icon: root.icon
      iconSize: Theme.typography.xl

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

      Behavior on scale {
        NumberAnimation {
          duration: 150
          easing.type: Easing.OutCubic
        }
      }
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
        font.pixelSize: Theme.typography.md
        font.family: Theme.typography.fontFamilyDisplay
        font.weight: Theme.typography.weightMedium

        Behavior on opacity {
          NumberAnimation { duration: 200 }
        }
      }

      Text {
        text: root.subtitle

        // If stateful and active, show accent color. Otherwise muted
        color: root.isStateful && root.isActive
               ? Theme.primary
               : Theme.on_surface_variant

        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        opacity: 0.8

        Behavior on color {
          ColorAnimation { duration: 200 }
        }
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
