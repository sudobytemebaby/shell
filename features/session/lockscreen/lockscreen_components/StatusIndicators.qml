import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../../shared/theme"

// ============================================================================
// STATUS INDICATORS
// Shows battery, keyboard layout, and username
// ============================================================================

Rectangle {
  id: root

  required property var systemState

  readonly property string username: Quickshell.env("USER") || "user"

  width: contentRow.implicitWidth + Config.padding.lg * 2
  height: 60
  radius: Config.radius.lg
  color: Theme.surface

  RowLayout {
    id: contentRow
    anchors.centerIn: parent
    spacing: Config.spacing.lg

    // User info
    RowLayout {
      spacing: Config.spacing.sm

      Text {
        text: "󰀄"
        font.pixelSize: Config.typography.lg
        font.family: Config.typography.sans
        color: Theme.primary
      }

      Text {
        text: root.username
        font.pixelSize: Config.typography.md
        font.family: Config.typography.sans
        font.weight: Config.typography.weightMedium
        color: Theme.on_surface
      }
    }

    // Divider
    Rectangle {
      width: 1
      height: 30
      color: Theme.outline_variant
    }

    // Battery (only show if laptop)
    RowLayout {
      spacing: Config.spacing.sm
      visible: root.systemState?.battery.isLaptopBattery ?? false

      Text {
        text: root.systemState?.battery.batteryIcon ?? ""
        font.pixelSize: Config.typography.lg
        font.family: Config.typography.sans
        color: {
          if (!root.systemState) return Theme.on_surface_variant
          if (root.systemState.battery.isCharging) return Theme.primary
          if (root.systemState.battery.percentage < 0.2) return Theme.error
          return Theme.on_surface_variant
        }
      }

      Text {
        text: root.systemState
          ? Math.round(root.systemState.battery.percentage * 100) + "%"
          : "0%"
        font.pixelSize: Config.typography.md
        font.family: Config.typography.sans
        color: Theme.on_surface_variant
      }
    }

    // Divider (only show if battery is visible)
    Rectangle {
      width: 1
      height: 30
      color: Theme.outline_variant
      visible: root.systemState?.battery.isLaptopBattery ?? false
    }

    // Keyboard layout
    Text {
      text: root.systemState?.keyboardLayout.currentLayout ?? "EN"
      font.pixelSize: Config.typography.md
      font.family: Config.typography.sans
      color: Theme.on_surface_variant
    }
  }
}
