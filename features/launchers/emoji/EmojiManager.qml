import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core/system_state" as Core

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Search text
  property string searchText: ""
  
  // Emoji data
  property var emojis: []
  property var emojiGroups: []
  
  // Loading state
  property bool isLoading: true
  property string errorMessage: ""
  
  // Selected group filter (empty = all)
  property string selectedGroup: ""
  
  // JSON file path
  readonly property string emojiJsonPath: {
    var homeDir = Quickshell.env("HOME")
    return homeDir + "/.config/quickshell/features/launchers/emoji/emojis.json"
  }
  
  onVisibleChanged: {
    if (visible) {
      searchText = "" // Reset search when opening
      selectedGroup = "" // Reset group filter
    }
  }
  
  // Process to read JSON file
  Process {
    id: readJsonProcess
    command: ["cat", manager.emojiJsonPath]
    
    property string jsonBuffer: ""
    
    onStarted: {
      jsonBuffer = ""
    }
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        readJsonProcess.jsonBuffer += data
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (!data) return
        manager.errorMessage = "Failed to read emoji file: " + data
        manager.isLoading = false
      }
    }
    
    onExited: code => {
      if (code !== 0) {
        manager.errorMessage = "Failed to read emoji file (exit code: " + code + ")"
        manager.isLoading = false
        return
      }
      
      // Parse JSON
      try {
        var jsonData = JSON.parse(readJsonProcess.jsonBuffer)
        manager.parseEmojiData(jsonData)
      } catch (error) {
        manager.errorMessage = "Failed to parse emoji JSON: " + error
        manager.isLoading = false
      }
    }
  }
  
  // Parse emoji data from JSON
  function parseEmojiData(jsonData) {
    var emojiList = []
    var groups = new Set()
    
    // Convert JSON object to array
    for (var emoji in jsonData) {
      var data = jsonData[emoji]
      emojiList.push({
        emoji: emoji,
        name: data.name || "",
        slug: data.slug || "",
        group: data.group || "Other",
        keywords: (data.name || "").toLowerCase()
      })
      groups.add(data.group || "Other")
    }
    
    manager.emojis = emojiList
    manager.emojiGroups = Array.from(groups).sort()
    manager.isLoading = false
    
    console.log("[EmojiManager] Loaded", emojiList.length, "emojis in", manager.emojiGroups.length, "groups")
  }
  
  // Function to copy emoji to clipboard
  function copyEmoji(emoji) {
    console.log("[EmojiManager] Copying emoji:", emoji)
    
    Core.ProcessUtils.runCommand(
      manager,
      ["emoji-picker", emoji],
      () => {
        // Close picker after successful copy
        manager.visible = false
      },
      (code, error) => {
        console.error("[EmojiManager] Failed to copy emoji:", error)
      }
    )
  }
  
  // Load emojis when component is created
  Component.onCompleted: {
    readJsonProcess.running = true
  }
  
  // IPC Handler for external control
  IpcHandler {
    target: "emoji"
    
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
