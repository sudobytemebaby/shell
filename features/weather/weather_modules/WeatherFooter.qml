import QtQuick
import QtQuick.Layouts
import "../../../shared/theme"

ColumnLayout {
    spacing: Theme.spacing.md
    
    property int currentIndex: 0
    property int pageCount: 3
    property string lastUpdate: ""
    signal indexSelected(int index)
    
    // Navigation Dots
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spacing.sm
        
        Repeater {
            model: pageCount
            
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: index === currentIndex ? Theme.primary : Theme.surface_container_highest
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: indexSelected(index)
                }
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
    
    // Bottom Bar (Centered Text + Right-aligned Update)
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 20
        
        // Centered Help Text
        Text {
            anchors.centerIn: parent
            text: "Arrows to Switch • Esc Close"
            color: Theme.on_surface_variant
            font.pixelSize: Theme.typography.sm
            font.family: Theme.typography.fontFamily
            opacity: 0.7
        }
        
        // Right-aligned Last Update
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Theme.padding.sm
            visible: lastUpdate !== ""
            text: "Updated: " + lastUpdate
            color: Theme.on_surface_variant
            font.pixelSize: Theme.typography.xs
            font.family: Theme.typography.fontFamily
            opacity: 0.5
        }
    }
}