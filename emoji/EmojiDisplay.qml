import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "../components"
import "../components/Input"
import "emoji_components" as Components

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.visible
  
  PanelWindow {
    id: emojiWindow
    
    // Fill screen - emoji picker will be centered
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
      console.log("[EmojiDisplay] Window loaded")
      exclusiveZone = 0
    }
    
    // Search and selection state
    property string searchText: ""
    property int selectedIndex: 0
    property var filteredEmojis: []
    
    // Filter emojis based on search and group
    function updateFilteredEmojis() {
      var search = emojiWindow.searchText.toLowerCase()
      var group = loader.manager.selectedGroup
      
      var filtered = []
      
      for (var i = 0; i < loader.manager.emojis.length; i++) {
        var emoji = loader.manager.emojis[i]
        
        // Filter by group if selected
        if (group && emoji.group !== group) {
          continue
        }
        
        // Filter by search
        if (search) {
          // Search in name and keywords
          if (!emoji.keywords.includes(search)) {
            continue
          }
        }
        
        filtered.push(emoji)
      }
      
      emojiWindow.filteredEmojis = filtered
      emojiWindow.selectedIndex = 0
      
      console.log("[EmojiDisplay] Filtered:", filtered.length, "emojis")
    }
    
    // Update filtered list when emojis or filters change
    Connections {
      target: loader.manager
      function onEmojisChanged() {
        emojiWindow.updateFilteredEmojis()
      }
      function onSelectedGroupChanged() {
        emojiWindow.updateFilteredEmojis()
      }
    }
    
    // Handle keyboard navigation
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          // Select current emoji
          if (emojiWindow.selectedIndex >= 0 && 
              emojiWindow.selectedIndex < emojiWindow.filteredEmojis.length) {
            var selected = emojiWindow.filteredEmojis[emojiWindow.selectedIndex]
            console.log("[EmojiDisplay] Selected via Enter:", selected.emoji)
            loader.manager.copyEmoji(selected.emoji)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up) {
          // Move up by columns (6 per row)
          if (emojiWindow.selectedIndex >= 6) {
            emojiWindow.selectedIndex -= 6
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down) {
          // Move down by columns (6 per row)
          if (emojiWindow.selectedIndex + 6 < emojiWindow.filteredEmojis.length) {
            emojiWindow.selectedIndex += 6
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Left) {
          // Move left
          if (emojiWindow.selectedIndex > 0) {
            emojiWindow.selectedIndex--
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Right) {
          // Move right
          if (emojiWindow.selectedIndex < emojiWindow.filteredEmojis.length - 1) {
            emojiWindow.selectedIndex++
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
      }
    }
    
    // Background overlay
    Rectangle {
      anchors.fill: parent
      color: Theme.scrim
      opacity: 0.2
      
      MouseArea {
        anchors.fill: parent
        onClicked: loader.manager.visible = false
      }
    }
    
    // Main container - centered with Material 3 styling
    Rectangle {
      id: container
      x: (parent.width - 700) / 2
      y: (parent.height - 600) / 2
      width: 700
      height: 600
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
        
        // ========== HEADER ==========
        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          spacing: Theme.spacing.sm
          
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding.xs
            text: "Emoji Picker"
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
          placeholder: "Search emojis..."
          debounceInterval: 200

          onSearchChanged: text => {
            emojiWindow.searchText = text
            emojiWindow.updateFilteredEmojis()
          }
        }
        
        // ========== GROUP FILTER ==========
        Components.EmojiGroupFilter {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          
          groups: loader.manager.emojiGroups
          selectedGroup: loader.manager.selectedGroup
          
          onGroupSelected: group => {
            loader.manager.selectedGroup = group
          }
        }
        
        // ========== LOADING STATE ==========
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
              }
            }
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: "Loading emojis..."
              color: Theme.on_surface
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              font.weight: Theme.typography.weightMedium
              opacity: 0.8
            }
          }
        }
        
        // ========== ERROR STATE ==========
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
        
        // ========== EMOJI GRID ==========
        Components.EmojiGridView {
          id: gridView
          Layout.fillWidth: true
          Layout.fillHeight: true
          
          visible: !loader.manager.isLoading && loader.manager.errorMessage === ""
          
          emojis: emojiWindow.filteredEmojis
          selectedIndex: emojiWindow.selectedIndex
          
          onEmojiSelected: emoji => {
            console.log("[EmojiDisplay] Selected via click:", emoji)
            loader.manager.copyEmoji(emoji)
          }
          
          onIndexSelected: index => {
            emojiWindow.selectedIndex = index
          }
        }
        
        // ========== EMPTY STATE ==========
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: !loader.manager.isLoading && 
                   emojiWindow.filteredEmojis.length === 0 && 
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
                text: "󱚣"
                color: Theme.on_surface_variant
                font.pixelSize: Theme.typography.xxxl
                font.family: Theme.typography.fontFamily
                opacity: 0.6
              }
            }
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: emojiWindow.searchText ? 
                    "No emojis found" : 
                    "No emojis available"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              font.weight: Theme.typography.weightMedium
              opacity: 0.8
            }
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: emojiWindow.searchText ? 
                    "Try a different search term" : 
                    "Check emoji data file"
              color: Theme.on_surface_variant
              font.pixelSize: Theme.typography.sm
              font.family: Theme.typography.fontFamily
              opacity: 0.6
            }
          }
        }
        
        // ========== FOOTER WITH HINT ==========
        Text {
          Layout.fillWidth: true
          text: "↑↓←→ Navigate • Enter Copy • Esc Close"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          horizontalAlignment: Text.AlignHCenter
          opacity: 0.7
          visible: !loader.manager.isLoading && emojiWindow.filteredEmojis.length > 0
        }
      }
    }
  }
}
