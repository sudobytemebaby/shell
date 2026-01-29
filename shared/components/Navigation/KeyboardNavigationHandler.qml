import QtQuick
import "../../theme"

/**
 * KeyboardNavigationHandler
 *
 * Reusable keyboard navigation logic for lists and grids.
 * Provides consistent navigation patterns across all menu and modal interfaces.
 *
 * FEATURES:
 * - Up/Down arrow navigation (1D lists)
 * - Up/Down/Left/Right arrow navigation (2D grids)
 * - Ctrl+P/N for Up/Down (Emacs-style)
 * - Tab/Shift+Tab navigation
 * - Home/End jump navigation
 * - Escape to close
 * - Enter to select
 * - Wrap-around support
 * - Grid dimension awareness (calculates 2D navigation)
 *
 * USAGE:
 * ```qml
 * Item {
 *   property int currentIndex: 0
 *
 *   KeyboardNavigationHandler {
 *     id: navHandler
 *     currentIndex: parent.currentIndex
 *     itemCount: listModel.count
 *     columns: 3  // For grid navigation (omit for 1D lists)
 *     wrapAround: true
 *     enableCtrlPN: true
 *     enableTabNavigation: true
 *     enableHomeEnd: true
 *
 *     onNavigateUp: parent.currentIndex = newIndex
 *     onNavigateDown: parent.currentIndex = newIndex
 *     onNavigateLeft: parent.currentIndex = newIndex
 *     onNavigateRight: parent.currentIndex = newIndex
 *     onSelectCurrent: executeAction()
 *     onClose: manager.visible = false
 *   }
 *
 *   Keys.onPressed: event => navHandler.handleKeyPress(event)
 * }
 * ```
 *
 * NAVIGATION MODES:
 * - 1D List: Set columns = 1 (or omit), only Up/Down work
 * - 2D Grid: Set columns > 1, all four directions work
 */
