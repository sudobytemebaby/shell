import QtQuick
import Quickshell
import Quickshell.Io
import "../core" as Core

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Power options with their commands
  property var powerOptions: [
    {
      icon: "󰐥",
      name: "Shutdown",
      description: "Power off the system",
      command: "systemctl poweroff",
      color: "#E82424"
    },
    {
      icon: "󰜉",
      name: "Reboot",
      description: "Restart the system",
      command: "systemctl reboot",
      color: "#FF9E3B"
    },
    {
      icon: "󰍃",
      name: "Logout",
      description: "End your session",
      command: "hyprctl dispatch exit",
      color: "#7E9CD8"
    },
    {
      icon: "󰌾",
      name: "Lock",
      description: "Lock the screen",
      command: "loginctl lock-session",
      color: "#7FB4CA"
    },
    {
      icon: "󰤄",
      name: "Suspend",
      description: "Suspend to RAM",
      command: "systemctl suspend",
      color: "#98BB6C"
    },
    {
      icon: "󰋊",
      name: "Hibernate",
      description: "Suspend to disk",
      command: "systemctl hibernate",
      color: "#957FB8"
    }
  ]
  
  // Execute a power option
  function executePowerOption(option) {
    console.log("[PowerMenu] Executing:", option.name, "command:", option.command)
    
    // Close menu immediately for better UX
    manager.visible = false
    
    // Execute command
    Core.ProcessUtils.runCommand(
      manager,
      ["sh", "-c", option.command],
      () => {
        console.log("[PowerMenu] Command executed successfully")
      },
      (code, error) => {
        console.error("[PowerMenu] Failed to execute command:", error)
      }
    )
  }
  
  // IPC Handler for external control
  IpcHandler {
    target: "powermenu"
    
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
