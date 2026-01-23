import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../shared/theme"
import "../../../shared/components/Lists"

/**
 * LauncherAppList
 *
 * Application list component for the launcher system.
 *
 * ARCHITECTURE:
 * This component handles the application list display, filtering, navigation,
 * and launching logic. It's separated from LauncherDisplay.qml to maintain
 * a clean separation of concerns.
 *
 * RESPONSIBILITIES:
 * - Filter desktop applications based on search term
 * - Display filtered applications in a scrollable list
 * - Handle keyboard navigation (index management)
 * - Launch applications with fallback mechanism
 * - Show empty state when no apps match search
 *
 * DATA SOURCE:
 * Uses DesktopEntries.applications.values to get all installed desktop
 * applications. Filters out hidden apps and matches against name and comment.
 *
 * LAUNCH MECHANISM:
 * 1. Try app.execute() first (native desktop entry execution)
 * 2. Fall back to Quickshell.execDetached if execute() fails
 * 3. Emit appLaunched signal on success
 *
 * NAVIGATION:
 * - moveUp(): Move selection up
 * - moveDown(): Move selection down
 * - getCurrentApp(): Get currently selected app
 * - launchApp(app): Launch a specific application
 */

// ========== ROOT PROPERTIES ==========

Item {
  id: root

  // Search term to filter applications by
  property string searchTerm: ""

  // Emitted when an application is successfully launched
  signal appLaunched()

  clip: true

  // ========== APPLICATION LIST ==========

  ListView {
    id: appList
    anchors.fill: parent
    clip: true
    spacing: Theme.spacing.xs

    // Manage currentIndex directly on the ListView (not through parent property)
    // This ensures proper highlight behavior when model changes
    currentIndex: 0

    // Visual highlight that follows the currently selected item
    // Uses secondary color scheme to differentiate from menu (which uses primary)
    highlight: Rectangle {
      width: appList.width
      height: 72
      radius: Theme.radius.xl
      color: Theme.secondary_container
      border.width: 0
      border.color: Theme.secondary
    }

    // Critical: This ensures the highlight automatically moves with currentIndex
    // Without this, the highlight would stay in place when navigating
    highlightFollowsCurrentItem: true

    // Automatically scroll to keep the selected item visible
    onCurrentIndexChanged: {
      positionViewAtIndex(currentIndex, ListView.Contain)
    }

    // Reset selection when search changes to fix highlight disappearing bug
    // Without this, clearing the search leaves the highlight invisible
    Connections {
      target: root
      function onSearchTermChanged() {
        appList.currentIndex = 0
        if (appList.count > 0) {
          appList.positionViewAtBeginning()
        }
      }
    }

    // Dynamic model that filters applications based on search text
    // Filters by matching search against app name or comment/description
    model: ScriptModel {
      values: {
        const search = root.searchTerm.toLowerCase()

        // Get all desktop applications from DesktopEntries
        const allApps = DesktopEntries.applications.values

        // Return all apps if no search term
        if (!search) {
          return allApps
        }

        // Filter apps by name and comment
        const filtered = allApps.filter(app => {
          if (app.hidden) return false  // Skip hidden apps
          const name = (app.name || "").toLowerCase()
          const comment = (app.comment || "").toLowerCase()
          return name.includes(search) || comment.includes(search)
        })

        return filtered
      }
    }

    // Ensure currentIndex stays within valid bounds when model changes
    // This prevents crashes when the filtered list shrinks
    onCountChanged: {
      if (count > 0) {
        if (currentIndex >= count) {
          currentIndex = count - 1
        } else if (currentIndex < 0) {
          currentIndex = 0
        }
      } else {
        currentIndex = -1
      }
    }
    
    // List item delegate - renders each application entry
    // Uses first letter of app name as icon (desktop entries don't expose icon paths easily)
    delegate: ListItem {
      required property var modelData
      required property int index

      width: appList.width
      height: 72
      icon: modelData.name ? modelData.name.charAt(0).toUpperCase() : "?"
      title: modelData.name || "Unknown"
      subtitle: modelData.comment || ""
      selected: index === appList.currentIndex

      onClicked: {
        appList.currentIndex = index
        root.launchApp(modelData)
      }
    }

    // ========== EMPTY STATE ==========

    // Shown when no applications match the search term
    // Provides helpful feedback to the user
    Item {
      anchors.centerIn: parent
      width: parent.width
      height: 200
      visible: appList.count === 0
      
      ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.spacing.md

        // Large circular icon container with app icon
        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: 64
          Layout.preferredHeight: 64
          radius: Theme.radius.full
          color: Theme.surface_container_high

          Text {
            anchors.centerIn: parent
            text: "󰀻"  // App grid icon
            color: Theme.on_surface_variant
            font.pixelSize: Theme.typography.xxxl
            font.family: Theme.typography.fontFamily
            opacity: 0.6
          }
        }

        // Primary message: changes based on whether search is active
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: root.searchTerm ? "No apps found" : "No applications available"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamily
          font.weight: Theme.typography.weightMedium
          opacity: 0.8
        }

        // Secondary helpful message
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: root.searchTerm ? "Try a different search term" : "Install some applications"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          opacity: 0.6
        }
      }
    }
  }

  // ========== HELPER FUNCTIONS ==========

  /**
   * Get the currently filtered applications list.
   * Used by Enter key handler to access the current model data.
   */
  function getFilteredApps() {
    return appList.model.values
  }

  /**
   * Move selection up by one item.
   * Called by keyboard navigation (Up arrow, Ctrl+P).
   */
  function moveUp() {
    if (appList.currentIndex > 0) {
      appList.currentIndex--
    }
  }

  /**
   * Move selection down by one item.
   * Called by keyboard navigation (Down arrow, Ctrl+N).
   */
  function moveDown() {
    const maxIndex = appList.count - 1
    if (appList.currentIndex < maxIndex) {
      appList.currentIndex++
    }
  }

  /**
   * Get the currently selected application object.
   * Returns null if no valid selection.
   */
  function getCurrentApp() {
    const apps = getFilteredApps()
    if (appList.currentIndex >= 0 && appList.currentIndex < apps.length) {
      return apps[appList.currentIndex]
    }
    return null
  }

  /**
   * Launch an application with fallback mechanism.
   *
   * LAUNCH STRATEGY:
   * 1. Try app.execute() first (native desktop entry execution)
   * 2. If that fails, fall back to Quickshell.execDetached
   * 3. Emit appLaunched signal on success
   *
   * @param app - Desktop entry application object to launch
   */
  function launchApp(app) {
    try {
      app.execute()
      root.appLaunched()
    } catch (error) {
      console.error("[LauncherAppList] execute() failed:", error)
      // Fallback: try execDetached if execute() fails
      try {
        Quickshell.execDetached({
          command: app.command,
          workingDirectory: app.workingDirectory || ""
        })
        root.appLaunched()
      } catch (fallbackError) {
        console.error("[LauncherAppList] Both launch methods failed:", fallbackError)
      }
    }
  }
}
