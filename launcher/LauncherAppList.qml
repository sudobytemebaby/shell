import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../components/Lists"

Item {
  id: root
  
  property string searchTerm: ""
  property int currentIndex: 0
  signal appLaunched()
  
  clip: true
  
  // Reset index when search changes
  onSearchTermChanged: {
    currentIndex = 0
  }
  
  ListView {
    id: appList
    anchors.fill: parent
    clip: true
    spacing: Theme.spacing.xs
    
    // Bind current index for keyboard navigation
    currentIndex: root.currentIndex
    
    // Material 3 style highlight
    highlight: Rectangle {
      width: appList.width
      height: 72
      radius: Theme.radius.xl
      color: Theme.secondary_container
      border.width: 0
      border.color: Theme.secondary
      
      // Smooth transition when highlight moves
      Behavior on y {
        NumberAnimation {
          duration: 150
          easing.type: Easing.OutCubic
        }
      }
    }
    
    highlightFollowsCurrentItem: true
    
    // Keep current item visible
    onCurrentIndexChanged: {
      positionViewAtIndex(currentIndex, ListView.Contain)
    }
    
    model: ScriptModel {
      values: {
        const search = root.searchTerm.toLowerCase()
        
        const allApps = DesktopEntries.applications.values
        
        if (!search) {
          return allApps
        }
        
        const filtered = allApps.filter(app => {
          if (app.hidden) return false
          const name = (app.name || "").toLowerCase()
          const comment = (app.comment || "").toLowerCase()
          return name.includes(search) || comment.includes(search)
        })
        
        return filtered
      }
    }
    
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
    
    delegate: ListItem {
      required property var modelData
      required property int index

      width: appList.width
      height: 72
      icon: modelData.name ? modelData.name.charAt(0).toUpperCase() : "?"
      title: modelData.name || "Unknown"
      subtitle: modelData.comment || ""
      selected: index === root.currentIndex

      onClicked: {
        root.currentIndex = index
        root.launchApp(modelData)
      }
    }
    
    // Empty state - Material 3 style
    Item {
      anchors.centerIn: parent
      width: parent.width
      height: 200
      visible: appList.count === 0
      
      ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.spacing.md
        
        // Icon container
        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: 64
          Layout.preferredHeight: 64
          radius: Theme.radius.full
          color: Theme.surface_container_high
          
          Text {
            anchors.centerIn: parent
            text: "󰀻"
            color: Theme.on_surface_variant
            font.pixelSize: Theme.typography.xxxl
            font.family: Theme.typography.fontFamily
            opacity: 0.6
          }
        }
        
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: root.searchTerm ? "No apps found" : "No applications available"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamily
          font.weight: Theme.typography.weightMedium
          opacity: 0.8
        }
        
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
  
  // Helper function to get the filtered apps (for Enter key handling)
  function getFilteredApps() {
    return appList.model.values
  }
  
  // Navigation functions
  function moveUp() {
    if (root.currentIndex > 0) {
      root.currentIndex--
    }
  }
  
  function moveDown() {
    const maxIndex = appList.count - 1
    if (root.currentIndex < maxIndex) {
      root.currentIndex++
    }
  }
  
  function getCurrentApp() {
    const apps = getFilteredApps()
    if (root.currentIndex >= 0 && root.currentIndex < apps.length) {
      return apps[root.currentIndex]
    }
    return null
  }

  function launchApp(app) {
    try {
      app.execute()
      root.appLaunched()
    } catch (error) {
      console.error("execute() failed:", error)
      // Fallback: try execDetached
      try {
        Quickshell.execDetached({
          command: app.command,
          workingDirectory: app.workingDirectory || ""
        })
        root.appLaunched()
      } catch (fallbackError) {
        console.error("Fallback also failed:", fallbackError)
      }
    }
  }
}
