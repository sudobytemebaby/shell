import QtQuick
import QtQuick.Layouts
import "../../../../shared/components"
import "../../../../shared/theme"

Card {
  id: root
  
  required property var mediaManager
  
  ColumnLayout {
    anchors.fill: parent
    spacing: Theme.spacing.md
    
    // Header row - always visible
    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.spacing.sm
      
      // Status icon
      IconCircle {
        icon: mediaManager.playerActive ? "󰝚" : "󰝛"

        bgColor: mediaManager.playerActive 
                 ? Theme.primary_container 
                 : Theme.surface_container_high
        iconColor: mediaManager.playerActive 
                   ? Theme.primary 
                   : Theme.on_surface_variant
        
        Behavior on bgColor { ColorAnimation { duration: 200 } }
        Behavior on iconColor { ColorAnimation { duration: 200 } }
      }
      
      // Player name and status
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive 
                ? (mediaManager.playerName || "Media Player") 
                : "No Media Playing"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamilyDisplay
          font.weight: Theme.typography.weightMedium
          elide: Text.ElideRight
        }
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive ? "Active" : "Idle"
          color: mediaManager.playerActive ? Theme.primary : Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamilyDisplay
          opacity: 0.8
        }
      }
    }
    
    // Expanded content - only when player is active
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Theme.spacing.sm
      visible: mediaManager.playerActive
      opacity: mediaManager.playerActive ? 1 : 0
      
      Behavior on opacity { 
        NumberAnimation { duration: 250 } 
      }
      
      // Title & Artist
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerTitle || "Unknown Title"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.lg
          font.family: Theme.typography.fontFamily
          font.weight: Theme.typography.weightMedium
          elide: Text.ElideRight
        }
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerArtist || "Unknown Artist"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamily
          elide: Text.ElideRight
        }
      }
      
      // Progress slider + time
      RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm
        
        Text {
          text: mediaManager.formatTime(mediaManager.playerPosition)
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
        }
        
        HorizontalSlider {
          id: positionSlider
          Layout.fillWidth: true
          
          minimumValue: 0
          maximumValue: mediaManager.playerLength > 0 ? mediaManager.playerLength : 100
          value: mediaManager.playerPosition
          
          // Only update slider from player when not being dragged
          Binding {
            target: positionSlider
            property: "value"
            value: mediaManager.playerPosition
            when: !positionSlider.pressed
          }
          
          onMoved: newValue => {
            // Seek when user drags the slider
            mediaManager.playerSeek(newValue)
          }
        }
        
        Text {
          text: mediaManager.formatTime(mediaManager.playerLength)
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
        }
      }
      
      // Control buttons - centered
      RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spacing.lg
        
        RoundIconButton {
          icon: "󰒮"
          onClicked: mediaManager.playerPrevious()
        }
        
        RoundIconButton {
          icon: mediaManager.playerPlaying ? "󰏤" : "󰼛"
          isPrimary: true
          onClicked: mediaManager.playerPlayPause()
        }
        
        RoundIconButton {
          icon: "󰒭"
          onClicked: mediaManager.playerNext()
        }
      }
    }
  }
}
