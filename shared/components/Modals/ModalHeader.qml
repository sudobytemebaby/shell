import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../Animations"

/**
 * ModalHeader
 *
 * Standard header component for modal dialogs with title, optional action buttons,
 * and close button. Provides consistent styling and layout across all modals.
 *
 * FEATURES:
 * - Title text with optional fade transition
 * - Support for action buttons (refresh, settings, etc.)
 * - Integrated close button with configurable style
 * - Responsive layout
 * - Optional title animation on text change
 *
 * USAGE:
 * ```qml
 * ModalHeader {
 *   title: "Weather"
 *   closeButtonStyle: "rounded"
 *   animateTitle: true
 *
 *   actionButtons: [
 *     {
 *       icon: "󰑐",
 *       tooltip: "Refresh",
 *       onClicked: () => { refreshData() }
 *     }
 *   ]
 *
 *   onCloseClicked: manager.visible = false
 * }
 * ```
 */
RowLayout {
  id: root

  Layout.fillWidth: true
  Layout.preferredHeight: 40
  spacing: Config.spacing.sm

  /**
   * Title text displayed in the header
   */
  property string title: ""

  /**
   * Enable fade animation when title changes
   * Useful for dynamic titles that update (e.g., weather location)
   */
  property bool animateTitle: false

  /**
   * Duration of the fade out/in animation in milliseconds.
   * Total animation time = 2 * fadeDuration (out + in).
   * Default: 100ms
   */
  property int fadeDuration: 100

  /**
   * Style for the close button: "minimal" or "rounded"
   * Default: "rounded" for modern, emphasized appearance
   */
  property string closeButtonStyle: "minimal"

  /**
   * Array of action button definitions
   * Each button object should have: { icon: string, tooltip: string, onClicked: function }
   * Buttons appear between the title and close button
   *
   * Example:
   * [
   *   { icon: "󰑐", tooltip: "Refresh", onClicked: () => { refresh() } },
   *   { icon: "", tooltip: "Settings", onClicked: () => { openSettings() } }
   * ]
   */
  property var actionButtons: []

  /**
   * Emitted when close button is clicked
   */
  signal closeClicked()

  // ==========================================================================
  // TITLE TEXT
  // ==========================================================================

  Text {
    id: headerText
    Layout.fillWidth: true
    Layout.leftMargin: Config.padding.xs

    text: root.title

    color: Theme.on_surface
    font.pixelSize: Config.typography.xl
    font.family: Config.typography.sans
    font.weight: Config.typography.weightMedium

    // Smooth fade transition when title changes (optional)
    Behavior on text {
      enabled: root.animateTitle
      SequentialAnimation {
        NumberAnimation { target: headerText; property: "opacity"; to: 0; duration: root.fadeDuration }
        PropertyAction { target: headerText; property: "text" }
        NumberAnimation { target: headerText; property: "opacity"; to: 1; duration: root.fadeDuration }
      }
    }
  }

  // ==========================================================================
  // ACTION BUTTONS (DYNAMIC)
  // ==========================================================================

  Repeater {
    model: root.actionButtons

    Rectangle {
      required property var modelData
      required property int index

      Layout.preferredWidth: 32
      Layout.preferredHeight: 32
      radius: Config.radius.full
      color: "transparent"


      Text {
        id: actionIcon
        anchors.centerIn: parent
        text: modelData.icon || ""
        color: actionMouseArea.containsMouse ? Theme.outline : Theme.on_surface
        font.pixelSize: Config.typography.lg
        font.family: Config.typography.sans

        AColor on color {}
      }

      MouseArea {
        id: actionMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
          if (modelData.onClicked) {
            modelData.onClicked()
          }
        }

        // TODO: Add tooltip support when needed (requires QtQuick.Controls)
      }
    }
  }

  // ==========================================================================
  // CLOSE BUTTON
  // ==========================================================================

  CloseButton {
    style: root.closeButtonStyle
    onClicked: root.closeClicked()
  }
}
