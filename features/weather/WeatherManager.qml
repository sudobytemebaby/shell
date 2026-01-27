import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // ========================================================================
    // PUBLIC PROPERTIES
    // ========================================================================
    
    property bool visible: false
    
    property string city: "Barnaul"
    property real lat: 53.3498
    property real lon: 83.7836
    
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
    
    // Sun data
    property string sunrise: ""
    property string sunset: ""
    property real sunProgress: 0.0 // 0.0 (sunrise) to 1.0 (sunset)
    
    property var dailyForecast: [] 
    property var hourlyForecast: [] 
    property bool loading: false
    property bool error: false
    
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
    }
    
    // ========================================================================
    // LOGIC
    // ========================================================================
    
    function fetchWeather() {
        loading = true;
        error = false;
        
        const xhr = new XMLHttpRequest();
        // Updated URL: Added wind_speed_unit=ms, and re-added sunrise/sunset to daily
        const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m,relative_humidity_2m,apparent_temperature&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_probability_max,wind_speed_10m_max,sunrise,sunset&hourly=temperature_2m,weather_code,is_day,precipitation_probability,wind_speed_10m&timezone=auto&forecast_days=7&wind_speed_unit=ms`;
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false;
                if (xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        
                        // Current weather
                        root.currentTemp = response.current.temperature_2m;
                        root.weatherCode = response.current.weather_code;
                        root.windSpeed = response.current.wind_speed_10m;
                        root.windDirection = response.current.wind_direction_10m;
                        root.humidity = response.current.relative_humidity_2m;
                        root.feelsLike = response.current.apparent_temperature;
                        
                        // Daily forecast processing
                        if (response.daily && response.daily.time) {
                            root.maxTemp = response.daily.temperature_2m_max[0];
                            root.minTemp = response.daily.temperature_2m_min[0];
                            
                            // Sun times
                            if (response.daily.sunrise && response.daily.sunset) {
                                const sr = new Date(response.daily.sunrise[0]);
                                const ss = new Date(response.daily.sunset[0]);
                                const now = new Date();
                                
                                root.sunrise = getHourMinuteString(sr);
                                root.sunset = getHourMinuteString(ss);
                                
                                // Calculate progress
                                var totalDay = ss - sr;
                                var current = now - sr;
                                var prog = current / totalDay;
                                if (prog < 0) prog = 0;
                                if (prog > 1) prog = 1;
                                root.sunProgress = prog;
                            }
                            
                            var dForecast = [];
                            const dTimes = response.daily.time;
                            const dMaxs = response.daily.temperature_2m_max;
                            const dMins = response.daily.temperature_2m_min;
                            const dCodes = response.daily.weather_code;
                            const dPrecip = response.daily.precipitation_probability_max;
                            const dWind = response.daily.wind_speed_10m_max;
                            
                            for (var i = 0; i < dTimes.length; i++) {
                                dForecast.push({
                                    day: getDayName(dTimes[i]),
                                    max: dMaxs[i],
                                    min: dMins[i],
                                    code: dCodes[i],
                                    precipProb: dPrecip ? dPrecip[i] : 0,
                                    windSpeed: dWind ? dWind[i] : 0
                                });
                            }
                            root.dailyForecast = dForecast;
                        }
                        
                        // Hourly forecast processing
                        if (response.hourly && response.hourly.time) {
                            var hForecast = [];
                            const hTimes = response.hourly.time;
                            const hTemps = response.hourly.temperature_2m;
                            const hCodes = response.hourly.weather_code;
                            const hIsDay = response.hourly.is_day;
                            const hPrecip = response.hourly.precipitation_probability;
                            const hWind = response.hourly.wind_speed_10m;
                            
                            const now = new Date();
                            
                            var count = 0;
                            var currentProbFound = false;
                            
                            for (var j = 0; j < hTimes.length; j++) {
                                const timeObj = new Date(hTimes[j]);
                                const diff = timeObj - now;
                                
                                if (!currentProbFound && Math.abs(diff) < 3600000) {
                                    root.precipProb = hPrecip[j];
                                    currentProbFound = true;
                                }
                                
                                if (count >= 12) continue;
                                
                                if (timeObj < now && diff < -3600000) continue; 

                                if (count < 12) {
                                    hForecast.push({
                                        time: getHourMinuteString(timeObj),
                                        temp: hTemps[j],
                                        code: hCodes[j],
                                        isDay: hIsDay[j] === 1,
                                        precipProb: hPrecip[j],
                                        windSpeed: hWind[j]
                                    });
                                    count++;
                                }
                            }
                            root.hourlyForecast = hForecast;
                            
                            if (!currentProbFound && hPrecip.length > 0) {
                                root.precipProb = hPrecip[0];
                            }
                        }

                        // Set last update time
                        const nowUpdate = new Date();
                        root.lastUpdate = getHourMinuteString(nowUpdate);
                        
                    } catch (e) {
                        console.error("Weather parsing error:", e);
                        error = true;
                    }
                } else {
                    console.error("Weather fetch failed:", xhr.status, xhr.statusText);
                    error = true;
                }
            }
        }
        
        xhr.open("GET", url);
        xhr.send();
    }
    
    function getDayName(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString(Qt.locale(), "ddd");
    }
    
    function getHourMinuteString(date) {
        return date.getHours().toString().padStart(2, '0') + ":" + 
               date.getMinutes().toString().padStart(2, '0');
    }
    
    // Auto-refresh every 30 minutes
    property Timer refreshTimer: Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.fetchWeather()
    }
    
    Component.onCompleted: fetchWeather()
}