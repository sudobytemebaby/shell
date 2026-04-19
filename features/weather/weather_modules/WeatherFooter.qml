import QtQuick
import QtQuick.Layouts
import "../../../shared/theme"
import "../../../shared/components/Modals"
import "../../../shared/components/Animations"

// ----------------------------------------------------------------------------
// Weather Footer
// ----------------------------------------------------------------------------
// Footer with navigation dots and status information.
// Shows current page indicator, keyboard shortcuts, and last update time.

ColumnLayout {
  spacing: Config.spacing.md

  // ==========================================================================
  // PROPERTIES
  // ==========================================================================

  property int currentIndex: 0
  property int pageCount: 3
  property string lastUpdate: ""
  signal indexSelected(int index)

  // ==========================================================================
  // NAVIGATION DOTS
  // ==========================================================================

  RowLayout {
    Layout.alignment: Qt.AlignHCenter
    spacing: Config.spacing.sm

    Repeater {
      model: pageCount

      Rectangle {
        width: 8
        height: 8
        radius: 4
        color: index === currentIndex ? Theme.primary : Theme.surface_container_highest

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: indexSelected(index)
        }

        AColor on color {}
      }
    }
  }

  // ==========================================================================
  // BOTTOM BAR (Help Text + Last Update)
  // ==========================================================================

  Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 20

    // Centered keyboard shortcut hints
    FooterHint {
      anchors.centerIn: parent
      width: parent.width
      hint: "Arrows to Switch • Esc Close"
    }

    // Right-aligned last update timestamp
    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.rightMargin: Config.padding.sm
      visible: lastUpdate !== ""
      text: "Updated: " + lastUpdate
      color: Theme.on_surface_variant
      font.pixelSize: Config.typography.xs
      font.family: Config.typography.sans
      opacity: 0.5
    }
  }
}
