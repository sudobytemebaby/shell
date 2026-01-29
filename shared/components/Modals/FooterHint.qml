import QtQuick
import QtQuick.Layouts
import "../../theme"

/**
 * FooterHint
 *
 * Standardized footer component for displaying keyboard shortcuts and hints
 * at the bottom of modal dialogs and menu interfaces.
 *
 * FEATURES:
 * - Consistent styling across all modals
 * - Center-aligned hint text with reduced opacity
 * - Responsive to parent width
 *
 * USAGE:
 * ```qml
 * FooterHint {
 *   hint: "↑↓ Navigate • Enter Select • Esc Close"
 * }
 * ```
 *
 * COMMON HINT PATTERNS:
 * - Menu navigation: "Arrows to Navigate • Enter to Select • Esc to Close"
 * - App launcher: "↑↓ / Ctrl+P/N Navigate • Enter Launch • Esc Close"
 * - Grid navigation: "↑↓←→ Navigate • Enter Select • Esc Close"
 * - Tab navigation: "Arrow Keys Navigate • Tab Next • Shift+Tab Previous • Enter Apply • Esc Close"
 */
Text {
  id: root

  /**
   * The hint text to display
   * Use bullet separator (•) between different actions
   */
  property string hint: ""

  Layout.fillWidth: true
  text: hint
  color: Theme.on_surface_variant
  font.pixelSize: Theme.typography.sm
  font.family: Theme.typography.fontFamilyDisplay
  horizontalAlignment: Text.AlignHCenter
  opacity: 0.7
}
