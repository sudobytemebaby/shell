import QtQuick
import QtQuick.Layouts
import "../../../shared/theme"
import "../WeatherUtils.js" as Utils

Item {
    required property var manager

    // Component for hourly item (used in both rows)
    Component {
        id: hourlyItemComponent
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4
                
                Text {
                    text: modelData.time
                    color: Theme.on_surface_variant
                    font.pixelSize: Theme.typography.md
                    font.weight: Theme.typography.weightBold
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: Utils.getWeatherIcon(modelData.code)
                    font.pixelSize: 36
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: Math.round(modelData.temp) + "°"
                    color: Theme.on_surface
                    font.pixelSize: Theme.typography.xxl
                    font.weight: Theme.typography.weightBold
                    Layout.alignment: Qt.AlignHCenter
                }
                
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8
                    
                                        RowLayout {
                                            spacing: 2
                                            Text { text: "󰖝"; font.pixelSize: 12; color: Theme.outline }
                                            Text { 
                                                text: Math.round(modelData.windSpeed) + " m/s"
                                                color: Theme.outline
                                                font.pixelSize: Theme.typography.sm
                                            }
                                        }
                    
                    RowLayout {
                        spacing: 2
                        Text { text: "󰕊"; font.pixelSize: 12; color: Theme.outline }
                        Text { 
                            text: modelData.precipProb + "%"
                            color: modelData.precipProb > 0 ? Theme.primary : Theme.outline
                            font.pixelSize: Theme.typography.sm
                        }
                    }
                }
                
                Text {
                    text: Utils.getShortWeatherDesc(modelData.code)
                    color: Theme.tertiary
                    font.pixelSize: Theme.typography.sm
                    Layout.alignment: Qt.AlignHCenter
                    elide: Text.ElideRight
                    Layout.maximumWidth: parent.width - 10
                }
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.95
        spacing: 0
        
        // Row 1 (First 6 items)
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: manager.hourlyForecast.slice(0, 6)
                delegate: hourlyItemComponent
            }
        }
        
        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.surface_container_highest
            Layout.topMargin: Theme.spacing.xxl
            Layout.bottomMargin: Theme.spacing.xxl
        }
        
        // Row 2 (Next 6 items)
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: manager.hourlyForecast.slice(6, 12)
                delegate: hourlyItemComponent
            }
        }
    }
}
