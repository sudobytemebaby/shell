pragma Singleton
import QtQuick

QtObject {
  // ============================================================================
  // MATUGEN SEMANTIC TOKENS
  // ============================================================================
    
  // --- Primary Colors (Main brand color) ---
  readonly property color primary: "#b1c5ff"
  readonly property color on_primary: "#182e5e"
  readonly property color primary_container: "#4c6093"
  readonly property color on_primary_container: "#ffffff"
  readonly property color primary_fixed: "#dae2ff"
  readonly property color primary_fixed_dim: "#b1c5ff"
  readonly property color on_primary_fixed: "#001947"
  readonly property color on_primary_fixed_variant: "#314576"
    
  // --- Secondary Colors (Supporting color) ---
  readonly property color secondary: "#bfc6df"
  readonly property color on_secondary: "#293044"
  readonly property color secondary_container: "#3f465b"
  readonly property color on_secondary_container: "#d9dff9"
  readonly property color secondary_fixed: "#dbe2fc"
  readonly property color secondary_fixed_dim: "#bfc6df"
  readonly property color on_secondary_fixed: "#141b2e"
  readonly property color on_secondary_fixed_variant: "#3f465b"
    
  // --- Tertiary Colors (Third accent) ---
  readonly property color tertiary: "#eeb4e6"
  readonly property color on_tertiary: "#4a2049"
  readonly property color tertiary_container: "#81517d"
  readonly property color on_tertiary_container: "#ffffff"
  readonly property color tertiary_fixed: "#ffd6f7"
  readonly property color tertiary_fixed_dim: "#eeb4e6"
  readonly property color on_tertiary_fixed: "#320a33"
  readonly property color on_tertiary_fixed_variant: "#633761"
    
  // --- Error Colors ---
  readonly property color error: "#ffb4ab"
  readonly property color on_error: "#690005"
  readonly property color error_container: "#93000a"
  readonly property color on_error_container: "#ffdad6"
    
  // --- Background Colors ---
  readonly property color background: "#121317"
  readonly property color on_background: "#e3e2e6"
    
  // --- Surface Colors (5-level elevation system) ---
  readonly property color surface: "#121317"
  readonly property color on_surface: "#e3e2e6"
  readonly property color surface_variant: "#44464f"
  readonly property color on_surface_variant: "#c5c6d0"
    
  readonly property color surface_dim: "#121317"
  readonly property color surface_bright: "#38393d"
  readonly property color surface_container_lowest: "#0d0e11"
  readonly property color surface_container_low: "#1b1b1f"
  readonly property color surface_container: "#1f1f23"
  readonly property color surface_container_high: "#292a2d"
  readonly property color surface_container_highest: "#343438"
    
  // --- Outline Colors (Borders) ---
  readonly property color outline: "#8f909a"
  readonly property color outline_variant: "#44464f"
    
  // --- Inverse Colors (for dark/light theme switching) ---
  readonly property color inverse_surface: "#e3e2e6"
  readonly property color inverse_on_surface: "#303034"
  readonly property color inverse_primary: "#495d90"
    
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
