pragma Singleton
import QtQuick

QtObject {
  // ============================================================================
  // MATUGEN SEMANTIC TOKENS
  // ============================================================================
    
  // --- Primary Colors (Main brand color) ---
  readonly property color primary: "#86d7ad"
  readonly property color on_primary: "#003824"
  readonly property color primary_container: "#005235"
  readonly property color on_primary_container: "#a1f4c8"
  readonly property color primary_fixed: "#a1f4c8"
  readonly property color primary_fixed_dim: "#86d7ad"
  readonly property color on_primary_fixed: "#002113"
  readonly property color on_primary_fixed_variant: "#005235"
    
  // --- Secondary Colors (Supporting color) ---
  readonly property color secondary: "#e0bbdd"
  readonly property color on_secondary: "#412742"
  readonly property color secondary_container: "#593d59"
  readonly property color on_secondary_container: "#fdd7fa"
  readonly property color secondary_fixed: "#fdd7fa"
  readonly property color secondary_fixed_dim: "#e0bbdd"
  readonly property color on_secondary_fixed: "#2a122c"
  readonly property color on_secondary_fixed_variant: "#593d59"
    
  // --- Tertiary Colors (Third accent) ---
  readonly property color tertiary: "#d3bdf5"
  readonly property color on_tertiary: "#382755"
  readonly property color tertiary_container: "#503e6d"
  readonly property color on_tertiary_container: "#ecdcff"
  readonly property color tertiary_fixed: "#ecdcff"
  readonly property color tertiary_fixed_dim: "#d3bdf5"
  readonly property color on_tertiary_fixed: "#23113f"
  readonly property color on_tertiary_fixed_variant: "#503e6d"
    
  // --- Error Colors ---
  readonly property color error: "#ffb4ab"
  readonly property color on_error: "#690005"
  readonly property color error_container: "#93000a"
  readonly property color on_error_container: "#ffdad6"
    
  // --- Background Colors ---
  readonly property color background: "#14121a"
  readonly property color on_background: "#e7e0eb"
    
  // --- Surface Colors (5-level elevation system) ---
  readonly property color surface: "#14121a"
  readonly property color on_surface: "#e7e0eb"
  readonly property color surface_variant: "#494453"
  readonly property color on_surface_variant: "#cbc3d5"
    
  readonly property color surface_dim: "#14121a"
  readonly property color surface_bright: "#3b3840"
  readonly property color surface_container_lowest: "#0f0d14"
  readonly property color surface_container_low: "#1d1a22"
  readonly property color surface_container: "#211e26"
  readonly property color surface_container_high: "#2b2931"
  readonly property color surface_container_highest: "#36333c"
    
  // --- Outline Colors (Borders) ---
  readonly property color outline: "#948e9f"
  readonly property color outline_variant: "#494453"
    
  // --- Inverse Colors (for dark/light theme switching) ---
  readonly property color inverse_surface: "#e7e0eb"
  readonly property color inverse_on_surface: "#322f38"
  readonly property color inverse_primary: "#116c49"
    
  // --- Scrim & Shadow ---
  readonly property color scrim: "#000000"
  readonly property color shadow: "#000000"

  // ============================================================================
  // TRANSPARENT VARIANTS - FOR BLUR EFFECTS
  // ============================================================================
  // Light = 60-65% opacity (subtle blur, good visibility)
  // Medium = 75-80% opacity (balanced blur, most common)
  // Heavy = 90-92% opacity (strong blur, near-opaque)

  // --- Primary Transparencies ---
  readonly property color primary_transparent_light: Qt.rgba(primary.r, primary.g, primary.b, 0.25)
  readonly property color primary_transparent_medium: Qt.rgba(primary.r, primary.g, primary.b, 0.40)
  readonly property color primary_transparent_heavy: Qt.rgba(primary.r, primary.g, primary.b, 0.60)

  // --- Surface Transparencies (for backgrounds) ---
  readonly property color surface_transparent_light: Qt.rgba(surface.r, surface.g, surface.b, 0.50)
  readonly property color surface_transparent_medium: Qt.rgba(surface.r, surface.g, surface.b, 0.70)
  readonly property color surface_transparent_heavy: Qt.rgba(surface.r, surface.g, surface.b, 0.85)

  // --- Surface Container Transparencies (for main panels/popups) ---
  readonly property color surface_container_transparent_light: Qt.rgba(surface_container.r, surface_container.g, surface_container.b, 0.60)
  readonly property color surface_container_transparent_medium: Qt.rgba(surface_container.r, surface_container.g, surface_container.b, 0.75)
  readonly property color surface_container_transparent_heavy: Qt.rgba(surface_container.r, surface_container.g, surface_container.b, 0.90)

  // --- Surface Container Low Transparencies (for lower elevation cards) ---
  readonly property color surface_container_low_transparent_light: Qt.rgba(surface_container_low.r, surface_container_low.g, surface_container_low.b, 0.50)
  readonly property color surface_container_low_transparent_medium: Qt.rgba(surface_container_low.r, surface_container_low.g, surface_container_low.b, 0.65)
  readonly property color surface_container_low_transparent_heavy: Qt.rgba(surface_container_low.r, surface_container_low.g, surface_container_low.b, 0.80)

  // --- Surface Container High Transparencies (for higher elevation cards) ---
  readonly property color surface_container_high_transparent_light: Qt.rgba(surface_container_high.r, surface_container_high.g, surface_container_high.b, 0.70)
  readonly property color surface_container_high_transparent_medium: Qt.rgba(surface_container_high.r, surface_container_high.g, surface_container_high.b, 0.85)
  readonly property color surface_container_high_transparent_heavy: Qt.rgba(surface_container_high.r, surface_container_high.g, surface_container_high.b, 0.95)

  // --- Scrim Transparencies (for modal overlays) ---
  readonly property color scrim_transparent_light: Qt.rgba(scrim.r, scrim.g, scrim.b, 0.15)
  readonly property color scrim_transparent_medium: Qt.rgba(scrim.r, scrim.g, scrim.b, 0.45)
  readonly property color scrim_transparent_heavy: Qt.rgba(scrim.r, scrim.g, scrim.b, 0.65)
    
  // ============================================================================
  // SPACING SYSTEM
  // ============================================================================
    
  readonly property QtObject spacing: QtObject {
    readonly property int xs: 4
    readonly property int sm: 8
    readonly property int md: 12
    readonly property int lg: 18
    readonly property int xl: 26 
    readonly property int xxl: 48
  }
    
  // ============================================================================
  // PADDING SYSTEM
  // ============================================================================
    
  readonly property QtObject padding: QtObject {
    readonly property int xs: 4
    readonly property int sm: 8
    readonly property int md: 12
    readonly property int lg: 18
    readonly property int xl: 20
  }
    
  // ============================================================================
  // TYPOGRAPHY SYSTEM
  // ============================================================================
    
  readonly property QtObject typography: QtObject {
    readonly property string fontFamily: "Google Sans"
    readonly property string fontFamilyDisplay: "Google Sans"
        
    readonly property int xs: 10
    readonly property int sm: 12
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
  // SHAPE SYSTEM (Border Radius)
  // ============================================================================
    
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
  // COMPONENT TOKENS
  // ============================================================================
    
  readonly property QtObject component: QtObject {
    readonly property int barHeight: 26
    readonly property int workspaceIndicatorSize: 10
    readonly property int buttonHeight: 36
    readonly property int inputHeight: 40
  }

  // ============================================================================
  // CONVENIENCE ALIASES
  // ============================================================================
  // Common top-level shortcuts to avoid nested property access

  readonly property string fontFamily: typography.fontFamily
  readonly property int barHeight: component.barHeight
  readonly property int workspaceIndicatorSize: component.workspaceIndicatorSize
}
