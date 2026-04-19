pragma Singleton
import QtQuick

QtObject {
  // --- Primary Colors ---
  readonly property color primary: "#b6c4ff"
  readonly property color on_primary: "#1e2d61"
  readonly property color primary_container: "#354479"
  readonly property color on_primary_container: "#dce1ff"
  readonly property color primary_fixed: "#dce1ff"
  readonly property color primary_fixed_dim: "#b6c4ff"
  readonly property color on_primary_fixed: "#04164b"
  readonly property color on_primary_fixed_variant: "#354479"
    
  // --- Secondary Colors ---
  readonly property color secondary: "#c2c5dd"
  readonly property color on_secondary: "#2b3042"
  readonly property color secondary_container: "#424659"
  readonly property color on_secondary_container: "#dee1f9"
  readonly property color secondary_fixed: "#dee1f9"
  readonly property color secondary_fixed_dim: "#c2c5dd"
  readonly property color on_secondary_fixed: "#161b2c"
  readonly property color on_secondary_fixed_variant: "#424659"
    
  // --- Tertiary Colors ---
  readonly property color tertiary: "#e3bada"
  readonly property color on_tertiary: "#43273f"
  readonly property color tertiary_container: "#5b3d57"
  readonly property color on_tertiary_container: "#ffd7f5"
  readonly property color tertiary_fixed: "#ffd7f5"
  readonly property color tertiary_fixed_dim: "#e3bada"
  readonly property color on_tertiary_fixed: "#2c1229"
  readonly property color on_tertiary_fixed_variant: "#5b3d57"
    
  // --- Error Colors ---
  readonly property color error: "#ffb4ab"
  readonly property color on_error: "#690005"
  readonly property color error_container: "#93000a"
  readonly property color on_error_container: "#ffdad6"
    
  // --- Background Colors ---
  readonly property color background: "#121318"
  readonly property color on_background: "#e3e1e9"
    
  // --- Surface Colors ---
  readonly property color surface: "#121318"
  readonly property color on_surface: "#e3e1e9"
  readonly property color surface_variant: "#45464f"
  readonly property color on_surface_variant: "#c6c5d0"
  readonly property color surface_dim: "#121318"
  readonly property color surface_bright: "#38393f"
  readonly property color surface_container_lowest: "#0d0e13"
  readonly property color surface_container_low: "#1a1b21"
  readonly property color surface_container: "#1e1f25"
  readonly property color surface_container_high: "#292a2f"
  readonly property color surface_container_highest: "#34343a"
    
  // --- Outline Colors ---
  readonly property color outline: "#90909a"
  readonly property color outline_variant: "#45464f"
    
  // --- Inverse Colors ---
  readonly property color inverse_surface: "#e3e1e9"
  readonly property color inverse_on_surface: "#2f3036"
  readonly property color inverse_primary: "#4d5c92"
    
  // --- Scrim & Shadow ---
  readonly property color scrim: "#000000"
  readonly property color shadow: "#000000"
}
