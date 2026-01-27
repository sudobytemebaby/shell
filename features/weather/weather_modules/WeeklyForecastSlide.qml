import QtQuick
import QtQuick.Layouts
import "../../../shared/theme"
import "../WeatherUtils.js" as Utils

Item {
    id: root
    required property var manager
    
    property var forecast: manager.dailyForecast
    property real minGraphTemp: 0
    property real maxGraphTemp: 0
    
    onForecastChanged: calculateBounds()
    Component.onCompleted: calculateBounds()
    
    function calculateBounds() {
        if (!forecast || forecast.length === 0) return;
        var min = 1000;
        var max = -1000;
        for (var i = 0; i < forecast.length; i++) {
            if (forecast[i].max > max) max = forecast[i].max;
            if (forecast[i].max < min) min = forecast[i].max;
        }
        minGraphTemp = min - 2;
        maxGraphTemp = max + 2;
        graphCanvas.requestPaint();
    }
    
    // 1. Background Layer: Separators
    RowLayout {
        anchors.fill: parent
        spacing: 0
        z: 0
        
        Repeater {
            model: root.forecast
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: Theme.spacing.lg
                    anchors.bottomMargin: Theme.spacing.lg
                    width: 1
                    color: Theme.surface_container_highest
                    visible: index < root.forecast.length - 1
                }
            }
        }
    }

    // 2. Middle Layer: Graph
    Canvas {
        id: graphCanvas
        anchors.fill: parent
        anchors.topMargin: 140 
        anchors.bottomMargin: 110
        z: 1
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            if (!root.forecast || root.forecast.length === 0) return;
            
            var points = root.forecast;
            var stepX = width / points.length;
            var rangeY = root.maxGraphTemp - root.minGraphTemp;
            if (rangeY === 0) rangeY = 1; 
            
            var gradient = ctx.createLinearGradient(0, 0, 0, height);
            gradient.addColorStop(0, Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4));
            gradient.addColorStop(1, Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.0));

            ctx.beginPath();
            for (var i = 0; i < points.length; i++) {
                var x = (i * stepX) + (stepX / 2);
                var normalizedY = (points[i].max - root.minGraphTemp) / rangeY;
                var y = height - (normalizedY * height);
                if (i === 0) { ctx.moveTo(x, height); ctx.lineTo(x, y); }
                else { ctx.lineTo(x, y); }
            }
            var lastX = ((points.length - 1) * stepX) + (stepX / 2);
            ctx.lineTo(lastX, height);
            ctx.closePath();
            ctx.fillStyle = gradient;
            ctx.fill();

            ctx.beginPath();
            ctx.strokeStyle = Theme.primary;
            ctx.lineWidth = 4;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            for (var i = 0; i < points.length; i++) {
                var x = (i * stepX) + (stepX / 2);
                var normalizedY = (points[i].max - root.minGraphTemp) / rangeY;
                var y = height - (normalizedY * height);
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
            ctx.stroke();
            
            ctx.fillStyle = Theme.surface_container;
            ctx.strokeStyle = Theme.primary;
            ctx.lineWidth = 3;
            for (var i = 0; i < points.length; i++) {
                var x = (i * stepX) + (stepX / 2);
                var normalizedY = (points[i].max - root.minGraphTemp) / rangeY;
                var y = height - (normalizedY * height);
                ctx.beginPath();
                ctx.arc(x, y, 6, 0, 2 * Math.PI);
                ctx.fill();
                ctx.stroke();
            }
        }
    }
    
    // 3. Top Layer: Text & Info
    RowLayout {
        anchors.fill: parent
        spacing: 0
        z: 2
        
        Repeater {
            model: root.forecast
            
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                // Top Info
                ColumnLayout {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4
                    anchors.topMargin: Theme.spacing.lg
                    width: parent.width
                    
                    Text {
                        text: modelData.day
                        color: Theme.on_surface
                        font.pixelSize: Theme.typography.lg
                        font.weight: Theme.typography.weightBold
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: Utils.getWeatherIcon(modelData.code)
                        font.pixelSize: 34
                        Layout.alignment: Qt.AlignHCenter
                    }

                     Text {
                        text: Math.round(modelData.max) + "°"
                        font.pixelSize: Theme.typography.xxl
                        font.weight: Theme.typography.weightBold
                        color: Theme.primary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: Utils.getShortWeatherDesc(modelData.code)
                        font.pixelSize: Theme.typography.xs // Slightly smaller for better fit
                        color: Theme.tertiary
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap // Enable wrapping
                        Layout.maximumWidth: parent.width - 8
                        lineHeight: 0.9
                    }
                }
                
                // Bottom Info
                ColumnLayout {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: Theme.spacing.lg
                    spacing: 4
                    
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 6
                        Text { text: "󰕊"; font.pixelSize: 16; color: Theme.outline }
                        Text { 
                            text: modelData.precipProb + "%"
                            color: modelData.precipProb > 0 ? Theme.primary : Theme.outline
                            font.pixelSize: Theme.typography.sm
                            font.weight: Theme.typography.weightMedium
                        }
                    }
                    
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 6
                        Text { text: "󰖝"; font.pixelSize: 16; color: Theme.outline }
                        Text { 
                            text: Math.round(modelData.windSpeed) + " m/s"
                            color: Theme.on_surface_variant
                            font.pixelSize: Theme.typography.sm
                        }
                    }
                }
            }
        }
    }
}
