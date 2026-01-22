import QtQuick
import "../../../../shared/theme"

/**
 * WallpaperGridView - Scrollable grid container for wallpaper thumbnails
 *
 * This component extends GridView with:
 * - Dynamic column calculation based on window width
 * - Performance optimizations (cacheBuffer, displayMargins)
 * - Safe column calculation with Math.max(1, ...) to prevent division by zero
 * - Smooth scrolling configuration
 * - Auto-positioning based on selected index
 * - Delegate for rendering individual wallpaper items
 *
 * Performance features:
 * - cacheBuffer: Pre-renders 3 rows (600px) above/below viewport
 * - displayMargins: Keeps 2 rows (400px) in memory at boundaries
 * - Smooth flick deceleration for natural scrolling feel
 */
GridView {
  id: gridView

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  property var wallpapers: []             // Array of wallpaper filenames to display
  property int selectedIndex: 0            // Currently selected wallpaper index (keyboard nav)
  property string currentWallpaper: ""     // Currently active wallpaper filename
  property string wallpaperDir: ""         // Path to wallpaper directory

  signal wallpaperSelected(string filename)  // Emitted when user clicks a wallpaper
  signal indexSelected(int index)            // Emitted when user clicks (for keyboard nav sync)

  // ============================================================================
  // DYNAMIC COLUMN CALCULATION
  // ============================================================================

  /**
   * Calculate number of columns based on available width
   * Safety check: Math.max(1, ...) ensures at least 1 column to prevent division by zero
   *
   * With cellWidth=280, this gives:
   * - 900px width  = 3 columns
   * - 1200px width = 4 columns
   * - 1680px width = 6 columns
   */
  readonly property int columnsPerRow: Math.max(1, Math.floor(width / cellWidth))

  // ============================================================================
  // GRID CONFIGURATION
  // ============================================================================

  clip: true  // Prevent items from rendering outside bounds

  // Cell dimensions (width x height in pixels)
  cellWidth: 280
  cellHeight: 200

  // Data source - array of wallpaper filenames
  model: wallpapers

  // Track current selection for keyboard navigation
  currentIndex: selectedIndex

  // ============================================================================
  // SCROLLING CONFIGURATION
  // ============================================================================

  // Smooth scrolling parameters
  maximumFlickVelocity: 2000    // Max scroll speed (pixels/second)
  flickDeceleration: 1500        // Deceleration rate for natural feel

  // ============================================================================
  // PERFORMANCE OPTIMIZATIONS
  // ============================================================================

  /**
   * cacheBuffer: Extra pixels to render outside viewport
   * 3 rows (600px) = smooth scrolling without visible item creation
   */
  cacheBuffer: cellHeight * 3  // 600px

  /**
   * displayMargins: Keep rendered items in memory at boundaries
   * Prevents flickering when scrolling back to recently viewed areas
   */
  displayMarginBeginning: cellHeight * 2  // 400px above viewport
  displayMarginEnd: cellHeight * 2         // 400px below viewport

  // ============================================================================
  // SELECTION HANDLING
  // ============================================================================

  /**
   * Auto-scroll to keep selected item visible when selection changes
   * Used for keyboard navigation to ensure selected item is always in view
   */
  onSelectedIndexChanged: {
    positionViewAtIndex(selectedIndex, GridView.Contain)
  }

  // ============================================================================
  // DELEGATE
  // ============================================================================

  /**
   * Delegate for rendering each wallpaper item
   * Uses WallpaperGridItem component for individual thumbnails
   */
  delegate: WallpaperGridItem {
    // Required properties from model (QML 6+ syntax)
    required property string modelData
    required property int index

    // Set item dimensions to match grid cell size
    width: gridView.cellWidth
    height: gridView.cellHeight

    // Pass data to item component
    filename: modelData
    itemIndex: index
    isSelected: index === gridView.selectedIndex          // Keyboard navigation indicator
    isCurrent: gridView.currentWallpaper === modelData    // Current wallpaper badge
    wallpaperPath: gridView.wallpaperDir + "/" + modelData

    // Handle user clicks
    onClicked: {
      // Update selection index (for keyboard nav)
      gridView.indexSelected(index)

      // Notify parent to apply wallpaper
      gridView.wallpaperSelected(modelData)
    }
  }

  // ============================================================================
  // DEBUG LOGGING
  // ============================================================================

  Component.onCompleted: {
    console.log("[WallpaperGridView] Initialized")
    console.log("[WallpaperGridView] Cell size:", cellWidth, "x", cellHeight)
    console.log("[WallpaperGridView] Columns:", columnsPerRow)
    console.log("[WallpaperGridView] Cache buffer:", cacheBuffer)
  }
}
