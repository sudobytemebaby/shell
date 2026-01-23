import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components"
import "../../../shared/components/Input"
import "../../../shared/components/Lists"

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

    contentItem {
      focus: true

      // Handle all keyboard shortcuts for menu navigation
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
          if (menuList.currentIndex > 0) {
            menuList.currentIndex--
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          if (menuList.currentIndex < menuList.count - 1) {
            menuList.currentIndex++
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          const filteredItems = menuList.model.values
          if (menuList.currentIndex >= 0 && menuList.currentIndex < filteredItems.length) {
            const selectedItem = filteredItems[menuList.currentIndex]
            loader.manager.executeItem(selectedItem)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Home) {
          menuList.currentIndex = 0
          event.accepted = true
        }
        else if (event.key === Qt.Key_End) {
          if (menuList.count > 0) {
            menuList.currentIndex = menuList.count - 1
          }
          event.accepted = true
        }
      }
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

      color: Theme.surface_container_transparent_medium
      border.width: 1
      border.color: Theme.surface_container_high

      // Polished appearing animation: subtle scale + fade + slide
      scale: 0.9 + (loader.animationProgress * 0.1)  // Scale from 0.94 to 1.0
      opacity: loader.animationProgress  // Fade from 0 to 1

      // Prevent clicks on menu from closing it (only background clicks close)
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
          text: "Menu"
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
            cursorShape: Qt.PointingHandCursor
            onClicked: loader.manager.visible = false
          }
        }
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
          // Filters by matching search against item name or description
          model: ScriptModel {
            values: {
              const search = loader.manager.searchText.toLowerCase()
              const allItems = loader.manager.menuItems

              if (!search) {
                return allItems
              }

              const filtered = allItems.filter(item => {
                const name = (item.name || "").toLowerCase()
                const description = (item.description || "").toLowerCase()
                return name.includes(search) || description.includes(search)
              })

              return filtered
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
      Text {
        Layout.fillWidth: true
        text: "↑↓ / Ctrl+P/N Navigate • Enter Select • Home/End Jump • Esc Close"
        color: Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamilyDisplay
        horizontalAlignment: Text.AlignHCenter
        opacity: 0.7
      }
    }
  }
  }
}
