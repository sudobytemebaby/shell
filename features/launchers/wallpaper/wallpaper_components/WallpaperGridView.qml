import QtQuick
import "../../../../shared/theme"

GridView {
  id: gridView
  
  // ============================================================================
  // PUBLIC API
  // ============================================================================
  
  property var wallpapers: []
  property int selectedIndex: 0
  property string currentWallpaper: ""
  property string wallpaperDir: ""
  property string thumbnailDir: ""
  
  signal wallpaperSelected(string filename)
  signal indexSelected(int index)
  
  // ============================================================================
  // DYNAMIC COLUMN CALCULATION
  // ============================================================================
  
  // Calculate columns based on available width
  readonly property int columnsPerRow: Math.max(1, Math.floor(width / cellWidth))
  
  // ============================================================================
  // GRID CONFIGURATION
  // ============================================================================
  
  clip: true
  
  cellWidth: 280
  cellHeight: 200
  
  model: wallpapers
  
  currentIndex: selectedIndex
  
  // Smooth scrolling
  maximumFlickVelocity: 2000
  flickDeceleration: 1500
  
  // Optimize performance
  cacheBuffer: cellHeight * 3  // Cache 3 rows above/below
  displayMarginBeginning: cellHeight * 2
  displayMarginEnd: cellHeight * 2
  
  // ============================================================================
  // SELECTION HANDLING
  // ============================================================================
  
  // Watch for selectedIndex changes and position view accordingly
  onSelectedIndexChanged: {
    positionViewAtIndex(selectedIndex, GridView.Contain)
  }
  
  // ============================================================================
  // DELEGATE
  // ============================================================================
  
  delegate: WallpaperGridItem {
    required property string modelData
    required property int index
    
    width: gridView.cellWidth
    height: gridView.cellHeight
    
    filename: modelData
    itemIndex: index
    isSelected: index === gridView.selectedIndex
    isCurrent: gridView.currentWallpaper === modelData
    wallpaperPath: gridView.wallpaperDir + "/" + modelData
    thumbnailPath: gridView.thumbnailDir + "/" + modelData.replace(/\.[^/.]+$/, "") + ".jpg"
    
    onClicked: {
      gridView.indexSelected(index)
      gridView.wallpaperSelected(modelData)
    }
  }
  
  // ============================================================================
  // DEBUG INFO (can be removed in production)
  // ============================================================================
  
  Component.onCompleted: {
    console.log("[WallpaperGridView] Initialized")
    console.log("[WallpaperGridView] Cell size:", cellWidth, "x", cellHeight)
    console.log("[WallpaperGridView] Columns:", columnsPerRow)
    console.log("[WallpaperGridView] Cache buffer:", cacheBuffer)
  }
}
