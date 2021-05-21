import QtQuick 2.14

SequentialAnimation {
    property var targetItem
    onRunningChanged: {
        if(!running) {
            targetItem.opacity = 1.0
        }
    }
    loops: Animation.Infinite
    NumberAnimation { target: targetItem; property: "opacity"; to: 0.5; duration: 600 }
    NumberAnimation { target: targetItem; property: "opacity"; to: 1.0; duration: 600 }
}
