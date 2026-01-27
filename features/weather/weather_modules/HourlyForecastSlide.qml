import QtQuick
import QtQuick.Layouts
import "../../../shared/theme"
import "../WeatherUtils.js" as Utils

// ----------------------------------------------------------------------------
// Hourly Forecast Slide
// ----------------------------------------------------------------------------
// Displays next 12 hours of weather forecast in two rows of 6 items each.
// Each item shows: time, weather icon, temperature, wind speed, and precipitation probability.

Item {
  required property var manager

  // ==========================================================================
  // HOURLY ITEM COMPONENT (Reusable)
  // ==========================================================================

  Component {
    id: hourlyItemComponent

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: 110

      ColumnLayout {
        anchors.centerIn: parent
        spacing: 4

        // Time label
        Text {
          text: modelData.time
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.md
          font.weight: Theme.typography.weightBold
          Layout.alignment: Qt.AlignHCenter
        }

        // Weather icon
        Text {
          text: Utils.getWeatherIcon(modelData.code)
          font.pixelSize: 36
          Layout.alignment: Qt.AlignHCenter
        }

        // Temperature
        Text {
          text: Math.round(modelData.temp) + "°"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.xxl
          font.weight: Theme.typography.weightBold
          Layout.alignment: Qt.AlignHCenter
        }

        // Wind & Precipitation info
        RowLayout {
          Layout.alignment: Qt.AlignHCenter
          spacing: 8

          // Wind speed
          RowLayout {
            spacing: 2
            Text {
              text: "󰖝"
              font.pixelSize: 12
              color: Theme.outline
            }
            Text {
              text: Math.round(modelData.windSpeed) + " m/s"
              color: Theme.outline
              font.pixelSize: Theme.typography.sm
            }
          }

          // Precipitation probability
          RowLayout {
            spacing: 2
            Text {
              text: "󰕊"
              font.pixelSize: 12
              color: Theme.outline
            }
            Text {
              text: modelData.precipProb + "%"
              color: modelData.precipProb > 0 ? Theme.primary : Theme.outline
              font.pixelSize: Theme.typography.sm
            }
          }
        }

        // Short weather description
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

  // ==========================================================================
  // FORECAST LAYOUT (Two Rows)
  // ==========================================================================

  ColumnLayout {
    anchors.centerIn: parent
    width: parent.width * 0.95
    spacing: 0

    // First row (hours 0-5)
    RowLayout {
      Layout.fillWidth: true
      spacing: 0
      Repeater {
        model: manager.hourlyForecast.slice(0, 6)
        delegate: hourlyItemComponent
      }
    }

    // Divider between rows
    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 1
      color: Theme.surface_container_highest
      Layout.topMargin: Theme.spacing.xxl
      Layout.bottomMargin: Theme.spacing.xxl
    }

    // Second row (hours 6-11)
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
