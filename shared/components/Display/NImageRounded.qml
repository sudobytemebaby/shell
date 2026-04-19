import QtQuick
import "../../theme"

Item {
  id: root

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  property real radius: 0
  property string imagePath: ""
  property string fallbackIcon: ""
  property real fallbackIconSize: Config.typography.xxxl
  property real borderWidth: 0
  property color borderColor: "transparent"
  property int imageFillMode: Image.PreserveAspectCrop

  readonly property bool showFallback: (fallbackIcon !== "" && imagePath === "")
  readonly property int status: imageSource.status

  // ============================================================================
  // CONTAINER WITH BORDER
  // ============================================================================

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: "transparent"
    border.width: root.borderWidth
    border.color: root.borderColor

    // ========================================================================
    // IMAGE SOURCE (HIDDEN)
    // ========================================================================

    Image {
      id: imageSource
      anchors.fill: parent
      anchors.margins: root.borderWidth
      visible: false
      source: root.imagePath
      mipmap: true
      smooth: true
      asynchronous: true
      antialiasing: true
      fillMode: root.imageFillMode
    }

    // ========================================================================
    // SHADER EFFECT (ROUNDED CORNERS)
    // ========================================================================

    ShaderEffect {
      anchors.fill: parent
      anchors.margins: root.borderWidth
      visible: !root.showFallback && imageSource.status === Image.Ready

      property variant source: imageSource
      property real itemWidth: width
      property real itemHeight: height
      property real sourceWidth: imageSource.sourceSize.width
      property real sourceHeight: imageSource.sourceSize.height
      property real cornerRadius: Math.max(0, root.radius - root.borderWidth)
      property real imageOpacity: 1.0
      property int fillMode: root.imageFillMode

      fragmentShader: "../../shaders/rounded_image.frag.qsb"
      supportsAtlasTextures: false
      blending: true
    }

    // ========================================================================
    // FALLBACK ICON
    // ========================================================================

    Text {
      anchors.fill: parent
      anchors.margins: root.borderWidth
      visible: root.showFallback || imageSource.status === Image.Error
      text: root.fallbackIcon || "󰸉"
      color: Theme.on_surface_variant
      font.pixelSize: root.fallbackIconSize
      font.family: Config.typography.sans
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      opacity: 0.5
    }

    // ========================================================================
    // LOADING INDICATOR
    // ========================================================================

    Item {
      anchors.centerIn: parent
      width: 48
      height: 48
      visible: imageSource.status === Image.Loading

      Rectangle {
        anchors.centerIn: parent
        width: 40
        height: 40
        radius: Config.radius.full
        color: Theme.primary_container

        Text {
          anchors.centerIn: parent
          text: ""
          color: Theme.on_primary_container
          font.pixelSize: Config.typography.xl
          font.family: Config.typography.sans

          RotationAnimation on rotation {
            running: parent.parent.visible
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 2000
          }
        }
      }
    }
  }
}
