import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../../theme"

Item {
    id: root
    
    property string icon: "KB"
    property string layout: "Unknown"
    
    implicitWidth: layoutText.implicitWidth
    implicitHeight: Theme.barHeight
    
    Text {
        id: layoutText
        anchors.centerIn: parent
        text: " " + root.layout
        color: Theme.on_surface
        font.pixelSize: Theme.fontSizeS
        font.family: "Ubuntu Nerd Font"
        verticalAlignment: Text.AlignVCenter
    }
    
    // ========== KEYBOARD LAYOUT DETECTION ==========
    
    // Monitor Hyprland focused window changes (layout often changes with window focus)
    Connections {
        target: Hyprland
        
        function onFocusedMonitorChanged() {
            updateLayout()
        }
    }
    
    // Update keyboard layout from script
    function updateLayout() {
        kbProc.running = true
    }
    
    Process {
        id: kbProc
        command: ["bash", "-c", "$HOME/.local/bin/keyboard-state"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") return
                
                var line = data.trim()
                var parts = line.split("|")
                if (parts.length === 2) {
                    root.icon = parts[0]
                    root.layout = parts[1]
                }
                // Process will exit after outputting, set running to false
                kbProc.running = false
            }
        }
        
        stderr: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    console.error("[Keyboard] Error:", data.trim())
                }
            }
        }
    }
    
    // Fallback timer for periodic updates (every 5 seconds)
    // Catches layout changes that don't trigger monitor focus changes
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: updateLayout()
    }
    
    // Initialize on startup
    Component.onCompleted: {
        updateLayout()
    }
}
