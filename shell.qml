import QtQuick
import Quickshell
import "core/system_state" as Core
import "core/services" as Services
import "features/shell_chrome/osd"
import "features/shell_chrome/bar"
import "features/notifications"
import "features/launchers/launcher"
import "features/system_panels/controlcenter"
import "features/launchers/menu"
import "features/system_panels/calendar"
import "features/launchers/wallpaper"
import "features/session/powermenu"
import "features/launchers/emoji"
import "features/session/lockscreen"
import "features/session/screenshot"
import "features/session/screenrec"
import "features/session/matugen"
import "features/weather"

ShellRoot {
  // ============================================================================
  // CONFIG RELOAD HANDLING
  // ============================================================================

  // Suppress the default "CONFIG RELOADED" popup notification
  // This prevents the reload popup from blocking other notifications (OSD, matugen, etc.)
  Connections {
    target: Quickshell

    function onReloadCompleted() {
      Quickshell.inhibitReloadPopup()
      console.log("[Shell] Config reloaded successfully (popup suppressed)")
    }

    function onReloadFailed(error) {
      Quickshell.inhibitReloadPopup()
      console.error("[Shell] Config reload failed:", error)
    }
  }

  // ============================================================================
  // SYSTEM STATE - Single Source of Truth
  // ============================================================================

  Core.SystemStateManager {
    id: systemStateManager
  }
  
  // ============================================================================
  // POWER MENU
  // ============================================================================
  
  PowerMenuManager {
    id: powerMenuManager
  }
  
  PowerMenuDisplay {
    manager: powerMenuManager
  }

  // ============================================================================
  // SCREENSHOT MENU
  // ============================================================================

  ScreenshotManager {
    id: screenshotManager
  }

  ScreenshotDisplay {
    manager: screenshotManager
  }

  // ============================================================================
  // SCREEN RECORDING MENU
  // ============================================================================

  ScreenRecordingManager {
    id: screenRecordingManager
  }

  ScreenRecordingDisplay {
    manager: screenRecordingManager
  }

  // ============================================================================
  // MATUGEN COLOR SCHEME MENU
  // ============================================================================

  MatugenManager {
    id: matugenManager
  }

  MatugenDisplay {
    manager: matugenManager
  }

  // ============================================================================
  // CONTROL CENTER
  // ============================================================================

  ControlCenterManager {
    id: controlCenterManager
    systemState: systemStateManager
    matugen: matugenManager
  }

  ControlCenterDisplay {
    manager: controlCenterManager
    systemState: systemStateManager
  }
  
  // ============================================================================
  // OSD SYSTEM
  // ============================================================================
  
  OsdManager {
    id: osdManager
    systemState: systemStateManager
  }
  
  OsdDisplay {
    manager: osdManager
  }

  // ============================================================================
  // NOTIFICATION SYSTEM
  // ============================================================================
  
  NotificationCenterManager {
    id: notificationCenterManager
  }
  
  NotificationCenterDisplay {
    manager: notificationCenterManager
  }
  
  NotificationManager {
    id: notificationManager
    notificationCenterManager: notificationCenterManager
  }
  
  NotificationDisplay {
    manager: notificationManager
  }
  
  // ============================================================================
  // LAUNCHER
  // ============================================================================
  
  LauncherManager {
    id: launcherManager
  }
  
  LauncherDisplay {
    manager: launcherManager
  }
  
  // ============================================================================
  // WALLPAPER
  // ============================================================================
  
  WallpaperManager {
    id: wallpaperManager
  }
  
  WallpaperDisplay {
    manager: wallpaperManager
  }
  
  // ============================================================================
  // EMOJI PICKER
  // ============================================================================
  
  EmojiManager {
    id: emojiManager
  }
  
  EmojiDisplay {
    manager: emojiManager
  }
  
  // ============================================================================
  // MENU
  // ============================================================================
  
  MenuManager {
    id: menuManager
    launcherManager: launcherManager
    wallpaperManager: wallpaperManager
    powerMenuManager: powerMenuManager
    emojiManager: emojiManager
    lockscreenManager: lockscreenManager
    screenshotManager: screenshotManager
    screenRecordingManager: screenRecordingManager
    weatherManager: weatherManager
    matugenManager: matugenManager
  }
  
  MenuDisplay {
    manager: menuManager
  }
  
  // ============================================================================
  // CALENDAR
  // ============================================================================
  
  CalendarManager {
    id: calendarManager
  }
  
  CalendarDisplay {
    manager: calendarManager
  }

  // ============================================================================
  // WEATHER WIDGET
  // ============================================================================

  WeatherManager {
    id: weatherManager
  }

  WeatherDisplay {
    manager: weatherManager
  }

  // ============================================================================
  // LOCKSCREEN
  // ============================================================================

  LockscreenManager {
    id: lockscreenManager
  }

  LockscreenDisplay {
    manager: lockscreenManager
    systemState: systemStateManager
  }

  // ============================================================================
  // BAR
  // ============================================================================
  
  Bar {
    id: bar
    controlCenterManager: controlCenterManager
    notificationCenterManager: notificationCenterManager
    calendarManager: calendarManager
    systemState: systemStateManager
  }
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    // Initialize BatteryNotifier singleton with dependencies
    Services.BatteryNotifier.systemState = systemStateManager
    Services.BatteryNotifier.notificationManager = notificationManager
  }
}
