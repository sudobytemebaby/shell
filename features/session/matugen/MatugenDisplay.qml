import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../shared/theme"

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
 * - LazyLoader ensures UI only loads when visible
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

LazyLoader {
  id: loader

  required property var manager

  // Lazy load UI only when visible for better performance
  active: manager.visible

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

    contentItem {
      focus: true

      // Handle keyboard shortcuts for navigation and quick actions
      Keys.onPressed: event => {
        // Close menu on Escape
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        // Arrow key navigation: Up moves to previous row
        else if (event.key === Qt.Key_Up) {
          if (matugenWindow.selectedIndex >= 3) {
            matugenWindow.selectedIndex -= 3
          } else {
            // Wrap to bottom row
            matugenWindow.selectedIndex = (matugenWindow.selectedIndex + 6) % 9
          }
          event.accepted = true
        }
        // Arrow key navigation: Down moves to next row
        else if (event.key === Qt.Key_Down) {
          if (matugenWindow.selectedIndex < 6) {
            matugenWindow.selectedIndex += 3
          } else {
            // Wrap to top row
            matugenWindow.selectedIndex = matugenWindow.selectedIndex % 3
          }
          event.accepted = true
        }
        // Arrow key navigation: Left moves to previous column
        else if (event.key === Qt.Key_Left) {
          if (matugenWindow.selectedIndex > 0) {
            matugenWindow.selectedIndex--
          } else {
            // Wrap around to last option
            matugenWindow.selectedIndex = loader.manager.colorSchemes.length - 1
          }
          event.accepted = true
        }
        // Arrow key navigation: Right moves to next column
        else if (event.key === Qt.Key_Right) {
          if (matugenWindow.selectedIndex < loader.manager.colorSchemes.length - 1) {
            matugenWindow.selectedIndex++
          } else {
            // Wrap around to first option
            matugenWindow.selectedIndex = 0
          }
          event.accepted = true
        }
        // Tab navigation: Move to next option
        else if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
          if (matugenWindow.selectedIndex < loader.manager.colorSchemes.length - 1) {
            matugenWindow.selectedIndex++
          } else {
            // Wrap around to first option
            matugenWindow.selectedIndex = 0
          }
          event.accepted = true
        }
        // Shift+Tab navigation: Move to previous option
        else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
          if (matugenWindow.selectedIndex > 0) {
            matugenWindow.selectedIndex--
          } else {
            // Wrap around to last option
            matugenWindow.selectedIndex = loader.manager.colorSchemes.length - 1
          }
          event.accepted = true
        }
        // Execute selected option on Enter
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          var selected = loader.manager.colorSchemes[matugenWindow.selectedIndex]
          loader.manager.executeColorScheme(selected)
          event.accepted = true
        }
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
      x: (parent.width - 800) / 2
      y: (parent.height - 700) / 2
      width: 800
      height: 700
      radius: 28
      color: Theme.surface_container_transparent_medium
      border.width: 0.5
      border.color: Theme.surface_container_high

      // Prevent clicks on container from propagating to background (which would close menu)
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

          // Title text
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding.xs
            text: "Matugen Color Scheme"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }

          // Close button (X icon)
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
        // SUBTITLE WITH WALLPAPER PATH
        // ====================================================================

        Text {
          Layout.fillWidth: true
          Layout.leftMargin: Theme.padding.xs
          text: {
            if (loader.manager.currentWallpaperPath) {
              // Extract filename from path
              var parts = loader.manager.currentWallpaperPath.split("/")
              var filename = parts[parts.length - 1]
              return "Apply color scheme from: " + filename
            }
            return "Loading wallpaper..."
          }
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          opacity: 0.7
          elide: Text.ElideMiddle
        }

        // ====================================================================
        // LIGHT/DARK MODE TOGGLE
        // ====================================================================

        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          Layout.topMargin: Theme.spacing.sm
          Layout.preferredWidth: 200
          Layout.preferredHeight: 40
          radius: Theme.radius.full
          color: Theme.surface_container_high

          RowLayout {
            anchors.fill: parent
            spacing: 0

            // Dark mode button
            Rectangle {
              Layout.fillHeight: true
              Layout.fillWidth: true
              Layout.margins: 4
              radius: Theme.radius.full
              color: !loader.manager.lightMode ? Theme.tertiary_container : "transparent"

              RowLayout {
                anchors.centerIn: parent
                spacing: Theme.spacing.xs

                Text {
                  text: "󰖔"  // Moon icon
                  color: !loader.manager.lightMode ? Theme.on_tertiary_container : Theme.on_surface_variant
                  font.pixelSize: Theme.typography.md
                  font.family: Theme.typography.fontFamily
                }

                Text {
                  text: "Dark"
                  color: !loader.manager.lightMode ? Theme.on_tertiary_container : Theme.on_surface_variant
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamily
                  font.weight: !loader.manager.lightMode ? Theme.typography.weightMedium : Theme.typography.weightRegular
                }
              }

              MouseArea {
                id: darkModeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                  if (loader.manager.lightMode) {
                    loader.manager.lightMode = false
                  }
                }
              }

              Behavior on color {
                ColorAnimation {
                  duration: 200
                  easing.type: Easing.OutCubic
                }
              }
            }

            // Light mode button
            Rectangle {
              Layout.fillHeight: true
              Layout.fillWidth: true
              Layout.margins: 4
              radius: Theme.radius.full
              color: loader.manager.lightMode ? Theme.tertiary_container : "transparent"

              RowLayout {
                anchors.centerIn: parent
                spacing: Theme.spacing.xs

                Text {
                  text: "󰖙"  // Sun icon
                  color: loader.manager.lightMode ? Theme.on_tertiary_container : Theme.on_surface_variant
                  font.pixelSize: Theme.typography.md
                  font.family: Theme.typography.fontFamily
                }

                Text {
                  text: "Light"
                  color: loader.manager.lightMode ? Theme.on_tertiary_container : Theme.on_surface_variant
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamily
                  font.weight: loader.manager.lightMode ? Theme.typography.weightMedium : Theme.typography.weightRegular
                }
              }

              MouseArea {
                id: lightModeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                  if (!loader.manager.lightMode) {
                    loader.manager.lightMode = true
                  }
                }
              }

              Behavior on color {
                ColorAnimation {
                  duration: 200
                  easing.type: Easing.OutCubic
                }
              }
            }
          }
        }

        // ====================================================================
        // COLOR SCHEMES GRID (3x3)
        // ====================================================================

        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 3
          rowSpacing: Theme.spacing.md
          columnSpacing: Theme.spacing.md

          Repeater {
            model: loader.manager.colorSchemes

            // Color scheme option card delegate
            delegate: Rectangle {
              required property var modelData
              required property int index

              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.preferredHeight: 140

              radius: Theme.radius.xl

              // Color logic: Use tertiary color for selection, hover for mouse interaction
              color: {
                // Selected state: Use tertiary container color
                if (index === matugenWindow.selectedIndex) {
                  return Theme.tertiary_container
                }
                // Hover state: Use transparent for minimal hover effect
                if (optionMouseArea.containsMouse) {
                  return "transparent"
                }
                // Default state: Use transparent
                return "transparent"
              }

              ColumnLayout {
                anchors {
                  fill: parent
                  margins: Theme.spacing.md
                }
                spacing: Theme.spacing.sm

                Item { Layout.fillHeight: true }

                // Color scheme icon
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.icon
                  // Use on_tertiary_container color when selected, otherwise on_surface
                  color: index === matugenWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface
                  font.pixelSize: 48
                  font.family: Theme.typography.fontFamily

                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }

                // Color scheme name
                Text {
                  Layout.fillWidth: true
                  text: modelData.name
                  color: index === matugenWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface
                  font.pixelSize: Theme.typography.lg
                  font.family: Theme.typography.fontFamilyDisplay
                  font.weight: Theme.typography.weightMedium
                  horizontalAlignment: Text.AlignHCenter

                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }

                // Color scheme description
                Text {
                  Layout.fillWidth: true
                  text: modelData.description
                  color: index === matugenWindow.selectedIndex ?
                         Theme.on_tertiary_container : Theme.on_surface_variant
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamilyDisplay
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  opacity: index === matugenWindow.selectedIndex ? 0.9 : 0.7

                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
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

        Text {
          Layout.fillWidth: true
          text: "Arrow Keys Navigate • Tab Next • Shift+Tab Previous • Enter Apply • Esc Close"
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
