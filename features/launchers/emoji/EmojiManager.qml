import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core/system_state" as Core
import "EmojiData.js" as EmojiData

Scope {
  id: manager

  // Visibility state
  property bool visible: false

  // Search text
  property string searchText: ""

  // Emoji data model (ListModel for performance)
  property alias emojiModel: emojiModel
  property var emojiGroups: []

  // Loading state (synchronous now, but keep for compatibility)
  property bool isLoading: false
  property string errorMessage: ""

  // Selected group filter (empty = all)
  property string selectedGroup: ""

  // ListModel for emoji data
  ListModel {
    id: emojiModel
  }

  onVisibleChanged: {
    if (visible) {
      searchText = "" // Reset search when opening
      selectedGroup = "" // Reset group filter
    }
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
    console.log("[EmojiManager] Loading emoji data...")

    try {
      // Load pre-processed data from JS module
      var emojis = EmojiData.emojis
      var groups = EmojiData.groups

      // Populate ListModel
      for (var i = 0; i < emojis.length; i++) {
        emojiModel.append(emojis[i])
      }

      manager.emojiGroups = groups

      console.log("[EmojiManager] Loaded", emojiModel.count, "emojis in", groups.length, "groups")
    } catch (error) {
      manager.errorMessage = "Failed to load emoji data: " + error
      console.error("[EmojiManager]", manager.errorMessage)
    }
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
