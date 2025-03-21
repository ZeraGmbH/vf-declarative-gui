import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.14

Rectangle {
    id: root

    property ObjectModel model;
    property int horizMargin: 0
    readonly property real safeHeight: height
    property real rowHeight: safeHeight/10
    property int rowWidth: sView.width - (sView.contentHeight > safeHeight ? scroller.width : 0) // don't overlap with the ScrollIndicator
    color: Material.backgroundColor
    ListView {
        id: sView
        anchors.fill: parent
        anchors.leftMargin: root.horizMargin
        anchors.rightMargin: root.horizMargin
        clip: true
        spacing: 0
        model: root.model
        boundsBehavior: Flickable.StopAtBounds
        ScrollIndicator.vertical: ScrollIndicator {
            id: scroller
            active: true
            onActiveChanged: {
                if(!active) {
                    active = true
                }
            }
        }
    }
}