QtObject {
  id: root

  /**
   * Current selection index
   */
  property int currentIndex: 0

  /**
   * Total number of navigable items
   */
  property int itemCount: 0

  /**
   * Number of columns in grid layout
   * Set to 1 (or omit) for 1D list navigation
   * Set to > 1 for 2D grid navigation
   */
  property int columns: 1

  /**
   * Enable wrap-around navigation
   * When true, navigating past the last item goes to first (and vice versa)
   */
  property bool wrapAround: false

  /**
   * Enable Ctrl+P (up) and Ctrl+N (down) navigation
   * Common in Emacs-style interfaces
   */
  property bool enableCtrlPN: false

  /**
   * Enable Tab/Shift+Tab navigation
   */
  property bool enableTabNavigation: false

  /**
   * Enable Home/End jump navigation
   */
  property bool enableHomeEnd: false

  /**
   * Emitted when user navigates up
   * @param newIndex - The calculated new index
   */
  signal navigateUp(int newIndex)

  /**
   * Emitted when user navigates down
   * @param newIndex - The calculated new index
   */
  signal navigateDown(int newIndex)

  /**
   * Emitted when user navigates left (grid only)
   * @param newIndex - The calculated new index
   */
  signal navigateLeft(int newIndex)

  /**
   * Emitted when user navigates right (grid only)
   * @param newIndex - The calculated new index
   */
  signal navigateRight(int newIndex)

  /**
   * Emitted when user presses Enter
   */
  signal selectCurrent()

  /**
   * Emitted when user presses Escape
   */
  signal close()

  /**
   * Main key press handler
   * Call this from your component's Keys.onPressed handler
   */
  function handleKeyPress(event) {
    // Escape key
    if (event.key === Qt.Key_Escape) {
      close()
      event.accepted = true
      return
    }

    // Enter key
    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      selectCurrent()
      event.accepted = true
      return
    }

    // Home key
    if (enableHomeEnd && event.key === Qt.Key_Home) {
      if (currentIndex !== 0) {
        navigateUp(0)
      }
      event.accepted = true
      return
    }

    // End key
    if (enableHomeEnd && event.key === Qt.Key_End) {
      const lastIndex = itemCount - 1
      if (currentIndex !== lastIndex) {
        navigateDown(lastIndex)
      }
      event.accepted = true
      return
    }

    // Tab navigation
    if (enableTabNavigation && event.key === Qt.Key_Tab) {
      const isShiftPressed = event.modifiers & Qt.ShiftModifier
      if (isShiftPressed) {
        // Shift+Tab: Previous
        const newIndex = calculatePrevious()
        if (newIndex !== currentIndex) {
          navigateUp(newIndex)
        }
      } else {
        // Tab: Next
        const newIndex = calculateNext()
        if (newIndex !== currentIndex) {
          navigateDown(newIndex)
        }
      }
      event.accepted = true
      return
    }

    // Up navigation (Arrow Up or Ctrl+P)
    if (event.key === Qt.Key_Up ||
        (enableCtrlPN && event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
      const newIndex = calculateUp()
      if (newIndex !== currentIndex) {
        navigateUp(newIndex)
      }
      event.accepted = true
      return
    }

    // Down navigation (Arrow Down or Ctrl+N)
    if (event.key === Qt.Key_Down ||
        (enableCtrlPN && event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
      const newIndex = calculateDown()
      if (newIndex !== currentIndex) {
        navigateDown(newIndex)
      }
      event.accepted = true
      return
    }

    // Left navigation (grid only)
    if (columns > 1 && event.key === Qt.Key_Left) {
      const newIndex = calculateLeft()
      if (newIndex !== currentIndex) {
        navigateLeft(newIndex)
      }
      event.accepted = true
      return
    }

    // Right navigation (grid only)
    if (columns > 1 && event.key === Qt.Key_Right) {
      const newIndex = calculateRight()
      if (newIndex !== currentIndex) {
        navigateRight(newIndex)
      }
      event.accepted = true
      return
    }
  }

  // ==========================================================================
  // NAVIGATION CALCULATION HELPERS
  // ==========================================================================

  function calculateUp() {
    if (columns <= 1) {
      // 1D list: Previous item
      return calculatePrevious()
    } else {
      // 2D grid: Move up one row
      const newIndex = currentIndex - columns
      if (newIndex >= 0) {
        return newIndex
      }
      if (wrapAround) {
        // Wrap to bottom row, same column
        const col = currentIndex % columns
        const lastRowStart = Math.floor((itemCount - 1) / columns) * columns
        return Math.min(lastRowStart + col, itemCount - 1)
      }
      return currentIndex
    }
  }

  function calculateDown() {
    if (columns <= 1) {
      // 1D list: Next item
      return calculateNext()
    } else {
      // 2D grid: Move down one row
      const newIndex = currentIndex + columns
      if (newIndex < itemCount) {
        return newIndex
      }
      if (wrapAround) {
        // Wrap to top row, same column
        const col = currentIndex % columns
        return col < itemCount ? col : currentIndex
      }
      return currentIndex
    }
  }

  function calculateLeft() {
    const newIndex = currentIndex - 1
    if (newIndex >= 0) {
      return newIndex
    }
    if (wrapAround) {
      return itemCount - 1
    }
    return currentIndex
  }

  function calculateRight() {
    const newIndex = currentIndex + 1
    if (newIndex < itemCount) {
      return newIndex
    }
    if (wrapAround) {
      return 0
    }
    return currentIndex
  }

  function calculatePrevious() {
    const newIndex = currentIndex - 1
    if (newIndex >= 0) {
      return newIndex
    }
    if (wrapAround) {
      return itemCount - 1
    }
    return currentIndex
  }

  function calculateNext() {
    const newIndex = currentIndex + 1
    if (newIndex < itemCount) {
      return newIndex
    }
    if (wrapAround) {
      return 0
    }
    return currentIndex
  }
}
