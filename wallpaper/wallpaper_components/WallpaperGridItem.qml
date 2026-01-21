import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../components/Display"
import "../../services"

Item {
  id: root

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  property string filename: ""
  property int itemIndex: 0
  property bool isSelected: false
  property bool isCurrent: false
  property string wallpaperPath: ""
  property string thumbnailPath: ""

  // ============================================================================
  // INTERNAL STATE
  // ============================================================================

  property string cachedThumbnailPath: ""

  signal clicked()
  
  // ============================================================================
  // MAIN CONTAINER
  // ============================================================================
  
  Rectangle {
    anchors {
      fill: parent
      margins: Theme.spacing.sm
    }
    radius: Theme.radius.xl
    
    color: {
      if (root.isSelected) return Theme.primary_container
      if (itemMouseArea.containsMouse) return Theme.surface_container_high
      return Theme.surface_container
    }
    
    border.width: root.isCurrent ? 3 : (root.isSelected ? 2 : 1)
    border.color: {
      if (root.isCurrent) return Theme.primary
      if (root.isSelected) return Theme.primary
      return Theme.surface_container_high
    }
    
    scale: itemMouseArea.pressed ? 0.95 : 1.0
    
    Behavior on color {
      ColorAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
    
    Behavior on border.color {
      ColorAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
    
    Behavior on border.width {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
    
    Behavior on scale {
      NumberAnimation {
        duration: 100
        easing.type: Easing.OutCubic
      }
    }
    
    ColumnLayout {
      anchors {
        fill: parent
        margins: Theme.spacing.sm
      }
      spacing: Theme.spacing.sm
      
      // ======================================================================
      // IMAGE PREVIEW (Using NImageRounded with ImageCacheService)
      // ======================================================================

      NImageRounded {
        id: imagePreview
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: Theme.spacing.sm
        radius: Theme.radius.lg
        imagePath: root.cachedThumbnailPath !== "" ? "file://" + root.cachedThumbnailPath : ""
        fallbackIcon: "󰸉"
        borderWidth: 0
        imageFillMode: Image.PreserveAspectCrop
      }


      // ======================================================================
      // CURRENT WALLPAPER BADGE
      // ======================================================================

      Rectangle {
        anchors {
          top: imagePreview.top
          right: imagePreview.right
          margins: Theme.spacing.md
        }
        width: 32
        height: 32
        radius: Theme.radius.full
        color: Theme.primary
        visible: root.isCurrent

        scale: root.isCurrent ? 1.0 : 0.8
        opacity: root.isCurrent ? 1.0 : 0.0

        Behavior on scale {
          NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
            easing.overshoot: 2
          }
        }

        Behavior on opacity {
          NumberAnimation {
            duration: 200
          }
        }

        Text {
          anchors.centerIn: parent
          text: "✓"
          color: Theme.on_primary
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamily
          font.weight: Theme.typography.weightMedium
        }
      }

      // ======================================================================
      // SELECTED INDICATOR (keyboard nav)
      // ======================================================================

      Rectangle {
        anchors {
          top: imagePreview.top
          left: imagePreview.left
          margins: Theme.spacing.md
        }
        width: 32
        height: 32
        radius: Theme.radius.full
        color: Theme.primary
        visible: root.isSelected && !root.isCurrent

        scale: root.isSelected && !root.isCurrent ? 1.0 : 0.8
        opacity: root.isSelected && !root.isCurrent ? 1.0 : 0.0

        Behavior on scale {
          NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
            easing.overshoot: 2
          }
        }

        Behavior on opacity {
          NumberAnimation {
            duration: 200
          }
        }

        Text {
          anchors.centerIn: parent
          text: "→"
          color: Theme.on_primary
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamily
          font.weight: Theme.typography.weightMedium
        }
      }
      
      // ======================================================================
      // FILENAME
      // ======================================================================
      
      Text {
        Layout.fillWidth: true
        text: root.filename
        color: {
          if (root.isCurrent) return Theme.primary
          if (root.isSelected) return Theme.on_primary_container
          return Theme.on_surface
        }
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        font.weight: {
          if (root.isCurrent || root.isSelected) return Theme.typography.weightMedium
          return Theme.typography.weightNormal
        }
        elide: Text.ElideMiddle
        horizontalAlignment: Text.AlignHCenter
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
    }
    
    // ========================================================================
    // INTERACTION
    // ========================================================================
    
    MouseArea {
      id: itemMouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor

      onClicked: {
        root.clicked()
      }
    }
  }

  // ============================================================================
  // THUMBNAIL LOADING
  // ============================================================================

  Component.onCompleted: {
    if (ImageCacheService.initialized) {
      ImageCacheService.getThumbnail(root.wallpaperPath, function(path, success) {
        if (success) {
          root.cachedThumbnailPath = path
        } else {
          // Fallback to original wallpaper path
          root.cachedThumbnailPath = root.wallpaperPath
        }
      })
    } else {
      // Service not initialized yet, use original path
      root.cachedThumbnailPath = root.wallpaperPath
    }
  }
}
