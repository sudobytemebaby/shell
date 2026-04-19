import QtQuick
import "../../../../shared/theme"
import "../../../../shared/components/Animations"

Item {
  id: root

  property real value: 0.5
  property bool isMuted: false
  property bool isDragging: false

  signal sliderMoved(real newValue)

  implicitWidth: Config.osd.sliderWidth
  implicitHeight: Config.osd.sliderHeight

  function clamp(valueToClamp) {
    return Math.max(0, Math.min(1, valueToClamp))
  }

  function valueFromHandle() {
    return clamp((handle.x + handle.width / 2) / track.width)
  }

  function valueFromPosition(positionX) {
    return clamp(positionX / track.width)
  }

  Rectangle {
    id: track
    anchors {
      left: parent.left
      right: parent.right
      verticalCenter: parent.verticalCenter
    }
    height: Config.osd.trackHeight
    radius: Config.radius.sm
    color: Theme.surface_container_highest

    Rectangle {
      anchors {
        left: parent.left
        top: parent.top
        bottom: parent.bottom
      }
      width: Math.max(0, Math.min(parent.width, parent.width * root.value))
      radius: parent.radius
      color: root.isMuted ? Theme.outline : Theme.primary

      AColor on color {}

      Behavior on width {
        enabled: !handleArea.drag.active
        NumberAnimation {
          duration: 100
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  Rectangle {
    id: handle
    x: Math.max(0, Math.min(track.width - width, (track.width - width) * root.value))
    anchors.verticalCenter: track.verticalCenter
    width: Config.osd.handleSize
    height: Config.osd.handleSize
    radius: Config.radius.full
    color: root.isMuted ? Theme.outline : Theme.primary
    border.color: Theme.surface_container_low
    border.width: Config.osd.handleBorderWidth

    scale: handleArea.pressed || handleArea.containsMouse ? 1.2 : 1.0

    AColor on color {}

    Behavior on x {
      enabled: !handleArea.drag.active
      NumberAnimation {
        duration: 100
        easing.type: Easing.OutCubic
      }
    }

    AScale on scale {}

    MouseArea {
      id: handleArea
      anchors.fill: parent
      anchors.margins: -8
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor

      drag.target: handle
      drag.axis: Drag.XAxis
      drag.minimumX: 0
      drag.maximumX: track.width - handle.width

      onPressed: {
        root.isDragging = true
      }

      onReleased: {
        root.isDragging = false
      }

      onCanceled: {
        root.isDragging = false
      }

      onPositionChanged: {
        if (drag.active) {
          root.sliderMoved(root.valueFromHandle())
        }
      }
    }
  }

  MouseArea {
    anchors.fill: track
    z: -1

    onClicked: function(mouse) {
      root.sliderMoved(root.valueFromPosition(mouse.x))
    }
  }
}
