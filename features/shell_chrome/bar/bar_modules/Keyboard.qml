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

    Layout.alignment: Qt.AlignVCenter
    Layout.minimumWidth: 32

    implicitWidth: Math.max(layoutText.implicitWidth, 32)
    implicitHeight: Config.bar.height

    // Display keyboard layout code in uppercase
    Text {
        id: layoutText
        anchors.centerIn: parent
        text: root.layout
        color: Theme.on_surface
        font.pixelSize: Config.typography.sm
        font.family: Config.typography.sans
        verticalAlignment: Text.AlignVCenter
    }
}
