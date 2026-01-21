import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components/Input"
import "wallpaper_components" as Components

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
    
    property string searchText: ""
    property int selectedIndex: 0
    property var filteredWallpapers: []
    
    // ========================================================================
    // FILTERING LOGIC
    // ========================================================================
    
    // Filter wallpapers based on search (fuzzy matching)
    function updateFilteredWallpapers() {
      var search = wallpaperWindow.searchText.toLowerCase()
      
      if (!search) {
        // No search - show all
        wallpaperWindow.filteredWallpapers = loader.manager.wallpapers
      } else {
        // Fuzzy search
        var filtered = []
        
        for (var i = 0; i < loader.manager.wallpapers.length; i++) {
          var name = loader.manager.wallpapers[i].toLowerCase()
          
          // Simple fuzzy: check if all search chars appear in order
          var searchIdx = 0
          for (var j = 0; j < name.length && searchIdx < search.length; j++) {
            if (name[j] === search[searchIdx]) {
              searchIdx++
            }
          }
          
          // If we found all characters, include it
          if (searchIdx === search.length) {
            filtered.push(loader.manager.wallpapers[i])
          }
        }
        
        wallpaperWindow.filteredWallpapers = filtered
      }
      
      // Reset selection to first item
      wallpaperWindow.selectedIndex = 0
      
      // Position view at top
      if (gridView) {
        gridView.positionViewAtBeginning()
      }
    }
    
    // Update filtered list when wallpapers change
    Connections {
      target: loader.manager
      function onWallpapersChanged() {
        wallpaperWindow.updateFilteredWallpapers()
      }
    }
    
    // Initialize window and filtered wallpapers
    Component.onCompleted: {
      exclusiveZone = 0
      
      // Initialize filtered wallpapers if already loaded
      if (loader.manager.wallpapers.length > 0) {
        wallpaperWindow.updateFilteredWallpapers()
      }
    }
    
    // ========================================================================
    // KEYBOARD NAVIGATION
    // ========================================================================
    
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        // Calculate columns dynamically based on current width
        var columnsPerRow = gridView.columnsPerRow
        
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          // Select current wallpaper
          if (wallpaperWindow.selectedIndex >= 0 && 
              wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length) {
            var selected = wallpaperWindow.filteredWallpapers[wallpaperWindow.selectedIndex]
            loader.manager.setWallpaper(selected)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
          // Move up one row
          if (wallpaperWindow.selectedIndex >= columnsPerRow) {
            wallpaperWindow.selectedIndex -= columnsPerRow
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          } else if (wallpaperWindow.selectedIndex > 0) {
            // First row - just go to start
            wallpaperWindow.selectedIndex = 0
            gridView.positionViewAtIndex(0, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          // Move down one row
          var newIndex = wallpaperWindow.selectedIndex + columnsPerRow
          if (newIndex < wallpaperWindow.filteredWallpapers.length) {
            wallpaperWindow.selectedIndex = newIndex
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          } else if (wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length - 1) {
            // Last row - go to last item
            wallpaperWindow.selectedIndex = wallpaperWindow.filteredWallpapers.length - 1
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Left) {
          // Move left
          if (wallpaperWindow.selectedIndex > 0) {
            wallpaperWindow.selectedIndex--
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Right) {
          // Move right
          if (wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length - 1) {
            wallpaperWindow.selectedIndex++
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Home) {
          // Jump to first
          wallpaperWindow.selectedIndex = 0
          gridView.positionViewAtIndex(0, GridView.Beginning)
          event.accepted = true
        }
        else if (event.key === Qt.Key_End) {
          // Jump to last
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
    
    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
    }
    
    // ========================================================================
    // MAIN CONTAINER
    // ========================================================================
    
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
      
      // Prevent clicks on container from closing
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
          
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding.xs
            text: "Wallpapers"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
          
          // Thumbnail generation indicator
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radius.full
            color: Theme.primary_container
            visible: loader.manager.isGeneratingThumbs
            
            Text {
              anchors.centerIn: parent
              text: "󰄉"
              color: Theme.on_primary_container
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              
              RotationAnimation on rotation {
                running: loader.manager.isGeneratingThumbs
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 2000
              }
            }
          }
          
          // Refresh button
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
                loader.manager.refreshWallpapers()
              }
            }
          }
          
          // Close button
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
                loader.manager.visible = false
              }
            }
          }
        }
        
        // ====================================================================
        // SEARCH BAR
        // ====================================================================

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
        
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: loader.manager.isLoading
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md
            
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
                
                RotationAnimation on rotation {
                  running: loader.manager.isLoading
                  loops: Animation.Infinite
                  from: 0
                  to: 360
                  duration: 2000
                }
              }
            }
            
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
        
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: !loader.manager.isLoading && loader.manager.errorMessage !== ""
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md
            
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
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              Layout.maximumWidth: 600
              text: loader.manager.errorMessage
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
        
        Components.WallpaperGridView {
          id: gridView
          Layout.fillWidth: true
          Layout.fillHeight: true
          
          visible: !loader.manager.isLoading && loader.manager.errorMessage === ""
          
          wallpapers: wallpaperWindow.filteredWallpapers
          selectedIndex: wallpaperWindow.selectedIndex
          currentWallpaper: loader.manager.currentWallpaper
          wallpaperDir: loader.manager.wallpaperDir
          thumbnailDir: loader.manager.thumbnailDir
          
          onWallpaperSelected: filename => {
            loader.manager.setWallpaper(filename)
          }
          
          onIndexSelected: index => {
            wallpaperWindow.selectedIndex = index
          }
        }
        
        // ====================================================================
        // EMPTY STATE
        // ====================================================================
        
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: !loader.manager.isLoading && 
                   wallpaperWindow.filteredWallpapers.length === 0 && 
                   loader.manager.errorMessage === ""
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md
            
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
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: wallpaperWindow.searchText ? 
                    "Try a different search term" : 
                    "Add wallpapers to " + loader.manager.wallpaperDir
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
        
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.spacing.md
          visible: !loader.manager.isLoading && wallpaperWindow.filteredWallpapers.length > 0
          
          Text {
            Layout.fillWidth: true
            text: "↑↓←→ Navigate • Enter Select • Home/End Jump • Esc Close"
            color: Theme.on_surface_variant
            font.pixelSize: Theme.typography.sm
            font.family: Theme.typography.fontFamily
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.7
          }
          
          // Wallpaper count
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
