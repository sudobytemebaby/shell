import QtQuick
import Quickshell
import "../../../../shared/theme"

// ============================================================================
// WALLPAPER BACKGROUND
// Displays the wallpaper image with gradient overlay
// Matches noctalia's approach - NO BLUR, just gradient darkening
// Wallpaper path is preloaded by manager for instant display
// ============================================================================

Item {
  id: root

  required property string wallpaperPath
  readonly property bool hasWallpaper: wallpaperPath !== ""
  readonly property bool wallpaperReady: hasWallpaper && wallpaperImage.status === Image.Ready

  // ============================================================================
  // FALLBACK BACKGROUND (shows while wallpaper loads or if missing)
  // Pure black to match the lockscreen surface color
  // ============================================================================

  Rectangle {
    anchors.fill: parent
    color: "#000000"
    opacity: (!root.hasWallpaper || wallpaperImage.status !== Image.Ready) ? 1.0 : 0.0

    Behavior on opacity {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
    }
  }

  // ============================================================================
  // WALLPAPER IMAGE (no blur, just as-is)
  // Loads immediately when path is available
  // ============================================================================

  Image {
    id: wallpaperImage
    anchors.fill: parent
    source: root.wallpaperPath
    fillMode: Image.PreserveAspectCrop
    visible: root.hasWallpaper
    opacity: 0
    cache: true
    asynchronous: true  // Image is preloaded by manager, so cache hit = instant
    smooth: true
    mipmap: false
    antialiasing: true

    // Smooth fade-in animation
    Behavior on opacity {
      NumberAnimation {
        duration: 600
        easing.type: Easing.OutCubic
      }
    }

    onStatusChanged: {
      if (status === Image.Error) {
        console.error("[WallpaperBackground] Failed to load wallpaper image")
      } else if (status === Image.Ready) {
        opacity = 1.0
      }
    }
  }

  // ============================================================================
  // GRADIENT OVERLAY (noctalia's exact approach)
  // Creates depth and ensures text contrast without blurring
  // ============================================================================

  Rectangle {
    id: gradientOverlay
    anchors.fill: parent
    visible: root.hasWallpaper
    opacity: wallpaperImage.status === Image.Ready ? 1.0 : 0.0

    gradient: Gradient {
      // Top - darkest for time display area
      GradientStop {
        position: 0.0
        color: Qt.rgba(0, 0, 0, 0.8)  // 80% black overlay
      }

      // Upper-middle - lighter
      GradientStop {
        position: 0.3
        color: Qt.rgba(0, 0, 0, 0.4)  // 40% black overlay
      }

      // Lower-middle - slightly darker
      GradientStop {
        position: 0.7
        color: Qt.rgba(0, 0, 0, 0.5)  // 50% black overlay
      }

      // Bottom - darkest for password input area
      GradientStop {
        position: 1.0
        color: Qt.rgba(0, 0, 0, 0.9)  // 90% black overlay
      }
    }

    // Smooth fade-in animation
    Behavior on opacity {
      NumberAnimation {
        duration: 400
        easing.type: Easing.OutCubic
      }
    }
  }
}
