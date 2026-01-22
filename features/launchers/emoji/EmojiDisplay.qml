import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components"
import "../../../shared/components/Input"
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
      // Initialize filtered model with all emojis
      emojiWindow.performFilter()
    }

    // Search and selection state
    property string searchText: ""
    property int selectedIndex: 0

    // Calculate columns dynamically based on grid width
    readonly property int columns: Math.floor(gridView.width / gridView.cellWidth)

    // Filtered ListModel - only contains matching emojis
    ListModel {
      id: filteredModel
    }

    // Debounce timer for filter updates
    Timer {
      id: filterTimer
      interval: 30
      repeat: false
      onTriggered: emojiWindow.performFilter()
    }

    function updateFilter() {
      filterTimer.restart()
    }

    function performFilter() {
      var search = emojiWindow.searchText.toLowerCase()
      var group = loader.manager.selectedGroup
      var sourceModel = loader.manager.emojiModel

      filteredModel.clear()

      // If no filters, copy all
      if (!search && !group) {
        for (var i = 0; i < sourceModel.count; i++) {
          var item = sourceModel.get(i)
          filteredModel.append({
            emoji: item.emoji,
            name: item.name,
            slug: item.slug,
            group: item.group,
            keywords: item.keywords
          })
        }
      } else {
        // Apply filters
        for (var i = 0; i < sourceModel.count; i++) {
          var item = sourceModel.get(i)

          var matches = true
          if (group && item.group !== group) {
            matches = false
          } else if (search && item.keywords.indexOf(search) === -1) {
            matches = false
          }

          if (matches) {
            filteredModel.append({
              emoji: item.emoji,
              name: item.name,
              slug: item.slug,
              group: item.group,
              keywords: item.keywords
            })
          }
        }
      }

      emojiWindow.selectedIndex = 0
    }

    // Update filter when search or group changes
    Connections {
      target: loader.manager
      function onSelectedGroupChanged() {
        emojiWindow.updateFilter()
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
          // Select current emoji at current index
          if (emojiWindow.selectedIndex >= 0 &&
              emojiWindow.selectedIndex < filteredModel.count) {
            var emoji = filteredModel.get(emojiWindow.selectedIndex)
            console.log("[EmojiDisplay] Selected via Enter:", emoji.emoji)
            loader.manager.copyEmoji(emoji.emoji)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up) {
          // Move up by calculated columns
          var newIndex = emojiWindow.selectedIndex - emojiWindow.columns
          if (newIndex >= 0) {
            emojiWindow.selectedIndex = newIndex
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down) {
          // Move down by calculated columns
          var newIndex = emojiWindow.selectedIndex + emojiWindow.columns
          if (newIndex < filteredModel.count) {
            emojiWindow.selectedIndex = newIndex
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
          if (emojiWindow.selectedIndex < filteredModel.count - 1) {
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
      x: (parent.width - 460) / 2
      y: (parent.height - 550) / 2
      width: 460
      height: 550
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
            emojiWindow.updateFilter()
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
          visible: loader.manager.emojiModel.count === 0 && loader.manager.errorMessage === ""
          
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
          visible: loader.manager.errorMessage !== ""
          
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
        GridView {
          id: gridView
          Layout.fillWidth: true
          Layout.fillHeight: true

          visible: loader.manager.emojiModel.count > 0 && loader.manager.errorMessage === ""

          clip: true
          cellWidth: 70
          cellHeight: 70

          model: filteredModel
          currentIndex: emojiWindow.selectedIndex

          maximumFlickVelocity: 2000
          flickDeceleration: 1500

          delegate: Components.EmojiGridItem {
            width: gridView.cellWidth
            height: gridView.cellHeight

            emoji: model.emoji
            name: model.name
            itemIndex: model.index
            isSelected: model.index === emojiWindow.selectedIndex

            onClicked: {
              emojiWindow.selectedIndex = model.index
              console.log("[EmojiDisplay] Selected via click:", model.emoji)
              loader.manager.copyEmoji(model.emoji)
            }
          }
        }
        
        // ========== EMPTY STATE ==========
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: loader.manager.emojiModel.count > 0 &&
                   filteredModel.count === 0 &&
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
          visible: filteredModel.count > 0
        }
      }
    }
  }
}
