import QtQuick
import Quickshell
import "core" as Core
import "osd"
import "bar"
import "notifications"
import "launcher"
import "notificationcenter"
import "controlcenter"
import "menu"
import "calendar"
import "wallpaper"
import "powermenu"
import "emoji"
import "lockscreen"

ShellRoot {
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
  // CONTROL CENTER
  // ============================================================================
  
  ControlCenterManager {
    id: controlCenterManager
    systemState: systemStateManager
    powerMenuManager: powerMenuManager
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
  
  WallpaperGrid {
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
  // LOCKSCREEN
  // ============================================================================
  
  LockscreenManager {
    id: lockscreenManager
  }
  
  LockscreenDisplay {
    manager: lockscreenManager
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
}
