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
    }

    // ========== STATE PROPERTIES ==========

    // Current search text (bound to SearchBar input)
    property string searchText: ""

    // Currently selected emoji index for keyboard navigation
    property int selectedIndex: 0

    // Calculate columns dynamically based on grid width
    // Safety check: ensure at least 1 column to prevent division by zero
    readonly property int columns: Math.max(1, Math.floor(gridView.width / gridView.cellWidth))

    // ========== FILTERING DEBOUNCE TIMER ==========

    // Timer for debounced filtering (150ms for better balance)
    Timer {
      id: filterDebounceTimer
      interval: 150
      repeat: false
      onTriggered: {
        performFiltering()
      }
    }

    // Function to schedule a filtered update with debouncing
    function scheduleFilter() {
      filterDebounceTimer.restart()
    }

    // Perform the actual filtering by updating group membership
    // This is much more efficient than rebuilding a ListModel
    function performFiltering() {
      // Null safety check
      if (!loader.manager || !loader.manager.emojiModel) {
        console.warn("[EmojiDisplay] Manager or emoji model not available")
        return
      }

      var search = emojiWindow.searchText.toLowerCase()
      var group = loader.manager.selectedGroup

      // Iterate through all items and update their group membership
      for (var i = 0; i < delegateModel.items.count; i++) {
        var item = delegateModel.items.get(i)
        var matches = true

        // Apply group filter
        if (group && item.model.group !== group) {
          matches = false
        }
        // Apply search filter
        else if (search && item.model.keywords.indexOf(search) === -1) {
          matches = false
        }

        // Update visibility group membership
        item.inVisible = matches
      }

      // Reset selection to first item when filter changes
      emojiWindow.selectedIndex = 0
    }

    // ========== DELEGATE MODEL WITH FILTERING ==========

    // DelegateModel wraps the source emoji model and provides efficient filtering
    // Only visible items are in the "visible" group, avoiding the need to duplicate data
    DelegateModel {
      id: delegateModel

      // Source model from manager
      model: loader.manager ? loader.manager.emojiModel : null

      // Only show items in the "visible" group
      filterOnGroup: "visible"

      // Define the "visible" group - all items start visible
      groups: [
        DelegateModelGroup {
          name: "visible"
          includeByDefault: true
        }
      ]

      // Delegate for rendering each emoji item
      delegate: Item {
        width: 70
        height: 70

        Components.EmojiGridItem {
          anchors.fill: parent
          emoji: model.emoji
          name: model.name
          itemIndex: model.index
          isSelected: delegateModel.filterOnGroup === "visible" ?
                      (DelegateModel.itemsIndex === emojiWindow.selectedIndex) : false

          onClicked: {
            // Update selection to the filtered index
            emojiWindow.selectedIndex = DelegateModel.itemsIndex
            console.log("[EmojiDisplay] Selected via click:", model.emoji)

            // Null safety check before calling manager method
            if (loader.manager) {
              loader.manager.copyEmoji(model.emoji)
            }
          }
        }
      }
    }

    // ========== FILTER TRIGGER CONNECTIONS ==========

    // Watch for group filter changes from manager
    Connections {
      target: loader.manager
      function onSelectedGroupChanged() {
        emojiWindow.scheduleFilter()
      }
    }
    
    // ========== KEYBOARD NAVIGATION ==========

    contentItem {
      focus: true

      Keys.onPressed: event => {
        // Close picker on Escape
        if (event.key === Qt.Key_Escape) {
          if (loader.manager) {
            loader.manager.visible = false
          }
          event.accepted = true
        }
        // Select and copy current emoji on Enter
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          // Get the actual item from the delegate model
          if (emojiWindow.selectedIndex >= 0 &&
              emojiWindow.selectedIndex < delegateModel.items.count) {
            var item = delegateModel.items.get(emojiWindow.selectedIndex)
            console.log("[EmojiDisplay] Selected via Enter:", item.model.emoji)

            // Null safety check
            if (loader.manager) {
              loader.manager.copyEmoji(item.model.emoji)
            }
          }
          event.accepted = true
        }
        // Navigate up by one row (calculated columns)
        else if (event.key === Qt.Key_Up) {
          var newIndex = emojiWindow.selectedIndex - emojiWindow.columns
          if (newIndex >= 0) {
            emojiWindow.selectedIndex = newIndex
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        // Navigate down by one row (calculated columns)
        else if (event.key === Qt.Key_Down) {
          var newIndex = emojiWindow.selectedIndex + emojiWindow.columns
          if (newIndex < delegateModel.items.count) {
            emojiWindow.selectedIndex = newIndex
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        // Navigate left
        else if (event.key === Qt.Key_Left) {
          if (emojiWindow.selectedIndex > 0) {
            emojiWindow.selectedIndex--
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        // Navigate right
        else if (event.key === Qt.Key_Right) {
          if (emojiWindow.selectedIndex < delegateModel.items.count - 1) {
            emojiWindow.selectedIndex++
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
      }
    }
    
    // ========== BACKGROUND OVERLAY ==========

    // Semi-transparent scrim overlay - clicking it closes the picker

      MouseArea {
        anchors.fill: parent
        onClicked: {
          // Null safety check
          if (loader.manager) {
            loader.manager.visible = false
          }
        }
      }
    
    // ========== MAIN PICKER CONTAINER ==========

    // Centered modal dialog with Material 3 styling
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
        
        // ========== HEADER ==========

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          spacing: Theme.spacing.sm

          // Title text
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding.xs
            text: "Emoji Picker"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }

          // Close button (X icon)
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
              onClicked: {
                // Null safety check
                if (loader.manager) {
                  loader.manager.visible = false
                }
              }
            }
          }
        }

        // ========== SEARCH BAR ==========

        // Search input with debouncing - filters emojis by name/keywords
        SearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 48
          placeholder: "Search emojis..."
          debounceInterval: 0  // Disable SearchBar's debounce, using DelegateModel's instead

          onSearchChanged: text => {
            emojiWindow.searchText = text
            emojiWindow.scheduleFilter()
          }
        }
        
        // ========== GROUP FILTER ==========

        // Horizontal list of category filter buttons
        Components.EmojiGroupFilter {
          Layout.fillWidth: true
          Layout.preferredHeight: 40

          // Pass groups from manager (with null safety)
          groups: loader.manager ? loader.manager.emojiGroups : []
          selectedGroup: loader.manager ? loader.manager.selectedGroup : ""

          onGroupSelected: group => {
            // Null safety check
            if (loader.manager) {
              loader.manager.selectedGroup = group
            }
          }
        }
        
        // ========== LOADING STATE ==========

        // Shown when emoji data hasn't loaded yet
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: {
            // Null safety check
            if (!loader.manager || !loader.manager.emojiModel) return false
            return loader.manager.emojiModel.count === 0 && loader.manager.errorMessage === ""
          }

          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md

            // Loading icon
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

            // Loading message
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

        // Shown when there's an error loading emoji data
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: loader.manager ? (loader.manager.errorMessage !== "") : false

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
        
        // ========== EMOJI GRID ==========

        // Main scrollable grid of emoji items
        // Uses DelegateModel for efficient filtering without data duplication
        GridView {
          id: gridView
          Layout.fillWidth: true
          Layout.fillHeight: true

          visible: {
            // Null safety check
            if (!loader.manager || !loader.manager.emojiModel) return false
            return loader.manager.emojiModel.count > 0 && loader.manager.errorMessage === ""
          }

          clip: true
          cellWidth: 70
          cellHeight: 70

          // Use the DelegateModel which provides filtered results
          model: delegateModel
          currentIndex: emojiWindow.selectedIndex

          // Smooth scrolling configuration
          maximumFlickVelocity: 2000
          flickDeceleration: 1500

          // Note: delegate is defined in DelegateModel above for proper filtering support
        }
        
        // ========== EMPTY STATE ==========

        // Shown when filter/search returns no results
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: {
            // Null safety check
            if (!loader.manager || !loader.manager.emojiModel) return false
            return loader.manager.emojiModel.count > 0 &&
                   delegateModel.items.count === 0 &&
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
                text: "󱚣"
                color: Theme.on_surface_variant
                font.pixelSize: Theme.typography.xxxl
                font.family: Theme.typography.fontFamily
                opacity: 0.6
              }
            }

            // Primary message
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

            // Secondary hint message
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

        // ========== FOOTER WITH KEYBOARD HINTS ==========

        // Shows keyboard shortcuts when emojis are visible
        Text {
          Layout.fillWidth: true
          text: "↑↓←→ Navigate • Enter Copy • Esc Close"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          horizontalAlignment: Text.AlignHCenter
          opacity: 0.7
          visible: delegateModel.items.count > 0
        }
      }
    }
  }
}
