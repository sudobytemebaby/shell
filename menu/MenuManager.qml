import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Search text
  property string searchText: ""
  
  // Reference to launcher manager (for the Applications item)
  required property var launcherManager
  
  // Reference to wallpaper manager (for the Wallpapers item)
  required property var wallpaperManager
  
  // Reference to power menu manager (for the Power item)
  required property var powerMenuManager
  
  // Reference to emoji manager (for the Emoji item)
  required property var emojiManager
  
  // Reference to lockscreen manager (for the Lock item)
  required property var lockscreenManager
  
  onVisibleChanged: {
    if (visible) {
      searchText = "" // Reset search when opening
    }
  }
  
  // Define our menu items - NEW: Added Themes entry
  property var menuItems: [
    {
      icon: "󰂯",
      name: "Bluetooth",
      description: "Manage Bluetooth devices",
      command: "kitty --class floating_term_s -e bluetui"
    },
    {
      icon: "󰤥",
      name: "WiFi",
      description: "Manage WiFi connections",
      command: "kitty --class floating_term_m -e impala"
    },
    {
      icon: "󱡫",
      name: "Audio",
      description: "Audio mixer and settings",
      command: "kitty --class floating_term_s -e wiremix"
    },
    {
      icon: "󰀻",
      name: "Applications",
      description: "Launch applications",
      command: "launcher"  // Special command to trigger launcher
    },
    {
      icon: "󱚣",
      name: "Emoji Picker",
      description: "Pick and copy emojis",
      command: "emoji"  // Special command to trigger emoji picker
    },
    {
      icon: "󰸉",
      name: "Wallpapers",
      description: "Change wallpaper",
      command: "wallpapers"  // Special command to trigger wallpaper picker
    },
    {
      icon: "󰏘",
      name: "Themes",
      description: "Switch color scheme",
      command: "themes"  // Special command to trigger theme switcher
    },
    {
      icon: "󰌾",
      name: "Lock Screen",
      description: "Lock your screen",
      command: "lock"  // Special command to trigger lockscreen
    },
    {
      icon: "󰐥",
      name: "Power",
      description: "Shutdown, reboot, logout...",
      command: "power"  // Special command to trigger power menu
    },
    {
      icon: "",
      name: "Files",
      description: "Browse files with Yazi",
      command: "kitty --class floating_term_l -e yazi"
    },
    {
      icon: "󱙣",
      name: "System Monitor",
      description: "View system resources",
      command: "kitty --class floating_term_l -e btop"
    }
  ]
  
  // Execute a menu item's command
  function executeItem(item) {
    // Special case: Applications opens the launcher
    if (item.command === "launcher") {
      manager.visible = false
      launcherManager.visible = true
      return
    }
    
    // Special case: Emoji Picker opens the emoji picker
    if (item.command === "emoji") {
      manager.visible = false
      emojiManager.visible = true
      return
    }
    
    // Special case: Wallpapers opens the wallpaper picker
    if (item.command === "wallpapers") {
      manager.visible = false
      wallpaperManager.visible = true
      return
    }
    
    // Special case: Themes opens the theme switcher - NEW
    if (item.command === "themes") {
      manager.visible = false
      themeManager.visible = true
      return
    }
    
    // Special case: Lock Screen locks the screen
    if (item.command === "lock") {
      manager.visible = false
      lockscreenManager.lock()
      return
    }
    
    // Special case: Power opens the power menu
    if (item.command === "power") {
      manager.visible = false
      powerMenuManager.visible = true
      return
    }
    
    // For everything else, use execDetached
    try {
      Quickshell.execDetached({
        command: ["sh", "-c", item.command]
      })
      manager.visible = false
    } catch (error) {
      console.error("[MenuManager] Failed to execute command:", error)
    }
  }
  
  // IPC Handler for external control
  IpcHandler {
    target: "menu"
    
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
