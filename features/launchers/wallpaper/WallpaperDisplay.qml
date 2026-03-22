import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components/Input"
import "../../../shared/components/Modals"
import "../../../shared/components/Navigation"
import "../../../shared/components/Utils"
import "wallpaper_components" as Components

/**
 * WallpaperDisplay
 *
 * UI display component for the wallpaper picker.
 *
 * ARCHITECTURE:
 * This component implements the Display pattern, handling all visual presentation
 * while delegating state management and logic to WallpaperManager.qml. The UI is
 * lazy-loaded for performance and uses Material 3 design principles.
 *
 * FEATURES:
 * - Full-screen overlay wallpaper picker interface
 * - Fuzzy search filtering for wallpaper names
 * - Comprehensive keyboard navigation (arrow keys, Home/End, Ctrl+P/N)
 * - Visual states: loading, error, empty, grid view
 * - Material 3 design with smooth animations
 *
 * KEYBOARD SHORTCUTS:
 * - Up/Down/Left/Right or Ctrl+P/N: Navigate through wallpapers
 * - Home/End: Jump to first/last item
 * - Enter: Select wallpaper
 * - Escape: Close picker
 * - Type to search: Filter wallpapers
 */
AnimatedLazyLoader {
  id: loader
  show: manager.visible

  required property var manager

  // Polished animation timings
  openDuration: 150
  closeDuration: 0
  openEasingType: Easing.OutCubic
  closeEasingType: Easing.InOutCubic

  PanelWindow {
    id: wallpaperWindow

    // Fill screen - wallpaper grid will be centered
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    visible: loader.active

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: loader.manager.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0

      // Initialize filtered wallpapers if already loaded
      // Null safety check before accessing wallpapers
      if (loader.manager && loader.manager.wallpapers && loader.manager.wallpapers.length > 0) {
        wallpaperWindow.updateFilteredWallpapers()
      }
    }

    // ========================================================================
    // SEARCH FILTER UTILITIES
    // ========================================================================

    SearchFilterMixin {
      id: filterMixin
    }

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
     * Uses SearchFilterMixin for consistent fuzzy matching across all pickers.
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
        console.warn("[WallpaperDisplay] Manager or wallpapers not available")
        wallpaperWindow.filteredWallpapers = []
        return
      }

      if (!wallpaperWindow.searchText) {
        // No search query - show all wallpapers
        wallpaperWindow.filteredWallpapers = loader.manager.wallpapers
      } else {
        // Apply fuzzy search using SearchFilterMixin for consistent behavior
        wallpaperWindow.filteredWallpapers = filterMixin.filterByFuzzy(
          loader.manager.wallpapers,
          wallpaperWindow.searchText
        )
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
    // KEYBOARD NAVIGATION
    // ========================================================================

    KeyboardNavigationHandler {
      id: navHandler
      currentIndex: wallpaperWindow.selectedIndex
      itemCount: wallpaperWindow.filteredWallpapers.length
      columns: gridView.columnsPerRow
      enableCtrlPN: true
      enableHomeEnd: true

      onNavigateUp: newIndex => {
        wallpaperWindow.selectedIndex = newIndex
        gridView.positionViewAtIndex(newIndex, GridView.Contain)
      }

      onNavigateDown: newIndex => {
        wallpaperWindow.selectedIndex = newIndex
        gridView.positionViewAtIndex(newIndex, GridView.Contain)
      }

      onNavigateLeft: newIndex => {
        wallpaperWindow.selectedIndex = newIndex
        gridView.positionViewAtIndex(newIndex, GridView.Contain)
      }

      onNavigateRight: newIndex => {
        wallpaperWindow.selectedIndex = newIndex
        gridView.positionViewAtIndex(newIndex, GridView.Contain)
      }

      onSelectCurrent: {
        if (wallpaperWindow.selectedIndex >= 0 &&
            wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length) {
          var selected = wallpaperWindow.filteredWallpapers[wallpaperWindow.selectedIndex]

          // Null safety check before calling manager method
          if (loader.manager) {
            loader.manager.setWallpaper(selected)
          }
        }
      }

      onClose: {
        if (loader.manager) {
          loader.manager.visible = false
        }
      }
    }

    contentItem {
      focus: true
      Keys.onPressed: event => navHandler.handleKeyPress(event)
    }
    
    // ========================================================================
    // BACKGROUND OVERLAY
    // ========================================================================

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

      layer.enabled: true
      layer.smooth: true
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#80000000"
        shadowBlur: 1.0
        shadowVerticalOffset: 6
        shadowHorizontalOffset: 0
        shadowOpacity: 1
        shadowScale: 1.02
      }

      radius: Theme.radius.xl

      color: Theme.surface_transparent_medium
      border.width: 0.5
      border.color: Theme.surface_container_high

      // Polished appearing animation: subtle scale + fade + slide
      scale: 0.95 + (loader.animationProgress * 0.05)
      opacity: loader.animationProgress

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

        ModalHeader {
          title: "Wallpapers"

          actionButtons: [
            {
              icon: "󰑐",
              tooltip: "Refresh wallpapers",
              onClicked: () => {
                if (loader.manager) {
                  loader.manager.refreshWallpapers()
                }
              }
            }
          ]

          onCloseClicked: {
            if (loader.manager) {
              loader.manager.visible = false
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
                text: "󰝲"
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

        // Keyboard shortcuts hint
        FooterHint {
          visible: {
            // Null safety check
            if (!loader.manager) return false
            return !loader.manager.isLoading && wallpaperWindow.filteredWallpapers.length > 0
          }
          hint: "Ctrl+P/N Navigate • Enter Select • Esc Close"
        }
      }
    }
  }
}
