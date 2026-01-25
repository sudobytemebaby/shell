import QtQuick
import Quickshell
import "../../../../core/system_state" as Core

Scope {
  id: manager
  
  // ========== LAUNCHER FUNCTIONS ==========
  // These functions simply launch external applications or scripts.
  
  function launchColorPicker() {
    Core.ProcessUtils.runCommandAsync(manager, ["hyprpicker", "-a"])
  }
  
  function takeScreenshot() {
    Core.ProcessUtils.runCommandAsync(manager, ["hyprshot", "-m", "region"])
  }
  
  function openClipboard() {
    Core.ProcessUtils.runCommandAsync(manager, ["kitty", "--class", "floating_term_s", "-e", "clipse"])
  }
  
  function updateTheme() {
    Core.ProcessUtils.runCommandAsync(manager, ["update-matugen"])
  }
}
