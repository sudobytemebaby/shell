import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
    id: root

    // Receive systemState from parent (Bar.qml)
    required property var systemState

    // Direct property bindings to the KeyboardLayout module
    // Updates INSTANTLY when layout changes via Hyprland IPC events
    property string icon: systemState.keyboardLayout.currentIcon
    property string layout: systemState.keyboardLayout.currentLayout

    implicitWidth: layoutText.implicitWidth
    implicitHeight: Theme.barHeight

    Text {
        id: layoutText
        anchors.centerIn: parent
        text: root.icon + " " + root.layout.toUpperCase()
        color: Theme.on_surface
        font.pixelSize: Theme.fontSizeS
        font.family: "Ubuntu Nerd Font"
        verticalAlignment: Text.AlignVCenter
    }
}
