import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../shared/theme"
import "../../shared/components"
import "../../shared/components/Modals"
import "../../shared/components/Utils"

AnimatedLazyLoader {
  id: loader
  show: manager.visible

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

    visible: loader.active

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
      x: parent.width - width - Config.notificationCenter.marginFromEdge
      y: Config.notificationCenter.posY
      width: Config.notificationCenter.width
      height: Config.notificationCenter.height

      scale: loader.contentScale
      opacity: loader.contentOpacity

      // Main container background
      Rectangle {
        id: background
        anchors.fill: parent
        radius: Config.notificationCenter.radius

        layer.enabled: true
        layer.smooth: true

        layer.effect: PaneShadow {}

        color: Config.paneBackground

        border.width: Config.paneBorderWidth
        border.color: Theme.surface_container

        // Prevent clicks on panel from closing it
        MouseArea {
          anchors.fill: parent
        }

        ColumnLayout {
          anchors {
            fill: parent
            margins: Config.padding.xl
          }

          spacing: Config.spacing.md

          // ----------------------------------------------------------------------
          // Header Section
          // ----------------------------------------------------------------------
          ModalHeader {
            title: "Notifications"

            // Show "Clear All" action button only when there are notifications
            actionButtons: loader.manager.notifications.length > 0 ? [
              {
                icon: "󰆴",  // Trash can icon
                tooltip: "Clear All",
                onClicked: () => { loader.manager.clearAll() }
              }
            ] : []

            onCloseClicked: loader.manager.visible = false
          }

          // ----------------------------------------------------------------------
          // Notifications List
          // ----------------------------------------------------------------------
          ListView {
            id: notifList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Config.spacing.sm

            model: loader.manager.notifications

            AExpand on contentY {}

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

                implicitHeight: cardContent.implicitHeight + (Config.padding.lg * 2)

                radius: Config.radius.lg

                // Subtle transparent background
                color: Theme.surface_container_low

                border.width: 0.5
                border.color: Theme.surface_container_high

                property bool hovered: false

                AColor on color {}

                ColumnLayout {
                  id: cardContent
                  anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Config.padding.lg
                  }

                  spacing: Config.spacing.md

                  // Card Header: Icon + App Name + Close
                  RowLayout {
                    Layout.fillWidth: true
                    spacing: Config.spacing.sm

                    IconCircle {
                      Layout.preferredWidth: 28
                      Layout.preferredHeight: 28
                      icon: "󰂚"
                      bgColor: Theme.primary_container
                      iconColor: Theme.primary
                      iconSize: Config.typography.md
                    }

                    Text {
                      Layout.fillWidth: true
                      text: modelData.appName
                      color: Theme.on_surface
                      font.pixelSize: Config.typography.sm
                      font.family: Config.typography.sans
                      font.weight: Config.typography.weightMedium
                      elide: Text.ElideRight
                      maximumLineCount: 1
                    }

                    // Close button
                    Text {
                      text: "✕"
                      font.pixelSize: Config.typography.sm
                      font.family: Config.typography.sans
                      color: mouseArea.containsMouse ? Theme.outline : Theme.on_surface_variant

                      MouseArea {
                        id: mouseArea
                        width: 24
                        height: 24
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
                    spacing: Config.spacing.xs

                    // Summary (bold)
                    Text {
                      Layout.fillWidth: true
                      text: modelData.summary
                      color: Theme.on_surface
                      font.pixelSize: Config.typography.md
                      font.family: Config.typography.sans
                      font.weight: Config.typography.weightMedium
                      wrapMode: Text.Wrap
                      maximumLineCount: 2
                      elide: Text.ElideRight
                    }

                    // Body (muted)
                    Text {
                      Layout.fillWidth: true
                      text: modelData.body
                      color: Theme.on_surface_variant
                      font.pixelSize: Config.typography.sm
                      font.family: Config.typography.sans
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
                    Layout.topMargin: Config.spacing.xs
                    Layout.bottomMargin: Config.spacing.sm
                    text: modelData.date + (modelData.date && modelData.time ? " · " : "") + modelData.time
                    color: Theme.on_surface_variant
                    font.pixelSize: Config.typography.xs
                    font.family: Config.typography.sans
                    opacity: 0.6
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
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
                spacing: Config.spacing.md

                // Icon container
                Rectangle {
                  Layout.alignment: Qt.AlignHCenter
                  Layout.preferredWidth: 64
                  Layout.preferredHeight: 64
                  radius: Config.radius.full
                  color: "transparent"

                  Text {
                    anchors.centerIn: parent
                    text: "󰂚"
                    color: Theme.on_surface_variant
                    font.pixelSize: Config.typography.xxl * 2
                    font.family: Config.typography.sans
                    opacity: 0.6
                  }
                }

                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: "No notifications"
                  color: Theme.on_surface
                  font.pixelSize: Config.typography.md
                  font.family: Config.typography.sans
                  font.weight: Config.typography.weightMedium
                  opacity: 0.8
                }

                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: "You're all caught up"
                  color: Theme.on_surface_variant
                  font.pixelSize: Config.typography.sm
                  font.family: Config.typography.sans
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
