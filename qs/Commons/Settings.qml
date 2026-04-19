pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property bool isLoaded: false

  readonly property alias data: adapter

  readonly property string shellName: "quickshell"
  readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/" + shellName + "/"
  readonly property string cacheDir: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/" + shellName + "/"

  readonly property string settingsFile: configDir + "config.json"

  signal settingsLoaded()
  signal settingsReloaded()

  Component.onCompleted: {
    Quickshell.execDetached(["mkdir", "-p", configDir])
    Quickshell.execDetached(["mkdir", "-p", cacheDir])
    settingsFileView.adapter = adapter
  }

  FileView {
    id: settingsFileView
    path: settingsFile
    printErrors: false
    watchChanges: true

    onFileChanged: {
      console.log("[Settings] External change detected, reloading...")
      settingsFileView.reload()
    }

    onPathChanged: {
      if (path !== undefined) {
        reload()
      }
    }

    onLoaded: {
      if (!root.isLoaded) {
        root.isLoaded = true
        root.settingsLoaded()
      } else {
        root.settingsReloaded()
      }
    }

    onLoadFailed: function(error) {
      if (error.toString().includes("No such file") || error === 2) {
        console.log("[Settings] Creating default config at", settingsFile)
        settingsFileView.writeAdapter()
        root.isLoaded = true
        root.settingsLoaded()
      } else {
        console.error("[Settings] Load failed:", error)
      }
    }
  }

  JsonAdapter {
    id: adapter

    // appearance - fonts, transparency, and UI scale
    property JsonObject appearance: JsonObject {
      property JsonObject fonts: JsonObject {
        property string sans: "Google Sans"
        property string sansDisplay: "Google Sans"
      }
      property string transparency: "medium"
      property real scaleRatio: 1.0
    }

    // animations
    property JsonObject animations: JsonObject {
      property real speed: 1.0
      property bool disabled: false
    }

    // shadows
    property JsonObject shadows: JsonObject {
      property string color: "#80000000"
      property real blur: 1.0
      property int verticalOffset: 4
      property int horizontalOffset: 0
    }

    // bar
    property JsonObject bar: JsonObject {
      property int height: 26
    }

    // control center
    property JsonObject controlCenter: JsonObject {
      property int width: 360
      property int height: 620
      property int posX: 28
      property int posY: 28
      property string radius: "xl"
    }

    // calendar
    property JsonObject calendar: JsonObject {
      property int width: 360
      property int height: 560
      property int posY: 28
      property string radius: "xl"
    }

    // notification center
    property JsonObject notificationCenter: JsonObject {
      property int width: 360
      property int height: 600
      property int marginFromEdge: 28
      property int posY: 28
      property string radius: "xl"
    }

    // launcher
    property JsonObject launcher: JsonObject {
      property int width: 500
      property int height: 600
      property string radius: "xl"
    }

    // menu
    property JsonObject menu: JsonObject {
      property int width: 460
      property int height: 560
      property string radius: "xl"
    }

    // wallpaper picker
    property JsonObject wallpaperPicker: JsonObject {
      property int width: 900
      property int height: 700
      property string radius: "xl"
    }

    // emoji picker
    property JsonObject emojiPicker: JsonObject {
      property int width: 460
      property int height: 550
      property string radius: "xl"
    }

    // power menu
    property JsonObject powerMenu: JsonObject {
      property int width: 700
      property int height: 450
      property string radius: "xl"
    }

    // screen recording
    property JsonObject screenRecording: JsonObject {
      property int width: 700
      property int height: 350
      property string radius: "xl"
    }

    // matugen
    property JsonObject matugen: JsonObject {
      property int width: 650
      property int height: 580
      property string radius: "xl"
    }

    // weather
    property JsonObject weather: JsonObject {
      property int width: 850
      property int height: 550
      property string radius: "lg"
    }
  }
}
