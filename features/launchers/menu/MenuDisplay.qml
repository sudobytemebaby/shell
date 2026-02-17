import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components"
import "../../../shared/components/Input"
import "../../../shared/components/Lists"
import "../../../shared/components/Modals"
import "../../../shared/components/Navigation"
import "../../../shared/components/Utils"

/**
 * MenuDisplay
 *
 * UI display component for the menu picker system.
 *
 * ARCHITECTURE:
 * This component implements the Display pattern, handling all visual presentation
 * while delegating state management and logic to MenuManager.qml. The UI is
 * lazy-loaded for performance and uses Material 3 design principles.
 *
 * FEATURES:
 * - Search-based filtering of menu items
 * - Keyboard navigation with highlight following
 * - Material 3 design with smooth animations
 * - Empty state handling
 *
 * KEYBOARD SHORTCUTS:
 * - Up/Down or Ctrl+P/N: Navigate through items
 * - Enter: Execute selected item
 * - Home/End: Jump to first/last item
 * - Escape: Close menu
 * - Type to search: Filter items in real-time
 *
 * BEHAVIOR:
 * - Lazy loads when manager.visible becomes true
 * - Resets search and selection when opened
 * - Maintains highlight position during navigation
 * - Automatically scrolls to keep current item visible
 */

// ========== LAZY LOADING ==========

AnimatedLazyLoader {
  id: loader
  show: manager.visible

  required property var manager

  // Polished animation timings
  openDuration: 150
  closeDuration: 0
  openEasingType: Easing.OutCubic
  closeEasingType: Easing.InOutCubic

  // ========== WINDOW CONFIGURATION ==========

  PanelWindow {
    id: menuWindow

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
    }

    // ========== KEYBOARD NAVIGATION ==========

    KeyboardNavigationHandler {
      id: navHandler
      currentIndex: menuList.currentIndex
      itemCount: menuList.count
      enableCtrlPN: true
      enableHomeEnd: true

      onNavigateUp: newIndex => menuList.currentIndex = newIndex
      onNavigateDown: newIndex => menuList.currentIndex = newIndex

      onSelectCurrent: {
        const filteredItems = menuList.model.values
        if (menuList.currentIndex >= 0 && menuList.currentIndex < filteredItems.length) {
          const selectedItem = filteredItems[menuList.currentIndex]
          loader.manager.executeItem(selectedItem)
        }
      }

      onClose: loader.manager.visible = false
    }

    contentItem {
      focus: true
      Keys.onPressed: event => navHandler.handleKeyPress(event)
    }

    // Clicking outside the menu closes it
    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
    }

    // ========== MAIN CONTAINER ==========

    Rectangle {
      id: menuBox
      
      layer.enabled: true
      layer.smooth: true

      x: (parent.width - 460) / 2
      y: (parent.height - 560) / 2
      width: 460
      height: 560

      // Rounded corners all around (centered design)
      radius: Theme.radius.xl

      color: Theme.surface_transparent_medium
      border.width: 0.5
      border.color: Theme.surface_container_high

      // Polished appearing animation: subtle scale + fade + slide
      scale: 0.8 + (loader.animationProgress * 0.2)  // Scale from 0.94 to 1.0
      opacity: loader.animationProgress  // Fade from 0 to 1

      // Prevent clicks on menu from closing it (only background clicks close)
      MouseArea {
        anchors.fill: parent
      }

    // ========== SEARCH FILTER UTILITIES ==========

    SearchFilterMixin {
      id: filterMixin
    }

    ColumnLayout {
      anchors {
        fill: parent
        margins: Theme.padding.xl
      }
      spacing: Theme.spacing.md

      // ========== HEADER ==========

      ModalHeader {
        title: "Menu"
        onCloseClicked: loader.manager.visible = false
      }

      // ========== SEARCH BAR ==========
      SearchBar {
        Layout.fillWidth: true
        Layout.preferredHeight: 48
        placeholder: "Search menu..."

        onSearchChanged: text => {
          loader.manager.searchText = text
        }
      }

      // ========== MENU ITEMS LIST ==========
      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        ListView {
          id: menuList
          anchors.fill: parent
          clip: true
          spacing: Theme.spacing.xs

          currentIndex: 0

          // Visual highlight that follows the currently selected item
          // highlightFollowsCurrentItem ensures the highlight stays in sync
          highlight: Rectangle {
            width: menuList.width
            height: 72
            radius: Theme.radius.xl
            color: Theme.primary_container
          }

          // Critical: This ensures the highlight automatically moves with currentIndex
          // Without this, the highlight would stay in place when navigating
          highlightFollowsCurrentItem: true

          // Dynamic model that filters menu items based on search text
          // Uses SearchFilterMixin for consistent multi-field matching and relevance sorting
          model: ScriptModel {
            values: {
              const allItems = loader.manager.menuItems

              // No search term: return all items
              if (!loader.manager.searchText) {
                return allItems
              }

              // Filter using multi-field match (name and description)
              const filtered = filterMixin.filterByMultiField(
                allItems,
                loader.manager.searchText,
                ["name", "description"]
              )

              // Sort by relevance for better UX (exact matches first, then starts-with, etc.)
              return filterMixin.sortByRelevance(filtered, loader.manager.searchText, "name")
            }
          }

          // Ensure currentIndex stays within valid bounds when model changes
          // This prevents crashes when the filtered list shrinks, but doesn't
          // automatically trigger highlight refresh (that's handled by onSearchTextChanged)
          onCountChanged: {
            if (count > 0) {
              if (currentIndex >= count) {
                currentIndex = count - 1
              } else if (currentIndex < 0) {
                currentIndex = 0
              }
            } else {
              currentIndex = -1
            }
          }

          // Automatically scroll to keep the current item visible
          // Works with highlightFollowsCurrentItem to maintain highlight position
          onCurrentIndexChanged: {
            if (currentIndex >= 0 && currentIndex < count) {
              positionViewAtIndex(currentIndex, ListView.Contain)
            }
          }

          // Reset selection when search changes to fix highlight disappearing bug
          // Without this, clearing the search leaves the highlight invisible
          Connections {
            target: loader.manager
            function onSearchTextChanged() {
              menuList.currentIndex = 0
              if (menuList.count > 0) {
                menuList.positionViewAtBeginning()
              }
            }
          }

          // List item delegate - renders each menu item with icon, name, and description
          delegate: ListItem {
            required property var modelData
            required property int index

            width: menuList.width
            height: 72
            icon: modelData.icon
            title: modelData.name
            subtitle: modelData.description
            selected: index === menuList.currentIndex

            // Menu uses primary color scheme for visual consistency
            selectedBgColor: Theme.primary
            selectedIconColor: Theme.on_primary
            defaultBgColor: Theme.primary_container
            defaultIconColor: Theme.primary

            onClicked: {
              menuList.currentIndex = index
              loader.manager.executeItem(modelData)
            }
          }

          // Empty state message shown when no items match the search
          Text {
            anchors.centerIn: parent
            text: loader.manager.searchText ? "No items found" : "No menu items available"
            color: Theme.on_surface_variant
            font.pixelSize: Theme.typography.md
            font.family: Theme.typography.fontFamilyDisplay
            opacity: menuList.count === 0 ? 0.7 : 0
          }
        }
      }

      // ========== FOOTER WITH HINT ==========

      FooterHint {
        hint: "Ctrl+P/N to Navigate • Enter to Select • Esc to Close"
      }
     }
    }
  }
}
