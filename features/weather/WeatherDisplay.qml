import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../shared/theme"
import "weather_modules" as Modules

LazyLoader {
    id: loader
    
    required property var manager
    
    active: manager.visible
    
    PanelWindow {
        id: weatherWindow
        
        // Full screen overlay
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        
        color: "transparent"
        mask: null
        
        Component.onCompleted: {
            exclusiveZone = 0
        }
        
        // Close on Escape, Arrows to switch slides
        contentItem {
            focus: true
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    loader.manager.visible = false
                    event.accepted = true
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                    if (viewStack.currentIndex < 2) {
                        viewStack.currentIndex++
                    } else {
                        viewStack.currentIndex = 0 // Wrap
                    }
                    event.accepted = true
                } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                    if (viewStack.currentIndex > 0) {
                        viewStack.currentIndex--
                    } else {
                        viewStack.currentIndex = 2 // Wrap
                    }
                    event.accepted = true
                }
            }
        }
        
        // Background click to close
        MouseArea {
            anchors.fill: parent
            onClicked: loader.manager.visible = false
        }
        
        // Main Container
        Rectangle {
            id: container
            x: (parent.width - 850) / 2
            y: (parent.height - 550) / 2
            width: 850
            height: 550
            radius: 28
            color: Theme.surface_container_transparent_medium
            border.width: 0.5
            border.color: Theme.surface_container_high
            
            // Prevent clicks on container from closing
            MouseArea {
                anchors.fill: parent
            }
            
            ColumnLayout {
                anchors {
                    fill: parent
                    margins: Theme.padding.xl
                }
                spacing: Theme.spacing.md
                
                // ====================================================================
                // HEADER
                // ====================================================================
                Modules.WeatherHeader {
                    title: {
                        if (viewStack.currentIndex === 0) return "Current Weather"
                        if (viewStack.currentIndex === 1) return "Hourly Forecast"
                        return "Weekly forecast"
                    }
                    
                    onCloseClicked: loader.manager.visible = false
                    onRefreshClicked: loader.manager.fetchWeather()
                }
                
                // ====================================================================
                // CONTENT STACK
                // ====================================================================
                StackLayout {
                    id: viewStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: 0
                    
                    // --- SLIDE 1: CURRENT WEATHER ---
                    Modules.CurrentWeatherSlide {
                        manager: loader.manager
                    }
                    
                    // --- SLIDE 2: HOURLY FORECAST ---
                    Modules.HourlyForecastSlide {
                      manager: loader.manager
                    }

                    // --- SLIDE 3: WEEKLY FORECAST GRAPH ---
                    Modules.WeeklyForecastSlide {
                        manager: loader.manager
                    }

                }
                
                // ====================================================================
                // FOOTER
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
