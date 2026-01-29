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

  signal searchChanged(string text)

  // ============================================================================
  // APPEARANCE
  // ============================================================================

  radius: Theme.radius.full
  color: Theme.surface_container_low

  border.width: 1
  border.color: Theme.surface_container_high

  // ============================================================================
  // INPUT FIELD
  // ============================================================================

  TextInput {
    id: searchInput
    anchors {
      fill: parent
      leftMargin: Theme.padding.lg
      rightMargin: Theme.padding.lg
    }

    verticalAlignment: TextInput.AlignVCenter
    color: Theme.on_surface
    font.pixelSize: Theme.typography.lg
    font.family: Theme.typography.fontFamilyDisplay

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
