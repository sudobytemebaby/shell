import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../shared/theme"
import "../../shared/components"

LazyLoader {
  id: loader
  active: manager.visible

  required property var manager

  PanelWindow {
    id: notifCenterWindow

    // --------------------------------------------------------------------------
    // Window Configuration
    // --------------------------------------------------------------------------
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }

    // Explicitly set visible to true as LazyLoader handles lifecycle
    visible: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0
    }

    // --------------------------------------------------------------------------
    // Input Handling
    // --------------------------------------------------------------------------
    contentItem {
      focus: true

      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
    }

    // --------------------------------------------------------------------------
    // Main Panel Container
    // --------------------------------------------------------------------------
    Item {
      id: container
      x: parent.width - width - 28
      y: 28
      width: 360
      height: 600

      // Main container background
      Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.radius.xl

        // Use standard transparent theme
        color: Theme.surface_container_transparent_medium
        border.width: 0.5
        border.color: Theme.surface_container_high

        // Prevent clicks on panel from closing it
        MouseArea {
          anchors.fill: parent
        }

        ColumnLayout {
          anchors {
            fill: parent
            margins: Theme.padding.xl
          }

          spacing: Theme.spacing.md

          // ----------------------------------------------------------------------
          // Header Section
          // ----------------------------------------------------------------------
          RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            spacing: Theme.spacing.sm

            Text {
              Layout.fillWidth: true
              Layout.leftMargin: Theme.padding.xs
              text: "Notifications"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.xl
              font.family: Theme.typography.fontFamily
              font.weight: 600 
            }

            // Clear All button - only visible when there are notifications
            Rectangle {
              Layout.preferredWidth: 74
              Layout.preferredHeight: 32
              radius: Theme.radius.full
              visible: loader.manager.notifications.length > 0

              color: Theme.surface_container

              border.width: 1
              border.color: Theme.surface_container_high

              scale: clearMouseArea.pressed ? 0.95 : 1.0

              Behavior on color { ColorAnimation { duration: 150 } }
              Behavior on border.color { ColorAnimation { duration: 150 } }
              Behavior on scale {
                NumberAnimation {
                  duration: 100
                  easing.type: Easing.OutCubic
                }
              }

              Text {
                anchors.centerIn: parent
                text: "Clear All"
                color: Theme.on_surface
                font.pixelSize: Theme.typography.sm
                font.family: Theme.typography.fontFamily
                font.weight: Theme.typography.weightMedium
              }

              MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: loader.manager.clearAll()
              }
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

          // ----------------------------------------------------------------------
          // Notifications List
          // ----------------------------------------------------------------------
          ListView {
            id: notifList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Theme.spacing.sm

            model: loader.manager.notifications

            Behavior on contentY {
              NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
              }
            }

            delegate: Rectangle {
              required property var modelData
              required property int index

              width: notifList.width
              height: notifCard.implicitHeight

              color: "transparent"

              // Individual notification card
              Rectangle {
                id: notifCard
                anchors {
                  left: parent.left
                  right: parent.right
                  top: parent.top
                }

                implicitHeight: cardContent.implicitHeight + (Theme.padding.md * 2)

                radius: Theme.radius.lg

                // Subtle transparent background
                color: Theme.surface_container

                border.width: 1
                border.color: Theme.surface_container_high

                property bool hovered: false

                Behavior on color {
                  ColorAnimation { duration: 150 }
                }

                ColumnLayout {
                  id: cardContent
                  anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.padding.lg
                  }

                  spacing: Theme.spacing.md

                  // Card Header: Icon + App Name + Close
                  RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.sm

                    IconCircle {
                      Layout.preferredWidth: 28
                      Layout.preferredHeight: 28
                      icon: "󰂚"
                      bgColor: Theme.primary_container
                      iconColor: Theme.primary
                      iconSize: Theme.typography.md
                    }

                    Text {
                      Layout.fillWidth: true
                      text: modelData.appName
                      color: Theme.on_surface
                      font.pixelSize: Theme.typography.sm
                      font.family: Theme.typography.fontFamilyDisplay
                      font.weight: 600
                      elide: Text.ElideRight
                      maximumLineCount: 1
                    }

                    Text {
                      text: "✕"
                      color: Theme.on_surface_variant
                      font.pixelSize: Theme.typography.md
                      font.family: Theme.typography.fontFamily
                      opacity: itemCloseArea.containsMouse ? 1 : 0.7

                      Behavior on opacity {
                        NumberAnimation { duration: 150 }
                      }

                      MouseArea {
                        id: itemCloseArea
                        anchors.centerIn: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: loader.manager.removeNotification(index)
                      }
                    }
                  }

                  // Card Content: Summary + Body
                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.xs

                    // Summary (bold)
                    Text {
                      Layout.fillWidth: true
                      text: modelData.summary
                      color: Theme.on_surface
                      font.pixelSize: Theme.typography.md
                      font.family: Theme.typography.fontFamily
                      font.weight: Theme.typography.weightMedium
                      wrapMode: Text.Wrap
                      maximumLineCount: 2
                      elide: Text.ElideRight
                    }

                    // Body (muted)
                    Text {
                      Layout.fillWidth: true
                      text: modelData.body
                      color: Theme.on_surface_variant
                      font.pixelSize: Theme.typography.sm
                      font.family: Theme.typography.fontFamily
                      wrapMode: Text.Wrap
                      maximumLineCount: 3
                      elide: Text.ElideRight
                      visible: text !== ""
                      opacity: 0.8
                    }
                  }

                  // Timestamp (subtle, bottom right)
                  Text {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spacing.xs
                    Layout.bottomMargin: Theme.spacing.sm
                    text: modelData.date + (modelData.date && modelData.time ? " · " : "") + modelData.time
                    color: Theme.on_surface_variant
                    font.pixelSize: Theme.typography.xs
                    font.family: Theme.typography.fontFamily
                    opacity: 0.6
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                  }
                }

                // Hover detection
                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  propagateComposedEvents: true

                  onEntered: notifCard.hovered = true
                  onExited: notifCard.hovered = false

                  onClicked: mouse => {
                    mouse.accepted = false
                  }
                }
              }
            }

            // --------------------------------------------------------------------
            // Empty State
            // --------------------------------------------------------------------
            Item {
              anchors.centerIn: parent
              width: parent.width
              height: 200
              visible: notifList.count === 0

              ColumnLayout {
                anchors.centerIn: parent
                spacing: Theme.spacing.md

                // Icon container
                Rectangle {
                  Layout.alignment: Qt.AlignHCenter
                  Layout.preferredWidth: 64
                  Layout.preferredHeight: 64
                  radius: Theme.radius.full
                  color: "transparent"

                  Text {
                    anchors.centerIn: parent
                    text: "󰂚"
                    color: Theme.on_surface_variant
                    font.pixelSize: Theme.typography.xxl * 2
                    font.family: Theme.typography.fontFamily
                    opacity: 0.6
                  }
                }

                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: "No notifications"
                  color: Theme.on_surface
                  font.pixelSize: Theme.typography.md
                  font.family: Theme.typography.fontFamily
                  font.weight: Theme.typography.weightMedium
                  opacity: 0.8
                }

                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: "You're all caught up"
                  color: Theme.on_surface_variant
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamily
                  opacity: 0.6
                }
              }
            }
          }
        }
      }
    }
  }
}
