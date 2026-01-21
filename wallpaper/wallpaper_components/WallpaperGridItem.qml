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
      margins: Theme.spacing.xs
    }
    radius: Theme.radius.md

    color: {
      if (root.isSelected && !root.isCurrent) return Theme.surface_container_high
      if (itemMouseArea.containsMouse && !root.isCurrent) return Theme.surface_container
      return "transparent"
    }

    border.width: (root.isSelected && !root.isCurrent) ? 2 : 0
    border.color: root.isSelected ? Theme.primary : "transparent"

    scale: itemMouseArea.pressed ? 0.96 : 1.0
    
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
    
    // ======================================================================
    // IMAGE PREVIEW (Using NImageRounded with ImageCacheService)
    // ======================================================================

    NImageRounded {
      id: imagePreview
      anchors {
        fill: parent
        margins: Theme.spacing.xs
      }
      radius: Theme.radius.md
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
        bottom: imagePreview.bottom
        right: imagePreview.right
        margins: Theme.spacing.sm
      }
      width: 28
      height: 28
      radius: Theme.radius.full
      color: Theme.primary
      visible: root.isCurrent

      scale: root.isCurrent ? 1.0 : 0.8
      opacity: root.isCurrent ? 0.95 : 0.0

      Behavior on scale {
        NumberAnimation {
          duration: 300
          easing.type: Easing.OutBack
          easing.overshoot: 1.5
        }
      }

      Behavior on opacity {
        NumberAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }

      Text {
        anchors.centerIn: parent
        text: "✓"
        color: Theme.on_primary
        font.pixelSize: Theme.typography.sm
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
        margins: Theme.spacing.sm
      }
      width: 28
      height: 28
      radius: Theme.radius.full
      color: Theme.primary
      visible: root.isSelected && !root.isCurrent

      scale: root.isSelected && !root.isCurrent ? 1.0 : 0.8
      opacity: root.isSelected && !root.isCurrent ? 0.9 : 0.0

      Behavior on scale {
        NumberAnimation {
          duration: 300
          easing.type: Easing.OutBack
          easing.overshoot: 1.5
        }
      }

      Behavior on opacity {
        NumberAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }

      Text {
        anchors.centerIn: parent
        text: "→"
        color: Theme.on_primary
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        font.weight: Theme.typography.weightMedium
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
