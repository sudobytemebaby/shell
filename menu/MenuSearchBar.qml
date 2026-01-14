import QtQuick
import "../theme"
import "../components"

Rectangle {
  id: root
  
  property alias text: searchInput.text
  signal searchChanged(string text)
  
  radius: Theme.radius.full
  color: Theme.surface_container

  border.width: 1
  border.color: Theme.surface_container_high

  Elevation {
    visible: false 
  }
  
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
    font.family: Theme.typography.fontFamily
    
    // Placeholder text
    Text {
      anchors.fill: parent
      text: "Search menu..."
      color: Theme.on_surface_variant
      font: parent.font
      verticalAlignment: Text.AlignVCenter
      visible: !parent.text
      opacity: 0.6
    }
    
    onTextChanged: {
      root.searchChanged(text)
    }
    
    Component.onCompleted: {
      forceActiveFocus()
    }
  }
}
