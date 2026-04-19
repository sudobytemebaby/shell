pragma Singleton
import QtQuick

QtObject {
  // ============================================================================
  // MATUGEN COLOR TOKENS
  // ============================================================================

  // --- Primary ---
  readonly property color primary: "#adc6ff"
  readonly property color on_primary: "#102f60"
  readonly property color primary_container: "#2b4678"
  readonly property color on_primary_container: "#d8e2ff"
  readonly property color primary_fixed: "#d8e2ff"
  readonly property color primary_fixed_dim: "#adc6ff"
  readonly property color on_primary_fixed: "#001a41"
  readonly property color on_primary_fixed_variant: "#2b4678"

  // --- Secondary ---
  readonly property color secondary: "#bfc6dc"
  readonly property color on_secondary: "#293041"
  readonly property color secondary_container: "#3f4759"
  readonly property color on_secondary_container: "#dbe2f9"
  readonly property color secondary_fixed: "#dbe2f9"
  readonly property color secondary_fixed_dim: "#bfc6dc"
  readonly property color on_secondary_fixed: "#141b2c"
  readonly property color on_secondary_fixed_variant: "#3f4759"

  // --- Tertiary ---
  readonly property color tertiary: "#debcdf"
  readonly property color on_tertiary: "#402843"
  readonly property color tertiary_container: "#583e5b"
  readonly property color on_tertiary_container: "#fbd7fc"
  readonly property color tertiary_fixed: "#fbd7fc"
  readonly property color tertiary_fixed_dim: "#debcdf"
  readonly property color on_tertiary_fixed: "#29132d"
  readonly property color on_tertiary_fixed_variant: "#583e5b"

  // --- Error ---
  readonly property color error: "#ffb4ab"
  readonly property color on_error: "#690005"
  readonly property color error_container: "#93000a"
  readonly property color on_error_container: "#ffdad6"

  // --- Background ---
  readonly property color background: "#111318"
  readonly property color on_background: "#e2e2e9"

  // --- Surface ---
  readonly property color surface: "#111318"
  readonly property color on_surface: "#e2e2e9"
  readonly property color surface_variant: "#44474f"
  readonly property color on_surface_variant: "#c4c6d0"
  readonly property color surface_dim: "#111318"
  readonly property color surface_bright: "#37393e"
  readonly property color surface_container_lowest: "#0c0e13"
  readonly property color surface_container_low: "#1a1b20"
  readonly property color surface_container: "#1e1f25"
  readonly property color surface_container_high: "#282a2f"
  readonly property color surface_container_highest: "#33353a"

  // --- Outline ---
  readonly property color outline: "#8e9099"
  readonly property color outline_variant: "#44474f"

  // --- Inverse ---
  readonly property color inverse_surface: "#e2e2e9"
  readonly property color inverse_on_surface: "#2f3036"
  readonly property color inverse_primary: "#445e91"

  // --- Scrim & Shadow ---
  readonly property color scrim: "#000000"
  readonly property color shadow: "#000000"

  // ============================================================================
  // TRANSPARENT VARIANTS (used by components, not pane backgrounds)
  // ============================================================================

  readonly property color primary_transparent_medium: Qt.rgba(primary.r, primary.g, primary.b, 0.40)
}
