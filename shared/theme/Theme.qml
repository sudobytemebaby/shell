pragma Singleton
import QtQuick

QtObject {
  // ============================================================================
  // MATUGEN SEMANTIC TOKENS
  // ============================================================================
    
  // --- Primary Colors (Main brand color) ---
  readonly property color primary: "#80d4db"
  readonly property color on_primary: "#00363a"
  readonly property color primary_container: "#004f54"
  readonly property color on_primary_container: "#9df0f8"
  readonly property color primary_fixed: "#9df0f8"
  readonly property color primary_fixed_dim: "#80d4db"
  readonly property color on_primary_fixed: "#002022"
  readonly property color on_primary_fixed_variant: "#004f54"
    
  // --- Secondary Colors (Supporting color) ---
  readonly property color secondary: "#b1cbce"
  readonly property color on_secondary: "#1b3436"
  readonly property color secondary_container: "#324b4d"
  readonly property color on_secondary_container: "#cce8ea"
  readonly property color secondary_fixed: "#cce8ea"
  readonly property color secondary_fixed_dim: "#b1cbce"
  readonly property color on_secondary_fixed: "#051f21"
  readonly property color on_secondary_fixed_variant: "#324b4d"
    
  // --- Tertiary Colors (Third accent) ---
  readonly property color tertiary: "#b7c7ea"
  readonly property color on_tertiary: "#21304c"
  readonly property color tertiary_container: "#374764"
  readonly property color on_tertiary_container: "#d7e2ff"
  readonly property color tertiary_fixed: "#d7e2ff"
  readonly property color tertiary_fixed_dim: "#b7c7ea"
  readonly property color on_tertiary_fixed: "#0a1b36"
  readonly property color on_tertiary_fixed_variant: "#374764"
    
  // --- Error Colors ---
  readonly property color error: "#ffb4ab"
  readonly property color on_error: "#690005"
  readonly property color error_container: "#93000a"
  readonly property color on_error_container: "#ffdad6"
    
  // --- Background Colors ---
  readonly property color background: "#0e1415"
  readonly property color on_background: "#dde4e4"
    
  // --- Surface Colors (5-level elevation system) ---
  readonly property color surface: "#0e1415"
  readonly property color on_surface: "#dde4e4"
  readonly property color surface_variant: "#3f4849"
  readonly property color on_surface_variant: "#bec8c9"
    
  readonly property color surface_dim: "#0e1415"
  readonly property color surface_bright: "#343a3b"
  readonly property color surface_container_lowest: "#090f10"
  readonly property color surface_container_low: "#161d1d"
  readonly property color surface_container: "#1a2121"
  readonly property color surface_container_high: "#252b2c"
  readonly property color surface_container_highest: "#303636"
    
  // --- Outline Colors (Borders) ---
  readonly property color outline: "#899393"
  readonly property color outline_variant: "#3f4849"
    
  // --- Inverse Colors (for dark/light theme switching) ---
  readonly property color inverse_surface: "#dde4e4"
  readonly property color inverse_on_surface: "#2b3232"
  readonly property color inverse_primary: "#006970"
    
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
