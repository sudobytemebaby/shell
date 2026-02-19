import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../../shared/theme"
import "../../../../shared/components"
import "../../../../core/system_state" as Core

/**
 * PowerWidgets - Quick power actions for the lockscreen
 *
 * Provides vertical buttons for:
 * - Suspend to RAM
 * - Reboot system
 * - Power off system
 *
 * Repositioned to the right side of the screen with no background.
 */

Item {
  id: root

  // ============================================================================
  // DIMENSIONS
  // ============================================================================

  implicitWidth: contentColumn.implicitWidth
  implicitHeight: contentColumn.implicitHeight

  // ============================================================================
  // CONTENT
  // ============================================================================

  ColumnLayout {
    id: contentColumn
    anchors.centerIn: parent
    spacing: Theme.spacing.lg

    // Suspend Button
    RoundIconButton {
      icon: "󰤄"
      size: 44
      onClicked: Core.ProcessUtils.runCommand(root, ["systemctl", "suspend"])
    }

    // Reboot Button
    RoundIconButton {
      icon: "󰜉"
      size: 44
      onClicked: Core.ProcessUtils.runCommand(root, ["systemctl", "reboot"])
    }

    // Power Off Button
    RoundIconButton {
      icon: "󰐥"
      size: 44
      onClicked: Core.ProcessUtils.runCommand(root, ["systemctl", "poweroff"])
    }
  }
}
