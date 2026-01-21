import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: manager
  
  // ============================================================================
  // PUBLIC API
  // ============================================================================
  
  property bool locked: false
  
  function lock() {
    locked = true
  }
  
  function unlock() {
    locked = false
  }
  
  function toggle() {
    locked = !locked
  }
  
  // ============================================================================
  // IPC HANDLER
  // ============================================================================
  
  property var ipcHandler: IpcHandler {
    target: "lockscreen"
    
    function lock(): void {
      manager.lock()
    }
    
    function unlock(): void {
      manager.unlock()
    }
    
    function toggle(): void {
      manager.toggle()
    }
  }
}
