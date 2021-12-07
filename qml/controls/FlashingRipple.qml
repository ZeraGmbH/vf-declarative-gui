import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Material.impl 2.14

// flash effect for user notification
Ripple {
    id: root
    function startFlash() {
        if(!ignoreFirst) {
            active = true
            rippleTimer.start()
        }
        ignoreFirst = false
    }
    property bool ignoreFirst: true
    clipRadius: 2
    anchors.fill: parent
    color: Material.highlightedRippleColor // Material.rippleColor
    Timer {
        id: rippleTimer
        interval: 700
        onTriggered: { root.active = false }
    }
}
