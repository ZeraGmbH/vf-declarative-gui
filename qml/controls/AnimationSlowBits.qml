import QtQuick 2.14
import QtQuick.Controls 2.12

// This is an interim cheap charly so we have something. Hope we'll find time
// for a more fancy animation
Item {
    BusyIndicator {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: parent.height
    }
}
