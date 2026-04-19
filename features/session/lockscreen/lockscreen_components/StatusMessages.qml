import QtQuick
import "../../../../shared/theme"
import "../../../../shared/components/Animations"

Column {
  id: root

  required property bool isAuthenticating
  required property bool errorVisible
  required property string errorText
  required property bool infoVisible
  required property string infoText

  spacing: Config.spacing.sm

  // Info message
  Text {
    id: infoMessage
    anchors.horizontalCenter: parent.horizontalCenter
    text: root.infoText
    color: Theme.on_surface_variant
    font.family: Config.typography.sans
    font.pixelSize: Config.typography.sm
    visible: root.infoVisible && !root.errorVisible
    opacity: visible ? 0.8 : 0

    AFade on opacity {}
  }

  // Error message
  Text {
    id: errorMessage
    anchors.horizontalCenter: parent.horizontalCenter
    text: root.errorText
    color: Theme.error
    font.family: Config.typography.sans
    font.pixelSize: Config.typography.md
    visible: root.errorVisible
    opacity: visible ? 1.0 : 0

    AFade on opacity {}
  }

  // Authenticating indicator
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    text: "󰔟 Authenticating..."
    color: Theme.on_surface_variant
    font.family: Config.typography.sans
    font.pixelSize: Config.typography.sm
    visible: root.isAuthenticating && !root.errorVisible
    opacity: 0.7

    SequentialAnimation on opacity {
      running: root.isAuthenticating && !root.errorVisible
      loops: Animation.Infinite
      NumberAnimation { from: 0.7; to: 0.3; duration: 600; easing.type: Easing.InOutCubic }
      NumberAnimation { from: 0.3; to: 0.7; duration: 600; easing.type: Easing.InOutCubic }
    }
  }
}
