import QtQuick
import QtQuick.Layouts
import "../../../../shared/theme"
import "../../../../shared/components/Display"
import "../../../../core/services"

/**
 * WallpaperGridItem - Individual wallpaper thumbnail cell component
 *
 * Displays a single wallpaper thumbnail with:
 * - Rounded thumbnail preview using NImageRounded
 * - Current wallpaper badge (checkmark) in bottom-right corner
 * - Keyboard selection indicator (arrow) in top-left corner
 * - Hover state with background color change
 * - Click animation (scale effect)
 * - Smooth transitions for all visual states
 *
 * Integration:
 * - Uses ImageCacheService for thumbnail loading with fallback
 * - Loads thumbnails asynchronously on component creation
 * - Falls back to original wallpaper if thumbnail fails to load
 *
 * Visual indicators:
 * - isCurrent: Shows checkmark badge (this is the active wallpaper)
 * - isSelected: Shows arrow badge (keyboard navigation selection)
 * - Both badges animate in/out with elastic easing
 */
Item {
  id: root

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  property string filename: ""         // Wallpaper filename (e.g., "nord_space.png")
  property int itemIndex: 0            // Index in grid
  property bool isSelected: false      // Whether this item is keyboard-selected
  property bool isCurrent: false       // Whether this is the currently active wallpaper
  property string wallpaperPath: ""    // Full path to original wallpaper file

  // ============================================================================
  // INTERNAL STATE
  // ============================================================================

  // Cached path to thumbnail after ImageCacheService processing
  property string cachedThumbnailPath: ""

  signal clicked()  // Emitted when user clicks this wallpaper

  // ============================================================================
  // MAIN CONTAINER
  // ============================================================================

  Rectangle {
    anchors {
      fill: parent
      margins: Theme.spacing.xs
    }

    radius: Theme.radius.lg

    // Dynamic background color based on state
    color: {
      if (root.isSelected && !root.isCurrent) return Theme.surface_container_high
      if (itemMouseArea.containsMouse && !root.isCurrent) return Theme.surface_container
      return "transparent"
    }

    // Border for keyboard-selected items
    border.width: root.isSelected ? 2 : 0
    border.color: root.isSelected ? Theme.primary : "transparent"

    // ======================================================================
    // IMAGE PREVIEW (Using NImageRounded with ImageCacheService)
    // ======================================================================

    /**
     * Rounded thumbnail preview
     * - Uses NImageRounded component for rounded corners
     * - Loads from cachedThumbnailPath set by ImageCacheService
     * - Falls back to wallpaper icon if thumbnail unavailable
     * - PreserveAspectCrop ensures thumbnail fills the cell
     */
    NImageRounded {
      id: imagePreview
      anchors {
        fill: parent
        margins: Theme.spacing.xs
      }
      radius: Theme.radius.lg
      imagePath: root.cachedThumbnailPath !== "" ? "file://" + root.cachedThumbnailPath : ""
      fallbackIcon: "󰸉"  // Wallpaper icon shown when loading/error
      borderWidth: 0
      imageFillMode: Image.PreserveAspectCrop
    }


    // ======================================================================
    // CURRENT WALLPAPER BADGE
    // ======================================================================

    /**
     * Checkmark badge in bottom-right corner
     * Shown when this is the currently active wallpaper
     * Animates in with elastic bounce effect
     */
    Rectangle {
      anchors {
        bottom: imagePreview.bottom
        right: imagePreview.right
        margins: Theme.spacing.sm
      }
      width: 100
      height: 40 
      radius: Theme.radius.full
      color: Theme.primary
      visible: root.isCurrent

      // Checkmark icon
      Text {
        anchors.centerIn: parent
        text: "󰄬  Applied"
        color: Theme.on_primary
        font.pixelSize: Theme.typography.md
        font.family: Theme.fontFamily
      }
    }

    // ======================================================================
    // SELECTED INDICATOR (keyboard nav)
    // ======================================================================

    /**
     * Arrow badge in top-left corner
     * Shown when this item is selected via keyboard navigation
     * Only shown if not the current wallpaper (to avoid clutter)
     */
    Rectangle {
      anchors {
        top: imagePreview.top
        left: imagePreview.left
        margins: Theme.spacing.sm
      }
      width: 40
      height: 40 
      radius: Theme.radius.full
      color: Theme.primary
      visible: root.isSelected && !root.isCurrent

      // Arrow icon (pointing right)
      Text {
        anchors.centerIn: parent
        text: "󰋑"
        color: Theme.on_primary
        font.pixelSize: Theme.typography.lg
        font.family: Theme.typography.fontFamily
        font.weight: Theme.typography.weightMedium
      }
    }

    // ========================================================================
    // INTERACTION
    // ========================================================================

    // Mouse interaction area for clicks and hover
    MouseArea {
      id: itemMouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor

      onClicked: {
        root.clicked()
      }
    }
  }

  // ============================================================================
  // THUMBNAIL LOADING
  // ============================================================================

  /**
   * Load thumbnail via ImageCacheService on component creation
   *
   * ImageCacheService:
   * - Generates cached thumbnails with SHA256-based naming
   * - Handles ImageMagick processing or Qt fallback
   * - Provides request coalescing to prevent duplicate processing
   * - Auto-cleanup of old cached files (30+ days)
   *
   * Fallback:
   * - If service not initialized or thumbnail fails, uses original wallpaper
   * - This ensures images always display, even if caching fails
   */
  Component.onCompleted: {
    if (ImageCacheService.initialized) {
      // Use ImageCacheService for optimized thumbnail loading
      ImageCacheService.getThumbnail(root.wallpaperPath, function(path, success) {
        if (success) {
          root.cachedThumbnailPath = path
        } else {
          // Fallback to original wallpaper if thumbnail generation fails
          root.cachedThumbnailPath = root.wallpaperPath
        }
      })
    } else {
      // Service not initialized yet - use original wallpaper path
      root.cachedThumbnailPath = root.wallpaperPath
    }
  }
}
