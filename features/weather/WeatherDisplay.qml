import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../shared/theme"
import "../../shared/components"
import "../../shared/components/Modals"
import "../../shared/components/Navigation"
import "../../shared/components/Utils"
import "weather_modules" as Modules

// ----------------------------------------------------------------------------
// Weather Display
// ----------------------------------------------------------------------------
// Full-screen weather widget overlay with three slides:
// 1. Current weather conditions with detailed stats
// 2. Hourly forecast (next 12 hours)
// 3. Weekly forecast with temperature graph
//
// Navigation: Arrow keys or click page indicators
// Close: Escape key or click background

AnimatedLazyLoader {
  id: loader

  required property var manager

  show: manager.visible

  PanelWindow {
    id: weatherWindow

    // ========================================================================
    // WINDOW CONFIGURATION
    // ========================================================================

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    visible: loader.active

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0
    }

    // ========================================================================
    // KEYBOARD NAVIGATION
    // ========================================================================

    KeyboardNavigationHandler {
      id: navHandler
      currentIndex: viewStack.currentIndex
      itemCount: 3
      columns: 3
      wrapAround: true

      onNavigateLeft: newIndex => viewStack.currentIndex = newIndex
      onNavigateRight: newIndex => viewStack.currentIndex = newIndex

      onClose: loader.manager.visible = false
    }

    contentItem {
      focus: true
      Keys.onPressed: event => {
        // Manual Up/Down navigation (Next/Prev behavior to match Left/Right)
        if (event.key === Qt.Key_Up) {
          if (viewStack.currentIndex > 0) {
            viewStack.currentIndex--
          } else {
            viewStack.currentIndex = 2
          }
          event.accepted = true
          return
        }
        else if (event.key === Qt.Key_Down) {
          if (viewStack.currentIndex < 2) {
            viewStack.currentIndex++
          } else {
            viewStack.currentIndex = 0
          }
          event.accepted = true
          return
        }

        // Delegate Left/Right/Escape/Home/End to handler
        navHandler.handleKeyPress(event)
      }
    }

    // ========================================================================
    // BACKGROUND OVERLAY
    // ========================================================================

    // Click background to close
    MouseArea {
      anchors.fill: parent
      onClicked: loader.manager.visible = false
    }

    // ========================================================================
    // MAIN CONTAINER
    // ========================================================================

    Rectangle {
      id: container

      layer.enabled: true
      layer.smooth: true
      layer.effect: PaneShadow {}

      x: (parent.width - Config.weather.width) / 2
      y: (parent.height - Config.weather.height) / 2
      width: Config.weather.width
      height: Config.weather.height
      radius: Config.weather.radius
      color: Config.paneBackground
      border.width: Config.paneBorderWidth
      border.color: Theme.surface_container

      scale: loader.contentScale
      opacity: loader.contentOpacity

      // Prevent clicks from propagating to background
      MouseArea {
        anchors.fill: parent
      }

      ColumnLayout {
        anchors {
          fill: parent
          margins: Config.padding.xl
        }
        spacing: Config.spacing.md

        // ====================================================================
        // HEADER
        // ====================================================================

        ModalHeader {
          title: {
            if (viewStack.currentIndex === 0) return "Current Weather"
            if (viewStack.currentIndex === 1) return "Hourly Forecast"
            return "Weekly Forecast"
          }

          animateTitle: true
          fadeDuration: 150

          actionButtons: [
            {
              icon: "󰑐",
              tooltip: "Refresh",
              onClicked: () => { loader.manager.fetchWeather() }
            }
          ]

          onCloseClicked: loader.manager.visible = false
        }

        // ====================================================================
        // CONTENT STACK (Three Slides)
        // ====================================================================

        StackLayout {
          id: viewStack
          Layout.fillWidth: true
          Layout.fillHeight: true
          currentIndex: 0

          // Slide 1: Current Weather
          Modules.CurrentWeatherSlide {
            manager: loader.manager
          }

          // Slide 2: Hourly Forecast
          Modules.HourlyForecastSlide {
            manager: loader.manager
          }

          // Slide 3: Weekly Forecast
          Modules.WeeklyForecastSlide {
            manager: loader.manager
          }
        }

        // ====================================================================
        // FOOTER (Navigation + Last Update)
        // ====================================================================

        Modules.WeatherFooter {
          currentIndex: viewStack.currentIndex
          pageCount: 3
          lastUpdate: loader.manager.lastUpdate
          onIndexSelected: index => viewStack.currentIndex = index
        }
      }
    }
  }
}
