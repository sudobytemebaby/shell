import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "../components"

AnimatedLazyLoader {
  id: loader

  required property var manager

  // Bind to manager visibility
  show: manager.visible

  // Animation config - snappy scale animation
  openDuration: 150
  closeDuration: 100
  openEasingType: Easing.OutCubic
  closeEasingType: Easing.OutCubic
  openOvershoot: 0

  PanelWindow {
    id: menuWindow

    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: loader.manager.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0
    }

    contentItem {
      focus: true

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
          const filteredItems = menuList.getFilteredItems()
          if (menuList.currentIndex >= 0 && menuList.currentIndex < filteredItems.length) {
            const selectedItem = filteredItems[menuList.currentIndex]
            loader.manager.executeItem(selectedItem)
          }
          event.accepted = true
        }
      }
    }

    // Background overlay - animates with loader progress
    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
    }

    // Main container
    Rectangle {
      id: menuBox
      x: (parent.width - 460) / 2
      y: (parent.height - 520) / 2
      width: 460
      height: 520
      radius: 28
      color: Theme.surface_container_transparent_medium
      border.width: 1
      border.color: Qt.lighter(Theme.surface_container, 1.3)

      // Animate scale and opacity using loader's animationProgress
      scale: 0.85 + (0.15 * loader.animationProgress)
      opacity: loader.animationProgress
      transformOrigin: Item.Center

      // Prevent clicks on menu from closing it
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
            opacity: closeMouseArea.containsMouse ? 0.7 : 1

            Behavior on opacity {
              NumberAnimation { duration: 200 }
            }

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
        MenuSearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 48

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

            // Highlight
            highlight: Rectangle {
              width: menuList.width
              height: 72
              radius: Theme.radius.xl
              color: Theme.primary_container
              border.width: 0
              border.color : Theme.primary
            }

            highlightFollowsCurrentItem: true

            // Filtered model based on search
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

            onCurrentIndexChanged: {
              if (currentIndex >= 0 && currentIndex < count) {
                positionViewAtIndex(currentIndex, ListView.Contain)
              }
            }

            function getFilteredItems() {
              return model.values
            }

            delegate: MenuItem {
              required property var modelData
              required property int index

              width: menuList.width
              height: 72
              item: modelData
              isSelected: index === menuList.currentIndex

              onClicked: {
                menuList.currentIndex = index
              }

              onActivated: {
                loader.manager.executeItem(modelData)
              }
            }

            // Empty state
            Text {
              anchors.centerIn: parent
              text: loader.manager.searchText ? "No items found" : "No menu items available"
              color: Theme.on_surface_variant
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              opacity: menuList.count === 0 ? 0.7 : 0
            }
          }
        }

        // ========== FOOTER WITH HINT ==========
        Text {
          Layout.fillWidth: true
          text: "↑↓ Navigate • Enter Select • Esc Close"
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
