import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"

/**
 * Keyboard - Displays current keyboard layout
 *
 * Shows the active keyboard layout as a simple two-letter code
 * (EN, RU, FR, GE, etc.) that updates instantly when layout changes.
 */

Item {
    id: root

    // Receive systemState from parent (Bar.qml)
    required property var systemState

    // Current keyboard layout from KeyboardLayout module
    // Updates instantly when layout changes via Hyprland IPC events
    property string layout: systemState.keyboardLayout.currentLayout

    implicitWidth: layoutText.implicitWidth
    implicitHeight: Theme.barHeight

    // Display keyboard layout code in uppercase
    Text {
        id: layoutText
        anchors.centerIn: parent
        text: root.layout.toUpperCase()
        color: Theme.on_surface
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.typography.fontFamily
        verticalAlignment: Text.AlignVCenter
    }
}
