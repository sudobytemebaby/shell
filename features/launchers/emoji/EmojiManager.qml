import QtQuick
import Quickshell
import Quickshell.Io
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
  property alias emojiModel: emojiModel

  // Array of emoji category names
  property var emojiGroups: []

  // Loading state - true when emoji data has been loaded
  property bool loaded: false

  // Internal ListModel
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
    // Escape emoji for shell: replace ' with '\''
    var escapedEmoji = emoji.replace(/'/g, "'\\''")
    
    // Copy to clipboard
    Quickshell.execDetached(["sh", "-c", "printf '%s' '" + escapedEmoji + "' | wl-copy"])
    
    // Show notification
    Quickshell.execDetached(["sh", "-c", "notify-send -u low 'Emoji Copied' '" + escapedEmoji + "'"])
    
    // Close picker
    Qt.callLater(() => {
      Qt.callLater(() => {
        manager.visible = false
      })
    })
  }

  // ========== DATA LOADING ==========

  /**
   * Load emoji data from pre-processed JavaScript module
   * Uses Qt.callLater() to defer loading until after shell init completes
   * This prevents blocking the UI during shell startup
   */
  function loadEmojis() {
    try {
      var emojis = EmojiData.emojis
      var groups = EmojiData.groups

      for (var i = 0; i < emojis.length; i++) {
        emojiModel.append(emojis[i])
      }

      manager.emojiGroups = groups
      manager.loaded = true
    } catch (error) {
      manager.errorMessage = "Failed to load emoji data: " + error
    }
  }

  // Deferred loading - runs after shell init completes
  Component.onCompleted: {
    Qt.callLater(() => {
      loadEmojis()
    })
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
