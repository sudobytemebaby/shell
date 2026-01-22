import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components/Input"
import "wallpaper_components" as Components

/**
 * WallpaperGrid - Main UI display for the wallpaper picker
 *
 * This component provides:
 * - Full-screen overlay wallpaper picker interface
 * - Fuzzy search filtering for wallpaper names
 * - Comprehensive keyboard navigation (arrow keys, Home/End, Ctrl+P/N)
 * - Visual states: loading, error, empty, grid view
 * - Material 3 design with smooth animations
 *
 * Architecture:
 * - LazyLoader ensures UI only loads when visible
 * - WallpaperManager handles data and business logic
 * - This component is purely presentational
 * - Uses fuzzy matching algorithm for search (allows "out of order" character matches)
 */
LazyLoader {
  id: loader

  required property var manager

  active: manager.visible

  PanelWindow {
    id: wallpaperWindow

    // Fill screen - wallpaper grid will be centered
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"
    mask: null

    // ========================================================================
    // SEARCH AND SELECTION STATE
    // ========================================================================

    property string searchText: ""              // Current search query
    property int selectedIndex: 0                // Currently selected wallpaper index (keyboard navigation)
    property var filteredWallpapers: []          // Filtered list based on search query

    // ========================================================================
    // FILTERING LOGIC
    // ========================================================================

    /**
     * Filter wallpapers based on search query using fuzzy matching
     *
     * Fuzzy matching allows characters to appear in order but not necessarily
     * consecutively. For example, "nod" would match "nord_outerspace.png"
     *
     * This function:
     * - Updates filteredWallpapers array with matching results
     * - Resets selection to first item
     * - Scrolls grid view to top
     */
    function updateFilteredWallpapers() {
      // Null safety check - prevent crashes if manager is not available
      if (!loader.manager || !loader.manager.wallpapers) {
        console.warn("[WallpaperGrid] Manager or wallpapers not available")
        wallpaperWindow.filteredWallpapers = []
        return
      }

      var search = wallpaperWindow.searchText.toLowerCase()

      if (!search) {
        // No search query - show all wallpapers
        wallpaperWindow.filteredWallpapers = loader.manager.wallpapers
      } else {
        // Apply fuzzy search algorithm
        var filtered = []

        for (var i = 0; i < loader.manager.wallpapers.length; i++) {
          var name = loader.manager.wallpapers[i].toLowerCase()

          // Fuzzy matching: check if all search characters appear in order
          // Example: search "nrd" matches "nord_space.png"
          var searchIdx = 0
          for (var j = 0; j < name.length && searchIdx < search.length; j++) {
            if (name[j] === search[searchIdx]) {
              searchIdx++
            }
          }

          // If we found all search characters in order, include this wallpaper
          if (searchIdx === search.length) {
            filtered.push(loader.manager.wallpapers[i])
          }
        }

        wallpaperWindow.filteredWallpapers = filtered
      }

      // Reset selection to first item when filter changes
      wallpaperWindow.selectedIndex = 0

      // Scroll grid view back to top
      if (gridView) {
        gridView.positionViewAtBeginning()
      }
    }

    // ========================================================================
    // WALLPAPER LIST CHANGE HANDLER
    // ========================================================================

    // Update filtered list when wallpapers are refreshed from manager
    Connections {
      target: loader.manager
      function onWallpapersChanged() {
        wallpaperWindow.updateFilteredWallpapers()
      }
    }

    // ========================================================================
    // INITIALIZATION
    // ========================================================================

    // Initialize window and perform initial filtering
    Component.onCompleted: {
      exclusiveZone = 0

      // Initialize filtered wallpapers if already loaded
      // Null safety check before accessing wallpapers
      if (loader.manager && loader.manager.wallpapers && loader.manager.wallpapers.length > 0) {
        wallpaperWindow.updateFilteredWallpapers()
      }
    }
    
    // ========================================================================
    // KEYBOARD NAVIGATION
    // ========================================================================

    contentItem {
      focus: true

      Keys.onPressed: event => {
        // Calculate columns dynamically based on current grid width
        // This is used for up/down navigation to move by full rows
        var columnsPerRow = gridView.columnsPerRow

        // Close picker on Escape
        if (event.key === Qt.Key_Escape) {
          // Null safety check
          if (loader.manager) {
            loader.manager.visible = false
          }
          event.accepted = true
        }
        // Select and apply current wallpaper on Enter
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          if (wallpaperWindow.selectedIndex >= 0 &&
              wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length) {
            var selected = wallpaperWindow.filteredWallpapers[wallpaperWindow.selectedIndex]

            // Null safety check before calling manager method
            if (loader.manager) {
              loader.manager.setWallpaper(selected)
            }
          }
          event.accepted = true
        }
        // Navigate up by one row (also Ctrl+P for Emacs-style navigation)
        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
          if (wallpaperWindow.selectedIndex >= columnsPerRow) {
            // Move up one full row
            wallpaperWindow.selectedIndex -= columnsPerRow
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          } else if (wallpaperWindow.selectedIndex > 0) {
            // Already in first row - jump to first item
            wallpaperWindow.selectedIndex = 0
            gridView.positionViewAtIndex(0, GridView.Contain)
          }
          event.accepted = true
        }
        // Navigate down by one row (also Ctrl+N for Emacs-style navigation)
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          var newIndex = wallpaperWindow.selectedIndex + columnsPerRow
          if (newIndex < wallpaperWindow.filteredWallpapers.length) {
            // Move down one full row
            wallpaperWindow.selectedIndex = newIndex
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          } else if (wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length - 1) {
            // Already in last row - jump to last item
            wallpaperWindow.selectedIndex = wallpaperWindow.filteredWallpapers.length - 1
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        // Navigate left
        else if (event.key === Qt.Key_Left) {
          if (wallpaperWindow.selectedIndex > 0) {
            wallpaperWindow.selectedIndex--
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        // Navigate right
        else if (event.key === Qt.Key_Right) {
          if (wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length - 1) {
            wallpaperWindow.selectedIndex++
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        // Jump to first wallpaper
        else if (event.key === Qt.Key_Home) {
          wallpaperWindow.selectedIndex = 0
          gridView.positionViewAtIndex(0, GridView.Beginning)
          event.accepted = true
        }
        // Jump to last wallpaper
        else if (event.key === Qt.Key_End) {
          if (wallpaperWindow.filteredWallpapers.length > 0) {
            wallpaperWindow.selectedIndex = wallpaperWindow.filteredWallpapers.length - 1
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.End)
          }
          event.accepted = true
        }
      }
    }
    
    // ========================================================================
    // BACKGROUND OVERLAY
    // ========================================================================

    // Semi-transparent background - clicking it closes the picker
    MouseArea {
      anchors.fill: parent
      onClicked: {
        // Null safety check
        if (loader.manager) {
          loader.manager.visible = false
        }
      }
    }

    // ========================================================================
    // MAIN CONTAINER
    // ========================================================================

    // Centered modal dialog with Material 3 styling
    Rectangle {
      id: container
      x: (parent.width - 900) / 2
      y: (parent.height - 700) / 2
      width: 900
      height: 700
      radius: 28
      color: Theme.surface_container_transparent_medium
      border.width: 1
      border.color: Qt.lighter(Theme.surface_container, 1.3)

      // Prevent clicks on container from propagating to background (which would close picker)
      MouseArea {
        anchors.fill: parent
      }
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.padding.xl
        }
        spacing: Theme.spacing.md
        
        // ====================================================================
        // HEADER
        // ====================================================================

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          spacing: Theme.spacing.sm

          // Title text
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding.xs
            text: "Wallpapers"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }

          // Refresh button (rescans wallpaper directory)
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radius.full
            color: refreshMouseArea.containsMouse ? Theme.surface_container_high : "transparent"

            Text {
              anchors.centerIn: parent
              text: "󰑐"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.lg
              font.family: Theme.typography.fontFamily
            }

            MouseArea {
              id: refreshMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor

              onClicked: {
                // Null safety check
                if (loader.manager) {
                  loader.manager.refreshWallpapers()
                }
              }
            }
          }

          // Close button (X icon)
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.rightMargin: Theme.padding.xs
            radius: Theme.radius.full
            color: closeMouseArea.containsMouse ? Theme.surface_container_high : "transparent"

            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.lg
              font.family: Theme.typography.fontFamily
            }

            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor

              onClicked: {
                // Null safety check
                if (loader.manager) {
                  loader.manager.visible = false
                }
              }
            }
          }
        }
        
        // ====================================================================
        // SEARCH BAR
        // ====================================================================

        // Fuzzy search input with 200ms debouncing
        SearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 48
          placeholder: "Search wallpapers..."
          debounceInterval: 200

          onSearchChanged: text => {
            wallpaperWindow.searchText = text
            wallpaperWindow.updateFilteredWallpapers()
          }
        }

        // ====================================================================
        // LOADING STATE
        // ====================================================================

        // Shown when wallpapers are being scanned from directory
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: loader.manager ? loader.manager.isLoading : false
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md

            // Loading spinner icon
            Rectangle {
              Layout.alignment: Qt.AlignHCenter
              Layout.preferredWidth: 64
              Layout.preferredHeight: 64
              radius: Theme.radius.full
              color: Theme.surface_container_high

              Text {
                anchors.centerIn: parent
                text: "󰄉"
                color: Theme.on_surface_variant
                font.pixelSize: Theme.typography.xxxl
                font.family: Theme.typography.fontFamily
                opacity: 0.6

                // Continuous rotation animation
                RotationAnimation on rotation {
                  running: loader.manager ? loader.manager.isLoading : false
                  loops: Animation.Infinite
                  from: 0
                  to: 360
                  duration: 2000
                }
              }
            }

            // Loading message
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: "Loading wallpapers..."
              color: Theme.on_surface
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              font.weight: Theme.typography.weightMedium
              opacity: 0.8
            }
          }
        }

        // ====================================================================
        // ERROR STATE
        // ====================================================================

        // Shown when there's an error loading wallpapers
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: {
            // Null safety check
            if (!loader.manager) return false
            return !loader.manager.isLoading && loader.manager.errorMessage !== ""
          }
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md

            // Error icon
            Rectangle {
              Layout.alignment: Qt.AlignHCenter
              Layout.preferredWidth: 64
              Layout.preferredHeight: 64
              radius: Theme.radius.full
              color: Theme.error_container

              Text {
                anchors.centerIn: parent
                text: "󰀪"
                color: Theme.on_error_container
                font.pixelSize: Theme.typography.xxxl
                font.family: Theme.typography.fontFamily
              }
            }

            // Error message text
            Text {
              Layout.alignment: Qt.AlignHCenter
              Layout.maximumWidth: 600
              text: loader.manager ? loader.manager.errorMessage : ""
              color: Theme.error
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              horizontalAlignment: Text.AlignHCenter
              wrapMode: Text.WordWrap
            }
          }
        }

        // ====================================================================
        // WALLPAPER GRID
        // ====================================================================

        // Main scrollable grid of wallpaper thumbnails
        Components.WallpaperGridView {
          id: gridView
          Layout.fillWidth: true
          Layout.fillHeight: true

          visible: {
            // Null safety check
            if (!loader.manager) return false
            return !loader.manager.isLoading && loader.manager.errorMessage === ""
          }

          // Pass data and state to grid component
          wallpapers: wallpaperWindow.filteredWallpapers
          selectedIndex: wallpaperWindow.selectedIndex
          currentWallpaper: loader.manager ? loader.manager.currentWallpaper : ""
          wallpaperDir: loader.manager ? loader.manager.wallpaperDir : ""

          // Handle wallpaper selection
          onWallpaperSelected: filename => {
            // Null safety check
            if (loader.manager) {
              loader.manager.setWallpaper(filename)
            }
          }

          // Update selected index (for keyboard navigation sync)
          onIndexSelected: index => {
            wallpaperWindow.selectedIndex = index
          }
        }

        // ====================================================================
        // EMPTY STATE
        // ====================================================================

        // Shown when filter/search returns no results
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: {
            // Null safety check
            if (!loader.manager) return false
            return !loader.manager.isLoading &&
                   wallpaperWindow.filteredWallpapers.length === 0 &&
                   loader.manager.errorMessage === ""
          }
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md

            // Empty state icon
            Rectangle {
              Layout.alignment: Qt.AlignHCenter
              Layout.preferredWidth: 64
              Layout.preferredHeight: 64
              radius: Theme.radius.full
              color: Theme.surface_container_high

              Text {
                anchors.centerIn: parent
                text: "󰸉"
                color: Theme.on_surface_variant
                font.pixelSize: Theme.typography.xxxl
                font.family: Theme.typography.fontFamily
                opacity: 0.6
              }
            }

            // Primary message (changes based on whether search is active)
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: wallpaperWindow.searchText ?
                    "No wallpapers found" :
                    "No wallpapers available"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              font.weight: Theme.typography.weightMedium
              opacity: 0.8
            }

            // Secondary hint message
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: wallpaperWindow.searchText ?
                    "Try a different search term" :
                    "Add wallpapers to " + (loader.manager ? loader.manager.wallpaperDir : "")
              color: Theme.on_surface_variant
              font.pixelSize: Theme.typography.sm
              font.family: Theme.typography.fontFamily
              opacity: 0.6
            }
          }
        }

        // ====================================================================
        // FOOTER
        // ====================================================================

        // Keyboard shortcuts hint and wallpaper count
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.spacing.md
          visible: {
            // Null safety check
            if (!loader.manager) return false
            return !loader.manager.isLoading && wallpaperWindow.filteredWallpapers.length > 0
          }

          // Keyboard shortcuts hint
          Text {
            Layout.fillWidth: true
            text: "↑↓←→ Navigate • Enter Select • Home/End Jump • Esc Close"
            color: Theme.on_surface_variant
            font.pixelSize: Theme.typography.sm
            font.family: Theme.typography.fontFamily
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.7
          }

          // Wallpaper count indicator
          Text {
            text: wallpaperWindow.filteredWallpapers.length + " wallpaper" +
                  (wallpaperWindow.filteredWallpapers.length === 1 ? "" : "s")
            color: Theme.on_surface_variant
            font.pixelSize: Theme.typography.sm
            font.family: Theme.typography.fontFamily
            opacity: 0.7
          }
        }
      }
    }
  }
}
