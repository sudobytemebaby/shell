pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// Weather Service
// ============================================================================
// Singleton service for fetching and managing weather data from Open-Meteo API.
// Provides current conditions, hourly forecasts, and daily forecasts.
// Auto-refreshes every 30 minutes to keep data current.
//
// Usage:
//   import "../../core/services" as Services
//   readonly property var weather: Services.WeatherService
//   Text { text: weather.currentTemp + "°C" }

Singleton {
    id: root

    // ========================================================================
    // CONFIGURATION
    // ========================================================================

    // Location settings
    property string city: "Barnaul"
    property real lat: 53.3498
    property real lon: 83.7836

    // Auto-refresh interval (milliseconds)
    readonly property int refreshInterval: 30 * 60 * 1000  // 30 minutes

    // ========================================================================
    // CURRENT WEATHER STATE
    // ========================================================================

    property real currentTemp: 0.0
    property real maxTemp: 0.0
    property real minTemp: 0.0
    property int weatherCode: 0
    property real windSpeed: 0.0
    property int windDirection: 0
    property int humidity: 0
    property real feelsLike: 0.0
    property int precipProb: 0
    property string lastUpdate: ""

    // ========================================================================
    // SUN DATA
    // ========================================================================

    property string sunrise: ""
    property string sunset: ""
    property real sunProgress: 0.0  // 0.0 (sunrise) to 1.0 (sunset)

    // ========================================================================
    // FORECAST DATA
    // ========================================================================

    // Daily forecast array
    // Structure: [{ day, max, min, code, precipProb, windSpeed }, ...]
    property var dailyForecast: []

    // Hourly forecast array (next 12 hours)
    // Structure: [{ time, temp, code, isDay, precipProb, windSpeed }, ...]
    property var hourlyForecast: []

    // ========================================================================
    // STATUS FLAGS
    // ========================================================================

    property bool loading: false
    property bool error: false

    // ========================================================================
    // PUBLIC API
    // ========================================================================

    /**
     * Fetch weather data from Open-Meteo API
     * Updates all weather properties on success
     */
    function fetchWeather() {
        loading = true
        error = false

        const xhr = new XMLHttpRequest()

        // Open-Meteo API endpoint with all required parameters
        const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m,relative_humidity_2m,apparent_temperature&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_probability_max,wind_speed_10m_max,sunrise,sunset&hourly=temperature_2m,weather_code,is_day,precipitation_probability,wind_speed_10m&timezone=auto&forecast_days=7&wind_speed_unit=ms`

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false

                if (xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText)
                        processWeatherResponse(response)
                    } catch (e) {
                        console.error("[WeatherService] Parsing error:", e)
                        error = true
                    }
                } else {
                    console.error("[WeatherService] Fetch failed:", xhr.status, xhr.statusText)
                    error = true
                }
            }
        }

        xhr.open("GET", url)
        xhr.send()
    }

    // ========================================================================
    // INTERNAL LOGIC - Response Processing
    // ========================================================================

    /**
     * Process the API response and update all weather properties
     * @param response - Parsed JSON response from Open-Meteo API
     */
    function processWeatherResponse(response) {
        // Process current weather
        if (response.current) {
            root.currentTemp = response.current.temperature_2m
            root.weatherCode = response.current.weather_code
            root.windSpeed = response.current.wind_speed_10m
            root.windDirection = response.current.wind_direction_10m
            root.humidity = response.current.relative_humidity_2m
            root.feelsLike = response.current.apparent_temperature
        }

        // Process daily forecast and sun data
        if (response.daily && response.daily.time) {
            processDailyForecast(response.daily)
        }

        // Process hourly forecast
        if (response.hourly && response.hourly.time) {
            processHourlyForecast(response.hourly)
        }

        // Update last refresh timestamp
        const now = new Date()
        root.lastUpdate = getHourMinuteString(now)
    }

    /**
     * Process daily forecast data
     * @param daily - Daily forecast object from API response
     */
    function processDailyForecast(daily) {
        // Set today's max/min temperatures
        root.maxTemp = daily.temperature_2m_max[0]
        root.minTemp = daily.temperature_2m_min[0]

        // Process sunrise/sunset and calculate sun progress
        if (daily.sunrise && daily.sunset) {
            const sr = new Date(daily.sunrise[0])
            const ss = new Date(daily.sunset[0])
            const now = new Date()

            root.sunrise = getHourMinuteString(sr)
            root.sunset = getHourMinuteString(ss)

            // Calculate sun position (0.0 = sunrise, 1.0 = sunset)
            var totalDay = ss - sr
            var current = now - sr
            var prog = current / totalDay

            // Clamp between 0 and 1
            if (prog < 0) prog = 0
            if (prog > 1) prog = 1
            root.sunProgress = prog
        }

        // Build daily forecast array
        var dForecast = []
        const dTimes = daily.time
        const dMaxs = daily.temperature_2m_max
        const dMins = daily.temperature_2m_min
        const dCodes = daily.weather_code
        const dPrecip = daily.precipitation_probability_max
        const dWind = daily.wind_speed_10m_max

        for (var i = 0; i < dTimes.length; i++) {
            dForecast.push({
                day: getDayName(dTimes[i]),
                max: dMaxs[i],
                min: dMins[i],
                code: dCodes[i],
                precipProb: dPrecip ? dPrecip[i] : 0,
                windSpeed: dWind ? dWind[i] : 0
            })
        }

        root.dailyForecast = dForecast
    }

    /**
     * Process hourly forecast data
     * Extracts next 12 hours of forecast and current precipitation probability
     * @param hourly - Hourly forecast object from API response
     */
    function processHourlyForecast(hourly) {
        var hForecast = []
        const hTimes = hourly.time
        const hTemps = hourly.temperature_2m
        const hCodes = hourly.weather_code
        const hIsDay = hourly.is_day
        const hPrecip = hourly.precipitation_probability
        const hWind = hourly.wind_speed_10m

        const now = new Date()

        var count = 0
        var currentProbFound = false

        // Iterate through hourly data
        for (var j = 0; j < hTimes.length; j++) {
            const timeObj = new Date(hTimes[j])
            const diff = timeObj - now

            // Find current hour's precipitation probability
            if (!currentProbFound && Math.abs(diff) < 3600000) {
                root.precipProb = hPrecip[j]
                currentProbFound = true
            }

            // Stop once we have 12 hours
            if (count >= 12) continue

            // Skip hours that are more than 1 hour in the past
            if (timeObj < now && diff < -3600000) continue

            // Add to forecast
            if (count < 12) {
                hForecast.push({
                    time: getHourMinuteString(timeObj),
                    temp: hTemps[j],
                    code: hCodes[j],
                    isDay: hIsDay[j] === 1,
                    precipProb: hPrecip[j],
                    windSpeed: hWind[j]
                })
                count++
            }
        }

        root.hourlyForecast = hForecast

        // Fallback: use first hour's precipitation if current not found
        if (!currentProbFound && hPrecip.length > 0) {
            root.precipProb = hPrecip[0]
        }
    }

    // ========================================================================
    // UTILITY FUNCTIONS
    // ========================================================================

    /**
     * Get abbreviated day name from ISO date string
     * @param dateString - ISO date string (e.g., "2024-03-15")
     * @returns Abbreviated day name (e.g., "Mon", "Tue")
     */
    function getDayName(dateString) {
        const date = new Date(dateString)
        return date.toLocaleDateString(Qt.locale(), "ddd")
    }

    /**
     * Format date object as HH:MM string
     * @param date - Date object
     * @returns Formatted time string (e.g., "14:30")
     */
    function getHourMinuteString(date) {
        return date.getHours().toString().padStart(2, '0') + ":" +
               date.getMinutes().toString().padStart(2, '0')
    }

    // ========================================================================
    // AUTO-REFRESH TIMER
    // ========================================================================

    property Timer refreshTimer: Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        onTriggered: root.fetchWeather()
    }

    // ========================================================================
    // INITIALIZATION & CLEANUP
    // ========================================================================

    Component.onCompleted: {
        console.log("[WeatherService] Initializing for", city)
        fetchWeather()
    }

    Component.onDestruction: {
        console.log("[WeatherService] Cleaning up")
        refreshTimer.stop()
    }
}
