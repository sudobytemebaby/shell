import QtQuick
import Quickshell.Io
import "../../core/services" as Services

// ----------------------------------------------------------------------------
// Weather Manager
// ----------------------------------------------------------------------------
// Manages weather widget visibility and IPC communication.
// Delegates all weather data fetching and processing to WeatherService.
// Exposes WeatherService properties for convenience.

QtObject {
    id: root

    // ========================================================================
    // WEATHER SERVICE
    // ========================================================================

    readonly property var weather: Services.WeatherService

    // ========================================================================
    // UI STATE
    // ========================================================================

    property bool visible: false

    // ========================================================================
    // WEATHER DATA (Proxied from WeatherService)
    // ========================================================================

    // Configuration
    readonly property string city: weather.city
    readonly property real lat: weather.lat
    readonly property real lon: weather.lon

    // Current weather
    readonly property real currentTemp: weather.currentTemp
    readonly property real maxTemp: weather.maxTemp
    readonly property real minTemp: weather.minTemp
    readonly property int weatherCode: weather.weatherCode
    readonly property real windSpeed: weather.windSpeed
    readonly property int windDirection: weather.windDirection
    readonly property int humidity: weather.humidity
    readonly property real feelsLike: weather.feelsLike
    readonly property int precipProb: weather.precipProb
    readonly property string lastUpdate: weather.lastUpdate

    // Sun data
    readonly property string sunrise: weather.sunrise
    readonly property string sunset: weather.sunset
    readonly property real sunProgress: weather.sunProgress

    // Forecast data
    readonly property var dailyForecast: weather.dailyForecast
    readonly property var hourlyForecast: weather.hourlyForecast

    // Status flags
    readonly property bool loading: weather.loading
    readonly property bool error: weather.error
    
    // ========================================================================
    // IPC HANDLER
    // ========================================================================

    property IpcHandler ipc: IpcHandler {
        target: "weather"

        function toggle() {
            root.visible = !root.visible
        }

        function show() {
            root.visible = true
        }

        function hide() {
            root.visible = false
        }

        function refresh() {
            weather.fetchWeather()
        }
    }

    // ========================================================================
    // PUBLIC API (Delegated to WeatherService)
    // ========================================================================

    /**
     * Fetch fresh weather data
     * Delegates to WeatherService
     */
    function fetchWeather() {
        weather.fetchWeather()
    }
}