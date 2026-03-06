import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components"
import "../../../shared/components/Input"
import "../../../shared/components/Modals"
import "../../../shared/components/Navigation"
import "../../../shared/components/Utils"
import "emoji_components" as Components

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
    id: emojiWindow

    // Fill screen - emoji picker will be centered
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    visible: loader.active

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"
    mask: null

    Component.onCompleted: {
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

    // ========== SEARCH FILTER UTILITIES ==========

    SearchFilterMixin {
      id: filterMixin
    }

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
        // Apply search filter using SearchFilterMixin for consistent keyword matching
        else if (search && !filterMixin.keywordMatch(item.model.keywords, search)) {
          matches = false
        }

        // Update visibility group membership
        item.inVisible = matches
      }

      // Reset selection to first item after filtering completes
      // This ensures highlight is always on the first visible item
      emojiWindow.selectedIndex = 0
      if (gridView.count > 0) {
        gridView.positionViewAtBeginning()
      }
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
          isSelected: false  // Highlight is now handled by GridView.highlight

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
        emojiWindow.selectedIndex = 0
        emojiWindow.scheduleFilter()
      }
    }
    
    // ========== KEYBOARD NAVIGATION ==========

    KeyboardNavigationHandler {
      id: navHandler
      currentIndex: emojiWindow.selectedIndex
      itemCount: delegateModel.items.count
      columns: emojiWindow.columns

      onNavigateUp: newIndex => {
        emojiWindow.selectedIndex = newIndex
        gridView.positionViewAtIndex(newIndex, GridView.Contain)
      }

      onNavigateDown: newIndex => {
        emojiWindow.selectedIndex = newIndex
        gridView.positionViewAtIndex(newIndex, GridView.Contain)
      }

      onNavigateLeft: newIndex => {
        emojiWindow.selectedIndex = newIndex
        gridView.positionViewAtIndex(newIndex, GridView.Contain)
      }

      onNavigateRight: newIndex => {
        emojiWindow.selectedIndex = newIndex
        gridView.positionViewAtIndex(newIndex, GridView.Contain)
      }

      onSelectCurrent: {
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
      radius: Theme.radius.xl
      color: Theme.surface_transparent_medium
      border.width: 2
      border.color: Theme.surface_container

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
        
        // ========== HEADER ==========

        ModalHeader {
          title: "Emoji Picker"
          onCloseClicked: {
            if (loader.manager) {
              loader.manager.visible = false
            }
          }
        }

        // ========== SEARCH BAR ==========

        // Search input with debouncing - filters emojis by name/keywords
        SearchBar {
          id: searchBar
          Layout.fillWidth: true
          Layout.preferredHeight: 48
          placeholder: "Search emojis..."
          debounceInterval: 0  // Disable SearchBar's debounce, using DelegateModel's instead
          forwardNavigationKeys: true  // Allow navigation keys to control grid instead of text cursor

          onSearchChanged: text => {
            emojiWindow.searchText = text
            emojiWindow.scheduleFilter()
          }

          // Handle navigation keys forwarded from SearchBar
          onNavigationKeyPressed: event => {
            navHandler.handleKeyPress(event)
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

          // Visual highlight that follows the currently selected item
          highlight: Item {
            width: 70
            height: 70

            Rectangle {
              anchors {
                fill: parent
                margins: Theme.spacing.xs
              }
              radius: Theme.radius.xl
              color: Theme.primary_container
            }
          }

          // Critical: This ensures the highlight automatically moves with currentIndex
          highlightFollowsCurrentItem: true

          // Smooth scrolling configuration
          maximumFlickVelocity: 2000
          flickDeceleration: 1500

          // Ensure currentIndex stays within valid bounds when model changes
          onCountChanged: {
            if (count > 0) {
              if (emojiWindow.selectedIndex >= count) {
                emojiWindow.selectedIndex = count - 1
              } else if (emojiWindow.selectedIndex < 0) {
                emojiWindow.selectedIndex = 0
              }
            } else {
              emojiWindow.selectedIndex = -1
            }
          }

          // Automatically scroll to keep the current item visible
          onCurrentIndexChanged: {
            if (currentIndex >= 0 && currentIndex < count) {
              positionViewAtIndex(currentIndex, GridView.Contain)
            }
          }

          // Reset selection IMMEDIATELY when search changes (before filtering)
          // This prevents highlight from "flying" during the debounce period
          Connections {
            target: emojiWindow
            function onSearchTextChanged() {
              emojiWindow.selectedIndex = 0
              if (gridView.count > 0) {
                gridView.positionViewAtBeginning()
              }
            }
          }

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

        FooterHint {
          hint: "Arrows to Navigate • Enter to Copy • Esc to Close"
          visible: delegateModel.items.count > 0
        }
      }
    }
  }
}
