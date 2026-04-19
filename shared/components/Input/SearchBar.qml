import QtQuick
import "../../theme"
import "../"

// Unified SearchBar Component
// Consolidates: LauncherSearchBar, EmojiSearchBar, MenuSearchBar, WallpaperSearchBar
Rectangle {
  id: root

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  property string placeholder: "Search..."
  property alias text: searchInput.text
  property int debounceInterval: 0  // 0 = no debounce, >0 = debounce in ms
  property bool showElevation: true
  property bool autoFocus: true
  property bool forwardNavigationKeys: false  // When true, navigation keys are forwarded instead of handled

  signal searchChanged(string text)
  signal navigationKeyPressed(var event)  // Emitted when navigation keys are pressed (if forwardNavigationKeys is true)

  // ============================================================================
  // APPEARANCE
  // ============================================================================

  radius: Config.radius.full
  color: Theme.surface_container

  border.width: 0
  border.color: Theme.surface_container_highest

  // ============================================================================
  // INPUT FIELD
  // ============================================================================

  TextInput {
    id: searchInput
    anchors {
      fill: parent
      leftMargin: Config.padding.lg
      rightMargin: Config.padding.lg
    }

    verticalAlignment: TextInput.AlignVCenter
    color: Theme.on_surface
    font.pixelSize: Config.typography.lg
    font.family: Config.typography.sans

    // Placeholder text
    Text {
      anchors.fill: parent
      text: root.placeholder
      color: Theme.on_surface_variant
      font: parent.font
      verticalAlignment: Text.AlignVCenter
      visible: !parent.text
      opacity: 0.6
    }

    onTextChanged: {
      if (root.debounceInterval > 0) {
        debounceTimer.restart()
      } else {
        root.searchChanged(text)
      }
    }

    // Forward navigation keys when enabled
    Keys.onPressed: event => {
      if (root.forwardNavigationKeys) {
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down ||
            event.key === Qt.Key_Left || event.key === Qt.Key_Right ||
            event.key === Qt.Key_Return || event.key === Qt.Key_Enter ||
            event.key === Qt.Key_Escape) {
          root.navigationKeyPressed(event)
          event.accepted = true
        }
      }
    }

    Component.onCompleted: {
      if (root.autoFocus) {
        forceActiveFocus()
      }
    }
  }

  // ============================================================================
  // DEBOUNCE TIMER (Optional)
  // ============================================================================

  Timer {
    id: debounceTimer
    interval: root.debounceInterval
    repeat: false
    onTriggered: root.searchChanged(searchInput.text)
  }
}
