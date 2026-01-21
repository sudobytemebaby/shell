import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "../components/Input"

LazyLoader {
  id: loader
  
  required property var manager
  
  // Load when visible
  active: manager.visible
  
  PanelWindow {
    id: launcherWindow
    
    // Fill screen - the launcher box will be centered inside
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
    
    Component.onCompleted: {
      exclusiveZone = 0
    }
    
    // Focus management - handle keyboard shortcuts
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        } 
        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
          appListComponent.moveUp()
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          appListComponent.moveDown()
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          event.accepted = true
          
          const selectedApp = appListComponent.getCurrentApp()
          
          if (selectedApp) {
            try {
              selectedApp.execute()
              loader.manager.visible = false
            } catch (error) {
              try {
                Quickshell.execDetached({
                  command: selectedApp.command,
                  workingDirectory: selectedApp.workingDirectory || ""
                })
                loader.manager.visible = false
              } catch (fallbackError) {
                console.error("Fallback failed:", fallbackError)
              }
            }
          }
        }
      }
    }
    
    // Background overlay (same as menu)
    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
    }
    
    // Main container - Material 3 style
    Rectangle {
      id: background
      x: (parent.width - 540) / 2
      y: (parent.height - 600) / 2
      width: 540
      height: 600
      radius: 28
      color: Theme.surface_container_transparent_medium
      border.width: 1
      border.color: Qt.lighter(Theme.surface_container, 1.3)
      
      // Catch clicks on the launcher itself to prevent closing
      MouseArea {
        anchors.fill: parent
      }
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.padding.xl
        }
        spacing: Theme.spacing.md
        
        // ========== HEADER ==========
        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          spacing: Theme.spacing.sm
          
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding.xs
            text: "Applications"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
          
          // Close button
          Text {
            Layout.rightMargin: Theme.padding.sm
            text: "✕"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.lg
            font.family: Theme.typography.fontFamily

            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: loader.manager.visible = false
            }
          }
        }
        
        // ========== SEARCH BAR ==========
        SearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 48
          placeholder: "Search applications..."

          onSearchChanged: text => {
            loader.manager.searchText = text
          }
        }
        
        // ========== APP LIST ==========
        LauncherAppList {
          id: appListComponent
          Layout.fillWidth: true
          Layout.fillHeight: true
          
          searchTerm: loader.manager.searchText
          
          onAppLaunched: {
            loader.manager.visible = false
          }
        }
        
        // ========== FOOTER WITH HINT ==========
        Text {
          Layout.fillWidth: true
          text: "↑↓ / Ctrl+P/N Navigate • Enter Launch • Esc Close"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          horizontalAlignment: Text.AlignHCenter
          opacity: 0.7
        }
      }
    }
  }
}
