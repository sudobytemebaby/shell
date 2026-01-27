import QtQuick
import QtQuick.Layouts
import "../../../shared/theme"
import "../WeatherUtils.js" as Utils

Item {
    id: root
    required property var manager

    RowLayout {
        anchors.centerIn: parent
        width: parent.width * 0.9
        spacing: Theme.spacing.xxl
        
        // Left Side: Big Temp & Context
        ColumnLayout {
            spacing: Theme.spacing.sm
            Layout.preferredWidth: parent.width * 0.45
            
            Text {
                text: manager.city
                color: Theme.on_surface_variant
                font.pixelSize: Theme.typography.xl
                font.family: Theme.typography.fontFamilyDisplay
                font.weight: Theme.typography.weightMedium
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: Math.round(manager.currentTemp) + "°"
                color: Theme.primary
                font.pixelSize: 112
                font.family: Theme.typography.fontFamilyDisplay
                font.weight: Theme.typography.weightBold
                Layout.alignment: Qt.AlignHCenter
            }
            
                            Text {
                                text: {
                                    var desc = Utils.getWeatherDescription(manager.weatherCode);
                                    if (manager.windSpeed > 6) desc += ", Windy";
                                    return desc;
                                }
                                color: Theme.tertiary
                                font.pixelSize: Theme.typography.xl
                                font.family: Theme.typography.fontFamilyDisplay
                                font.weight: Theme.typography.weightMedium
                                Layout.alignment: Qt.AlignHCenter
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }            
            Text {
                text: "H: " + Math.round(manager.maxTemp) + "°  L: " + Math.round(manager.minTemp) + "°"
                color: Theme.on_surface
                font.pixelSize: Theme.typography.lg
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Theme.spacing.sm
            }
        }
        
        // Divider
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 300 // Increased height to match larger right side
            color: Theme.outline_variant
        }
        
        // Right Side: Detailed Stats + Sun Arc
        ColumnLayout {
            spacing: Theme.spacing.xxl
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: parent.width * 0.45

            // Detailed Stats Grid
            GridLayout {
                columns: 2
                columnSpacing: Theme.spacing.xl
                rowSpacing: Theme.spacing.xl
                Layout.alignment: Qt.AlignHCenter
                
                // Wind
                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignHCenter
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4
                        Text { text: "Wind"; color: Theme.on_surface_variant; font.pixelSize: Theme.typography.sm }
                        Text { 
                            text: Utils.getWindDir(manager.windDirection)
                            color: Theme.on_surface_variant
                            font.pixelSize: Theme.typography.sm
                        }
                    }
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Text { text: "󰖝"; font.pixelSize: 24; color: Theme.on_surface }
                        Text { 
                            text: Math.round(manager.windSpeed) + " m/s"
                            color: Theme.on_surface
                            font.pixelSize: Theme.typography.lg
                            font.weight: Theme.typography.weightBold
                        }
                    }
                }
                
                // Humidity
                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignHCenter
                    Text { text: "Humidity"; color: Theme.on_surface_variant; font.pixelSize: Theme.typography.sm; Layout.alignment: Qt.AlignHCenter }
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Text { text: "󰖌"; font.pixelSize: 24; color: Theme.on_surface }
                        Text { 
                            text: manager.humidity + "%"
                            color: Theme.on_surface
                            font.pixelSize: Theme.typography.lg
                            font.weight: Theme.typography.weightBold
                        }
                    }
                }
                
                // Feels Like
                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignHCenter
                    Text { text: "Feels Like"; color: Theme.on_surface_variant; font.pixelSize: Theme.typography.sm; Layout.alignment: Qt.AlignHCenter }
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Text { text: "󰙊"; font.pixelSize: 24; color: Theme.on_surface }
                        Text { 
                            text: Math.round(manager.feelsLike) + "°"
                            color: Theme.on_surface
                            font.pixelSize: Theme.typography.lg
                            font.weight: Theme.typography.weightBold
                        }
                    }
                }
                
                // Precip Prob
                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignHCenter
                    Text { text: "Precipitation"; color: Theme.on_surface_variant; font.pixelSize: Theme.typography.sm; Layout.alignment: Qt.AlignHCenter }
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Text { text: "󰕊"; font.pixelSize: 24; color: Theme.on_surface }
                        Text { 
                            text: manager.precipProb + "%"
                            color: Theme.on_surface
                            font.pixelSize: Theme.typography.lg
                            font.weight: Theme.typography.weightBold
                        }
                    }
                }
            }

            // Sun Arc Section
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                
                Canvas {
                    id: sunCanvas
                    anchors.fill: parent
                    property real progress: manager.sunProgress
                    onProgressChanged: requestPaint()
                    
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        
                        var centerX = width / 2;
                        var bottomY = height - 20; 
                        var radius = Math.min(width / 2.5, height - 25);
                        
                        // Draw Background Arc
                        ctx.beginPath();
                        ctx.lineWidth = 2;
                        ctx.strokeStyle = Theme.surface_container_highest;
                        ctx.setLineDash([5, 5]);
                        ctx.arc(centerX, bottomY, radius, Math.PI, 2 * Math.PI, false);
                        ctx.stroke();
                        ctx.setLineDash([]);
                        
                        // Draw Progress Arc
                        var currentAngle = Math.PI + (manager.sunProgress * Math.PI);
                        ctx.beginPath();
                        ctx.lineWidth = 3;
                        ctx.strokeStyle = Theme.primary;
                        ctx.arc(centerX, bottomY, radius, Math.PI, currentAngle, false);
                        ctx.stroke();
                        
                        // Draw Sun Dot
                        var sunX = centerX + radius * Math.cos(currentAngle);
                        var sunY = bottomY + radius * Math.sin(currentAngle);
                        
                        ctx.beginPath();
                        ctx.fillStyle = "#FDB813"; 
                        ctx.arc(sunX, sunY, 6, 0, 2 * Math.PI);
                        ctx.fill();
                        ctx.lineWidth = 2;
                        ctx.strokeStyle = Qt.rgba(0.99, 0.72, 0.07, 0.3);
                        ctx.stroke();
                    }
                }
                
                // Numerical Labels (Sunrise/Sunset)
                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: parent.width * 0.15
                    text: manager.sunrise
                    color: Theme.on_surface_variant
                    font.pixelSize: Theme.typography.sm
                    font.weight: Theme.typography.weightMedium
                }
                
                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: parent.width * 0.15
                    text: manager.sunset
                    color: Theme.on_surface_variant
                    font.pixelSize: Theme.typography.sm
                    font.weight: Theme.typography.weightMedium
                }
            }
        }
    }
}
