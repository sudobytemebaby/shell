pragma Singleton
import QtQuick
import "../../qs/Commons" as QS

QtObject {
  id: root

  readonly property var _s: QS.Settings.data
  readonly property var _a: _s.appearance

  // ============================================================================
  // TOKEN RESOLVER
  // ============================================================================

  readonly property var _radiusMap: ({
    "none": 0, "sm": 6, "md": 12, "lg": 20, "xl": 32, "xxl": 40, "full": 9999
  })

  function resolveRadius(token) {
    return _radiusMap[token] ?? 0
  }

  // ============================================================================
  // TYPOGRAPHY (fonts from config, sizes/weights are internal design tokens)
  // ============================================================================

  readonly property QtObject typography: QtObject {
    readonly property string sans: root._a.fonts.sans
    readonly property string sansDisplay: root._a.fonts.sansDisplay

    readonly property int xs: 10
    property int sm: 12
    readonly property int md: 14
    readonly property int lg: 16
    readonly property int xl: 18
    readonly property int xxl: 24
    readonly property int xxxl: 32

    readonly property int weightNormal: 400
    readonly property int weightMedium: 500
    readonly property int weightBold: 700
  }

  // ============================================================================
  // LAYOUT (internal design tokens)
  // ============================================================================

  readonly property QtObject spacing: QtObject {
    readonly property int xs: 4
    readonly property int sm: 8
    readonly property int md: 12
    readonly property int lg: 18
    readonly property int xl: 26
    readonly property int xxl: 48
  }

  readonly property QtObject padding: QtObject {
    readonly property int xs: 4
    readonly property int sm: 8
    readonly property int md: 12
    readonly property int lg: 18
    readonly property int xl: 20
  }

  readonly property QtObject radius: QtObject {
    readonly property int none: 0
    readonly property int sm: 6
    readonly property int md: 12
    readonly property int lg: 20
    readonly property int xl: 32
    readonly property int xxl: 40
    readonly property int full: 9999
  }

  // ============================================================================
  // ANIMATIONS (durations scaled by config speed, 0 when disabled)
  // ============================================================================

  readonly property QtObject animations: QtObject {
    readonly property bool disabled: root._s.animations.disabled
    readonly property real speed: root._s.animations.speed

    function _d(ms) { return disabled ? 0 : Math.round(ms / speed) }

    readonly property int fastest: _d(50)
    readonly property int fast: _d(100)
    readonly property int normal: _d(150)
    readonly property int slow: _d(200)
    readonly property int slower: _d(300)
    readonly property int slowest: _d(600)
    readonly property int verySlow: _d(800)
  }

  // ============================================================================
  // SHADOWS (from config)
  // ============================================================================

  readonly property var shadows: root._s.shadows

  // ============================================================================
  // PANE APPEARANCE
  // ============================================================================

  readonly property real paneBorderWidth: 0.5

  // Transparency level: "none", "light", "medium", "heavy"
  readonly property string _transparency: root._a.transparency
  readonly property color paneBackground: {
    var s = Theme.surface
    switch (_transparency) {
      case "none":   return s
      case "light":  return Qt.rgba(s.r, s.g, s.b, 0.50)
      case "heavy":  return Qt.rgba(s.r, s.g, s.b, 0.85)
      default:       return Qt.rgba(s.r, s.g, s.b, 0.70) // medium
    }
  }

  // ============================================================================
  // BAR (from config)
  // ============================================================================

  readonly property QtObject bar: QtObject {
    readonly property int height: root._s.bar.height
  }

  // ============================================================================
  // OSD (hardcoded internal values)
  // ============================================================================

  readonly property QtObject osd: QtObject {
    readonly property int sliderWidth: 180
    readonly property int sliderHeight: 18
    readonly property int trackHeight: 6
    readonly property int handleSize: 16
    readonly property int handleBorderWidth: 2
    readonly property int bottomMargin: 28
  }

  // ============================================================================
  // SCREENSHOT (hardcoded internal values)
  // ============================================================================

  readonly property QtObject screenshot: QtObject {
    readonly property int containerWidth: 300
    readonly property int containerHeight: 60
    readonly property int bottomMargin: 24
  }

  // ============================================================================
  // LOCKSCREEN (hardcoded internal values)
  // ============================================================================

  readonly property QtObject lockscreen: QtObject {
    readonly property int fadeInDuration: 800
  }

  // ============================================================================
  // FEATURE PANELS (from config, radius resolved from tokens)
  // ============================================================================

  readonly property QtObject controlCenter: QtObject {
    readonly property var _raw: root._s.controlCenter
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int posX: _raw.posX
    readonly property int posY: _raw.posY
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject calendar: QtObject {
    readonly property var _raw: root._s.calendar
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int posY: _raw.posY
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject notificationCenter: QtObject {
    readonly property var _raw: root._s.notificationCenter
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int marginFromEdge: _raw.marginFromEdge
    readonly property int posY: _raw.posY
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject launcher: QtObject {
    readonly property var _raw: root._s.launcher
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject menu: QtObject {
    readonly property var _raw: root._s.menu
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject wallpaperPicker: QtObject {
    readonly property var _raw: root._s.wallpaperPicker
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject emojiPicker: QtObject {
    readonly property var _raw: root._s.emojiPicker
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject powerMenu: QtObject {
    readonly property var _raw: root._s.powerMenu
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject screenRecording: QtObject {
    readonly property var _raw: root._s.screenRecording
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject matugen: QtObject {
    readonly property var _raw: root._s.matugen
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int radius: root.resolveRadius(_raw.radius)
  }

  readonly property QtObject weather: QtObject {
    readonly property var _raw: root._s.weather
    readonly property int width: _raw.width
    readonly property int height: _raw.height
    readonly property int radius: root.resolveRadius(_raw.radius)
  }
}
