import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core/system_state" as Core
import "EmojiData.js" as EmojiData

/**
 * EmojiManager - Central state and logic manager for the emoji picker
 *
 * This component manages:
 * - Emoji data loading from pre-processed JavaScript module
 * - Visibility state for the picker window
 * - Search and filter state
 * - Clipboard operations via external script
 * - IPC interface for external control (toggle/open/close)
 *
 * Architecture:
 * - This is a pure state management layer (no UI)
 * - UI is handled by EmojiDisplay.qml which binds to this manager
 * - Emoji data is pre-processed in EmojiData.js for fast synchronous loading
 */
Scope {
  id: manager

  // ========== VISIBILITY STATE ==========

  property bool visible: false  // Controls whether the emoji picker window is shown

  // Reset state when picker is closed
  onVisibleChanged: {
    if (visible) {
      searchText = ""       // Clear search
      selectedGroup = ""    // Reset category filter
    }
  }

  // ========== SEARCH AND FILTER STATE ==========

  property string searchText: ""     // Current search query (bound to SearchBar input)
  property string selectedGroup: ""  // Selected emoji category (empty = all categories)

  // ========== EMOJI DATA ==========

  // ListModel containing all emoji data
  // Populated synchronously from EmojiData.js on component creation
  property alias emojiModel: emojiModel

  // Array of emoji category names (e.g., "Smileys & Emotion", "Animals & Nature", etc.)
  property var emojiGroups: []

  // Internal ListModel - contains all emojis loaded from EmojiData.js
  ListModel {
    id: emojiModel
  }

  // ========== ERROR HANDLING ==========

  property string errorMessage: ""  // Error message if emoji data fails to load

  // ========== CLIPBOARD OPERATIONS ==========

  /**
   * Copy emoji to clipboard using external emoji-picker script
   * The script handles:
   * - Copying emoji to Wayland clipboard via wl-copy
   * - Showing desktop notification
   * - Error handling for missing dependencies
   *
   * @param emoji - The emoji character to copy
   */
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

  // ========== DATA LOADING ==========

  /**
   * Load emoji data from pre-processed JavaScript module
   * This runs synchronously on component creation
   *
   * EmojiData.js contains:
   * - emojis: Array of 3,515+ emoji objects with name, keywords, group, etc.
   * - groups: Array of 9 emoji category names
   *
   * The data is pre-processed from emojis.json to avoid runtime JSON parsing overhead
   */
  Component.onCompleted: {
    console.log("[EmojiManager] Loading emoji data...")

    try {
      // Load pre-processed data from JS module
      var emojis = EmojiData.emojis
      var groups = EmojiData.groups

      // Populate ListModel with emoji data
      // Note: This is synchronous and may block UI for a moment
      // Consider async loading via WorkerScript for very large datasets
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

  // ========== IPC INTERFACE ==========

  /**
   * IPC handler for external control of the emoji picker
   * Allows other processes to control the picker via quickshell IPC
   *
   * Available methods:
   * - toggle(): Toggle picker visibility
   * - open(): Show picker
   * - close(): Hide picker
   *
   * Example usage from shell:
   *   quickshell --ipc emoji toggle
   */
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
