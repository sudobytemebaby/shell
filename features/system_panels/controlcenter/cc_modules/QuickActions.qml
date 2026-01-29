import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"
import "../../../../shared/theme"

/**
 * QuickActions - Grid of quick action buttons for Control Center
 *
 * Displays a 2x2 grid of round icon buttons for common quick actions:
 * - Color picker (hyprpicker)
 * - Clipboard manager (clipse)
 * - Terminal launcher
 * - Theme switcher (matugen)
 *
 * The grid is designed to be half-width in the control center layout,
 * appearing next to the media player controls.
 *
 * Properties:
 * - quickActionsManager: Manager handling button actions and logic
 */

Card {
  id: root
  padding: Theme.padding.md
  color: "transparent"

  required property var quickActionsManager

  GridLayout {
    anchors.centerIn: parent
    columns: 2
    rowSpacing: Theme.spacing.lg
    columnSpacing: Theme.spacing.lg

    Repeater {
      model: root.quickActionsManager.actions.length

      delegate: RoundIconButton {
        required property int index
        size: 50
        icon: root.quickActionsManager.actions[index].icon
        isPrimary: true
        onClicked: root.quickActionsManager.actions[index].action()
      }
    }
  }
}
