import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"
import "../../../shared/components/Animations"
import "../../../shared/components"
import "../../../shared/components/Modals"
import "../../../shared/components/Navigation"
import "../../../shared/components/Buttons"
import "../../../shared/components/Utils"

/**
 * MatugenDisplay - UI display for the matugen color scheme menu system
 *
 * This component provides:
 * - Full-screen overlay color scheme selection interface
 * - Light/dark mode toggle for theme switching
 * - Keyboard navigation (arrow keys and tab)
 * - Material 3 design with tertiary color highlighting
 * - Smooth animations and visual feedback
 * - 3x3 grid layout for 9 color schemes
 *
 * Architecture:
 * - AnimatedLazyLoader ensures UI only loads when visible
 * - MatugenManager handles state and command execution
 * - This component is purely presentational
 *
 * Keyboard shortcuts:
 * - Arrow keys: Navigate between options
 * - Tab: Next option
 * - Shift+Tab: Previous option
 * - Enter: Apply selected scheme
 * - Escape: Close menu
 */

// ========== LAZY LOADING ==========

AnimatedLazyLoader {
  id: loader

  required property var manager

  show: manager.visible

  // ========== WINDOW CONFIGURATION ==========

  PanelWindow {
    id: matugenWindow

    // Fill entire screen - menu will be centered inside
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

    // ========================================================================
    // SELECTION STATE
    // ========================================================================

    property int selectedIndex: 0  // Currently selected color scheme index

    // ========================================================================
    // KEYBOARD NAVIGATION & SHORTCUTS
    // ========================================================================

    KeyboardNavigationHandler {
      id: navHandler
      currentIndex: matugenWindow.selectedIndex
      itemCount: loader.manager.colorSchemes.length
      columns: 3
      wrapAround: true
      enableTabNavigation: true

      onNavigateUp: newIndex => matugenWindow.selectedIndex = newIndex
      onNavigateDown: newIndex => matugenWindow.selectedIndex = newIndex
      onNavigateLeft: newIndex => matugenWindow.selectedIndex = newIndex
      onNavigateRight: newIndex => matugenWindow.selectedIndex = newIndex

      onSelectCurrent: {
        var selected = loader.manager.colorSchemes[matugenWindow.selectedIndex]
        loader.manager.executeColorScheme(selected)
      }

      onClose: loader.manager.visible = false
    }

    contentItem {
      focus: true

      // Handle keyboard shortcuts for navigation and quick actions
      Keys.onPressed: event => {
        navHandler.handleKeyPress(event)
      }
    }

    // ========================================================================
    // BACKGROUND OVERLAY
    // ========================================================================

    // Semi-transparent background - clicking it closes the menu
    MouseArea {
      anchors.fill: parent
      onClicked: {
        loader.manager.visible = false
      }
    }

    // ========================================================================
    // MAIN CONTAINER
    // ========================================================================

    // Centered modal dialog with Material 3 styling
    Rectangle {
      id: container

      layer.enabled: true
      layer.smooth: true
      layer.effect: PaneShadow {}

      x: (parent.width - Config.matugen.width) / 2
      y: (parent.height - Config.matugen.height) / 2
      width: Config.matugen.width
      height: Config.matugen.height

      color: Config.paneBackground
      radius: Config.matugen.radius
      border.width: Config.paneBorderWidth
      border.color: Theme.surface_container

      scale: loader.contentScale
      opacity: loader.contentOpacity

      // Prevent clicks on container from propagating to background (which would close menu)
      MouseArea {
        anchors.fill: parent
      }

      ColumnLayout {
        anchors {
          fill: parent
          margins: Config.padding.xl
        }
        spacing: Config.spacing.md

        // ====================================================================
        // HEADER
        // ====================================================================

        ModalHeader {
          title: "Matugen Color Scheme"
          onCloseClicked: loader.manager.visible = false
        }

        // ====================================================================
        // TOOLBAR (Wallpaper info + Theme Switcher)
        // ====================================================================

        RowLayout {
          Layout.fillWidth: true
          spacing: Config.spacing.lg

          Text {
            text: {
              if (loader.manager.currentWallpaperPath) {
                var parts = loader.manager.currentWallpaperPath.split("/")
                var filename = parts[parts.length - 1]
                return "Source: " + filename
              }
              return "Loading wallpaper..."
            }
            color: Theme.on_surface_variant
            font.pixelSize: Config.typography.sm
            font.family: Config.typography.sans
            opacity: 0.7
            elide: Text.ElideMiddle
          }

          Item { Layout.fillWidth: true }

          SegmentedButton {
            Layout.preferredWidth: 180
            Layout.preferredHeight: 36

            options: [
              { icon: "󰖔", text: "Dark" },
              { icon: "󰖙", text: "Light" }
            ]

            currentIndex: loader.manager.lightMode ? 1 : 0

            onClicked: index => {
              loader.manager.lightMode = (index === 1)
            }
          }
        }

        // Divider
        Rectangle {
          Layout.fillWidth: true
          Layout.topMargin: 4
          Layout.bottomMargin: 4
          height: 1
          color: Theme.surface_container_high
          opacity: 0.5
        }

        // ====================================================================
        // COLOR SCHEMES GRID (3x3)
        // ====================================================================

        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 3
          rowSpacing: Config.spacing.sm
          columnSpacing: Config.spacing.sm

          Repeater {
            model: loader.manager.colorSchemes

            // Color scheme option card delegate
            delegate: Rectangle {
              required property var modelData
              required property int index

              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.preferredHeight: 120

              radius: Config.radius.xl

              color: {
                if (index === matugenWindow.selectedIndex) {
                  return Theme.tertiary_container
                }
                return "transparent"
              }

              ColumnLayout {
                anchors.fill: parent
                spacing: Config.spacing.xs

                Item { Layout.fillHeight: true }

                // Icon
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.icon
                  color: index === matugenWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface
                  font.pixelSize: 40
                  font.family: Config.typography.sans

                  AColor on color {}
                }

                // Title
                Text {
                  Layout.fillWidth: true
                  text: modelData.name
                  color: index === matugenWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface
                  font.pixelSize: Config.typography.md
                  font.family: Config.typography.sans
                  font.weight: Config.typography.weightMedium
                  horizontalAlignment: Text.AlignHCenter

                  AColor on color {}
                }

                // Description
                Text {
                  Layout.fillWidth: true
                  text: modelData.description
                  color: index === matugenWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface_variant
                  font.pixelSize: Config.typography.sm
                  font.family: Config.typography.sans
                  horizontalAlignment: Text.AlignHCenter
                  opacity: index === matugenWindow.selectedIndex ? 0.8 : 0.6

                  AColor on color {}
                }

                Item { Layout.fillHeight: true }
              }

              // Mouse interaction handler
              MouseArea {
                id: optionMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                // Execute option on click
                onClicked: {
                  matugenWindow.selectedIndex = index
                  loader.manager.executeColorScheme(modelData)
                }

                // Update selection on hover
                onEntered: {
                  matugenWindow.selectedIndex = index
                }
              }
            }
          }
        }

        // ====================================================================
        // FOOTER WITH KEYBOARD SHORTCUTS
        // ====================================================================

        FooterHint {
          hint: "Arrow Keys Navigate • Tab Next • Shift+Tab Previous • Enter Apply • Esc Close"
        }
      }
    }
  }
}
