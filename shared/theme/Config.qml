pragma Singleton
import QtQuick
import "../../qs/Commons" as QS

QtObject {
  id: root

  readonly property var _s: QS.Settings.data
  readonly property var _a: _s.appearance

  // ============================================================================
  // SCALE RATIO — multiplies all internal design tokens (fonts, spacing, etc.)
  // Panel dimensions (width/height) are NOT scaled — user controls those directly.
  // ============================================================================

  readonly property real scaleRatio: _a.scaleRatio

  // Scale helper: round to nearest int for pixel-perfect rendering
  function _sc(base) { return Math.round(base * scaleRatio) }

  // Force odd number (ensures clean center pixel for icon alignment)
  function toOdd(n) { var r = Math.round(n); return r % 2 === 0 ? r + 1 : r }

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
  // TYPOGRAPHY (fonts from config, sizes scaled by scaleRatio)
  // ============================================================================

  readonly property QtObject typography: QtObject {
    readonly property string sans: root._a.fonts.sans
    readonly property string sansDisplay: root._a.fonts.sansDisplay

    readonly property int xs: root._sc(10)
    property int sm: root._sc(12)
    readonly property int md: root._sc(14)
    readonly property int lg: root._sc(16)
    readonly property int xl: root._sc(18)
    readonly property int xxl: root._sc(24)
    readonly property int xxxl: root._sc(32)

    readonly property int weightNormal: 400
    readonly property int weightMedium: 500
    readonly property int weightBold: 700
  }

  // ============================================================================
  // LAYOUT (scaled design tokens)
  // ============================================================================

  readonly property QtObject spacing: QtObject {
    readonly property int xs: root._sc(4)
    readonly property int sm: root._sc(8)
    readonly property int md: root._sc(12)
    readonly property int lg: root._sc(18)
    readonly property int xl: root._sc(26)
    readonly property int xxl: root._sc(48)
  }

  readonly property QtObject padding: QtObject {
    readonly property int xs: root._sc(4)
    readonly property int sm: root._sc(8)
    readonly property int md: root._sc(12)
    readonly property int lg: root._sc(18)
    readonly property int xl: root._sc(20)
  }

  readonly property QtObject radius: QtObject {
    readonly property int none: 0
    readonly property int sm: root._sc(6)
    readonly property int md: root._sc(12)
    readonly property int lg: root._sc(20)
    readonly property int xl: root._sc(32)
    readonly property int xxl: root._sc(40)
    readonly property int full: 9999
  }

  // ============================================================================
  // COMPONENT SIZES (scaled)
  // ============================================================================

  readonly property QtObject sizes: QtObject {
    // Icon circles
    readonly property int iconCircle: root.toOdd(root._sc(32))
    readonly property int iconCircleLg: root.toOdd(root._sc(40))
    readonly property int iconCircleXl: root.toOdd(root._sc(48))

    // Buttons
    readonly property int buttonHeight: root._sc(40)
    readonly property int buttonHeightLg: root._sc(48)
    readonly property int buttonHeightXl: root._sc(56)

    // Close button
    readonly property int closeButton: root.toOdd(root._sc(32))

    // Segmented button
    readonly property int segmentedWidth: root._sc(200)
    readonly property int segmentedHeight: root._sc(40)

    // Header
    readonly property int headerHeight: root._sc(40)

    // Password dots
    readonly property int dotSize: root._sc(8)
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
  // OSD (scaled internal values)
  // ============================================================================

  readonly property QtObject osd: QtObject {
    readonly property int sliderWidth: root._sc(180)
    readonly property int sliderHeight: root._sc(18)
    readonly property int trackHeight: root._sc(6)
    readonly property int handleSize: root._sc(16)
    readonly property int handleBorderWidth: root._sc(2)
    readonly property int bottomMargin: root._sc(28)
  }

  // ============================================================================
  // SCREENSHOT (scaled internal values)
  // ============================================================================

  readonly property QtObject screenshot: QtObject {
    readonly property int containerWidth: root._sc(300)
    readonly property int containerHeight: root._sc(60)
    readonly property int bottomMargin: root._sc(24)
  }

  // ============================================================================
  // LOCKSCREEN (hardcoded internal values)
  // ============================================================================

  readonly property QtObject lockscreen: QtObject {
    readonly property int fadeInDuration: 800
  }

  // ============================================================================
  // FEATURE PANELS (from config, radius resolved from tokens — NOT scaled)
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
