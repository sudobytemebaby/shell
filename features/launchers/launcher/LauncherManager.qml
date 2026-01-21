import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // Current state
  property bool visible: false
  property string searchText: ""
  
  onVisibleChanged: {
    if (visible) {
      searchText = "" // Reset search when opening
    }
  }
  
  // IPC Handler - allows external control via command line
  IpcHandler {
    target: "launcher"
    
    function toggle(): void {
      manager.visible = !manager.visible
    }
    
    function open(): void {
      manager.visible = true
    }
    
    function close(): void {
      manager.visible = false
    }
  }
}
