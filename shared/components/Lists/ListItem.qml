import QtQuick
import QtQuick.Layouts
import "../../theme"
import ".."

// Unified ListItem Component
// Consolidates: LauncherAppItem, MenuItem patterns
Rectangle {
  id: root

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  property string icon: ""
  property string title: ""
  property string subtitle: ""
  property string iconSource: ""  // Image path (alternative to icon text)
  property int iconSize: 48
  property bool selected: false

  // Icon color customization
  property color selectedBgColor: Theme.secondary
  property color selectedIconColor: Theme.on_secondary
  property color defaultBgColor: Theme.secondary_container
  property color defaultIconColor: Theme.secondary

  signal clicked()
  signal rightClicked()

  // ============================================================================
  // APPEARANCE
  // ============================================================================

  radius: Theme.radius.lg
  color: "transparent"

  // ============================================================================
  // CONTENT
  // ============================================================================

  RowLayout {
    anchors.fill: parent
    anchors.margins: Theme.padding.md
    spacing: Theme.spacing.md

    // Icon (either text icon or image)
    Loader {
      id: iconLoader
      Layout.preferredWidth: root.iconSize
      Layout.preferredHeight: root.iconSize
      Layout.alignment: Qt.AlignVCenter

      sourceComponent: root.iconSource !== "" ? imageIconComponent : textIconComponent
    }

    // Image icon component
    Component {
      id: imageIconComponent
      Rectangle {
        width: root.iconSize
        height: root.iconSize
        radius: Theme.radius.md
        color: Theme.surface_container

        Image {
          anchors.fill: parent
          anchors.margins: 4
          source: root.iconSource
          fillMode: Image.PreserveAspectFit
          smooth: true
        }
      }
    }

    // Text icon component (using IconCircle)
    Component {
      id: textIconComponent
      IconCircle {
        icon: root.icon
        iconSize: root.iconSize * 0.5
        bgColor: root.selected ? root.selectedBgColor : root.defaultBgColor
        iconColor: root.selected ? root.selectedIconColor : root.defaultIconColor
      }
    }

    // Text content
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 2

      Text {
        id: titleText
        text: root.title
        color: Theme.on_surface
        font.pixelSize: Theme.typography.md
        font.family: Theme.typography.fontFamily
        font.weight: Theme.typography.weightMedium
        elide: Text.ElideRight
        Layout.fillWidth: true
      }

      Text {
        id: subtitleText
        text: root.subtitle
        color: Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        opacity: 0.8
        elide: Text.ElideRight
        Layout.fillWidth: true
        visible: root.subtitle !== ""
      }
    }
  }

  // ============================================================================
  // INTERACTION
  // ============================================================================

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: (mouse) => {
      if (mouse.button === Qt.RightButton) {
        root.rightClicked()
      } else {
        root.clicked()
      }
    }
  }

}
