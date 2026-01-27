.pragma library

function getWeatherDescription(code) {
    switch(code) {
        case 0: return "Clear sky";
        case 1: return "Mainly clear";
        case 2: return "Partly cloudy";
        case 3: return "Overcast";
        case 45: return "Fog";
        case 48: return "Depositing rime fog";
        case 51: return "Light drizzle";
        case 53: return "Moderate drizzle";
        case 55: return "Dense drizzle";
        case 61: return "Slight rain";
        case 63: return "Moderate rain";
        case 65: return "Heavy rain";
        case 71: return "Slight snow";
        case 73: return "Moderate snow";
        case 75: return "Heavy snow";
        case 95: return "Thunderstorm";
        default: return "Unknown (" + code + ")";
    }
}

function getShortWeatherDesc(code) {
    switch(code) {
        case 0: return "Clear";
        case 1: return "Clear";
        case 2: return "Cloudy";
        case 3: return "Cloudy";
        case 45: return "Fog";
        case 48: return "Fog";
        case 51: return "Drizzle";
        case 53: return "Drizzle";
        case 55: return "Drizzle";
        case 61: return "Rain";
        case 63: return "Rain";
        case 65: return "Rain";
        case 71: return "Snow";
        case 73: return "Snow";
        case 75: return "Snow";
        case 95: return "Storm";
        default: return "";
    }
}

function getWindDir(degree) {
    if (degree > 337.5) return "N";
    if (degree > 292.5) return "NW";
    if (degree > 247.5) return "W";
    if (degree > 202.5) return "SW";
    if (degree > 157.5) return "S";
    if (degree > 112.5) return "SE";
    if (degree > 67.5) return "E";
    if (degree > 22.5) return "NE";
    return "N";
}

function getWeatherIcon(code) {
    if (code === 0) return "☀️";
    if (code === 1 || code === 2) return "⛅";
    if (code === 3) return "☁️";
    if (code >= 45 && code <= 48) return "🌫️";
    if (code >= 51 && code <= 55) return "🌧️";
    if (code >= 61 && code <= 67) return "🌧️";
    if (code >= 71 && code <= 77) return "❄️";
    if (code >= 80 && code <= 82) return "🌦️";
    if (code >= 85 && code <= 86) return "🌨️";
    if (code >= 95) return "⛈️";
    return "❓";
}
