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
import "../../../shared/components/Utils"

/**
 * ScreenRecordingDisplay - UI display for the screen recording menu system
 *
 * This component provides:
 * - Full-screen overlay screen recording menu interface
 * - Recording state indicator (shows when recording is active)
 * - Keyboard shortcuts for quick actions (letter keys + arrow navigation)
 * - Material 3 design with tertiary color highlighting
 * - Smooth animations and visual feedback
 *
 * Architecture:
 * - AnimatedLazyLoader ensures UI only loads when visible
 * - ScreenRecordingManager handles state and command execution
 * - This component is purely presentational
 * - Shows recording state from manager
 *
 * Keyboard shortcuts:
 * - F: Fullscreen recording
 * - W: Window recording
 * - S: Region/Section recording
 * - Arrow keys: Navigate between options
 * - Enter: Execute selected option (or stop if recording)
 * - Escape: Close menu
 */

// Lazy loading is crucial
AnimatedLazyLoader {
  id: loader

  required property var manager

  show: manager.visible

  // ========== WINDOW CONFIGURATION ==========
  PanelWindow {
    id: recordingWindow

    // Fill entire screen - recording menu will be centered inside
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

    property int selectedIndex: 0  // Currently selected recording option index

    // ========================================================================
    // KEYBOARD NAVIGATION & SHORTCUTS
    // ========================================================================

    KeyboardNavigationHandler {
      id: navHandler
      currentIndex: recordingWindow.selectedIndex
      itemCount: loader.manager.recordingOptions.length
      columns: 3
      wrapAround: true

      onNavigateUp: newIndex => recordingWindow.selectedIndex = newIndex
      onNavigateDown: newIndex => recordingWindow.selectedIndex = newIndex
      onNavigateLeft: newIndex => recordingWindow.selectedIndex = newIndex
      onNavigateRight: newIndex => recordingWindow.selectedIndex = newIndex

      onSelectCurrent: {
        var selected = loader.manager.recordingOptions[recordingWindow.selectedIndex]
        loader.manager.executeRecordingOption(selected)
      }

      onClose: loader.manager.visible = false
    }

    contentItem {
      focus: true

      // Handle keyboard shortcuts for navigation and quick actions
      Keys.onPressed: event => {
        // Letter key shortcuts for quick access
        // F: Fullscreen
        if (event.key === Qt.Key_F) {
          loader.manager.executeRecordingOption(loader.manager.recordingOptions[0])
          event.accepted = true
          return
        }
        // W: Window
        else if (event.key === Qt.Key_W) {
          loader.manager.executeRecordingOption(loader.manager.recordingOptions[1])
          event.accepted = true
          return
        }
        // S: Region/Section
        else if (event.key === Qt.Key_R) {
          loader.manager.executeRecordingOption(loader.manager.recordingOptions[2])
          event.accepted = true
          return
        }

        // Delegate standard navigation to handler
        navHandler.handleKeyPress(event)
      }
    }

    // ========================================================================
    // BACKGROUND OVERLAY
    // ========================================================================

    // Clicking outside of it closes the menu
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

      x: (parent.width - Config.screenRecording.width) / 2
      y: (parent.height - Config.screenRecording.height) / 2
      width: Config.screenRecording.width
      height: Config.screenRecording.height

      layer.enabled: true
      layer.smooth: true
      layer.effect: PaneShadow {}

      color: Config.paneBackground

      radius: Config.screenRecording.radius
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
        // HEADER WITH RECORDING STATE
        // ====================================================================

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          spacing: Config.spacing.sm

          // Title text
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Config.padding.xs
            text: "Screen Recording"
            color: Theme.on_surface
            font.pixelSize: Config.typography.xl
            font.family: Config.typography.sans
            font.weight: Config.typography.weightMedium
          }

          // Recording indicator (red pulsing dot)
          Rectangle {
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            radius: 6
            color: "#ff3333"
            visible: loader.manager.isRecording

            // Pulsing animation
            SequentialAnimation on opacity {
              running: loader.manager.isRecording
              loops: Animation.Infinite
              NumberAnimation { from: 1.0; to: 0.3; duration: 800; easing.type: Easing.InOutSine }
              NumberAnimation { from: 0.3; to: 1.0; duration: 800; easing.type: Easing.InOutSine }
            }
          }

          // Recording state text
          Text {
            visible: loader.manager.isRecording
            text: "Recording..."
            color: "#ff3333"
            font.pixelSize: Config.typography.md
            font.family: Config.typography.sans
            font.weight: Config.typography.weightMedium
          }

          // Close button (X icon)
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.rightMargin: Config.padding.xs
            radius: Config.radius.full
            color: closeMouseArea.containsMouse ? Theme.surface_container_high : "transparent"

            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.on_surface
              font.pixelSize: Config.typography.lg
              font.family: Config.typography.sans
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
        // RECORDING STATE MESSAGE
        // ====================================================================

        Text {
          Layout.fillWidth: true
          Layout.topMargin: Config.spacing.xs
          visible: loader.manager.isRecording
          text: "Click any option again to stop recording"
          color: Theme.on_surface_variant
          font.pixelSize: Config.typography.sm
          font.family: Config.typography.sans
          horizontalAlignment: Text.AlignHCenter
          opacity: 0.8
        }

        // ====================================================================
        // RECORDING OPTIONS GRID (1x3)
        // ====================================================================

        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 3
          rowSpacing: Config.spacing.md
          columnSpacing: Config.spacing.md

          Repeater {
            model: loader.manager.recordingOptions

            // Recording option card delegate
            delegate: Rectangle {
              required property var modelData
              required property int index

              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.preferredHeight: 140

              radius: Config.radius.xl

              // Color logic: Use tertiary color for selection, hover for mouse interaction
              // Use red tint when recording is active
              color: {
                // Recording state: Use error/red container color
                if (loader.manager.isRecording) {
                  if (index === recordingWindow.selectedIndex) {
                    return Qt.rgba(1.0, 0.2, 0.2, 0.3)  // Red with selection
                  }
                  return Qt.rgba(1.0, 0.2, 0.2, 0.15)  // Red tint
                }
                // Selected state: Use tertiary container color
                if (index === recordingWindow.selectedIndex) {
                  return Theme.tertiary_container
                }
                // Default state: Use transparent surface container low
                return "transparent"
              }

              ColumnLayout {
                anchors {
                  fill: parent
                  margins: Config.spacing.md
                }
                spacing: Config.spacing.sm

                Item { Layout.fillHeight: true }

                // Recording option icon
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.icon
                  // Use on_tertiary_container color when selected, otherwise on_surface
                  // Use white when recording
                  color: {
                    if (loader.manager.isRecording) {
                      return "#ffffff"
                    }
                    return index === recordingWindow.selectedIndex ?
                           Theme.on_tertiary_container : Theme.on_surface
                  }
                  font.pixelSize: 48
                  font.family: Config.typography.sans

                  AColor on color {}
                }

                // Recording option name
                Text {
                  Layout.fillWidth: true
                  text: modelData.name
                  color: {
                    if (loader.manager.isRecording) {
                      return "#ffffff"
                    }
                    return index === recordingWindow.selectedIndex ?
                           Theme.on_tertiary_container : Theme.on_surface
                  }
                  font.pixelSize: Config.typography.lg
                  font.family: Config.typography.sans
                  font.weight: Config.typography.weightMedium
                  horizontalAlignment: Text.AlignHCenter

                  AColor on color {}
                }

                // Recording option description
                Text {
                  Layout.fillWidth: true
                  text: loader.manager.isRecording ? "Click to stop" : modelData.description
                  color: {
                    if (loader.manager.isRecording) {
                      return "#ffffff"
                    }
                    return index === recordingWindow.selectedIndex ?
                           Theme.on_tertiary_container : Theme.on_surface_variant
                  }
                  font.pixelSize: Config.typography.sm
                  font.family: Config.typography.sans
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  opacity: loader.manager.isRecording ? 0.9 : (index === recordingWindow.selectedIndex ? 0.9 : 0.7)

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

                // Execute option on click (or stop if recording)
                onClicked: {
                  recordingWindow.selectedIndex = index
                  loader.manager.executeRecordingOption(modelData)
                }

                // Update selection on hover
                onEntered: {
                  recordingWindow.selectedIndex = index
                }
              }
            }
          }
        }

        // ====================================================================
        // FOOTER WITH KEYBOARD SHORTCUTS
        // ====================================================================

        FooterHint {
          hint: loader.manager.isRecording ?
                "F/W/S Stop recording • Esc Close" :
                "F Fullscreen • W Window • R Region • Esc Close"
        }
      }
    }
  }
}
