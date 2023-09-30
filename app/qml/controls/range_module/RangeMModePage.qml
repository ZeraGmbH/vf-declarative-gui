import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraTranslation  1.0
import VeinEntity 1.0
import ZeraVeinComponents 1.0
import ZeraComponents 1.0
import QtQml.Models 2.11
import "../../controls"

Item {
    id: root

    readonly property int rowCount: 10
    readonly property real rowHeight: height / rowCount
    readonly property real pointSize: rowHeight > 0 ? rowHeight * 0.325 : 10
    readonly property real upperAreaHeight: rowHeight*2
    readonly property real leftWidth: root.width * 3 / 4

    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property bool groupingActive: groupingMode.checked
    readonly property real frameMargin: rowHeight * 0.3

    GridRect {
        id: upperAreaLeft
        anchors.top: parent.top
        height: upperAreaHeight
        anchors.left: parent.left
        width: leftWidth
        Item {
            id: rangeAutomaticLine
            anchors.top: parent.top
            width: parent.width
            height: rowHeight
            Label {
                text: Z.tr("Range automatic:")
                anchors.left: parent.left
                anchors.leftMargin: frameMargin
                verticalAlignment: Label.AlignVCenter
                height: rowHeight
                font.pointSize: pointSize
                color: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json" ? Material.primaryTextColor : Material.hintTextColor
            }
            VFSwitch {
                id: autoMode
                anchors.right: parent.right
                height: rowHeight
                entity: root.rangeModule
                enabled: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json"
                controlPropertyName: "PAR_RangeAutomatic"
            }
        }
        Item {
            anchors.top: rangeAutomaticLine.bottom
            width: parent.width
            height: rowHeight
            Label {
                text: Z.tr("Range grouping:")
                anchors.left: parent.left
                anchors.leftMargin: frameMargin
                verticalAlignment: Label.AlignVCenter
                height: rowHeight
                font.pointSize: pointSize
                color: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json" ? Material.primaryTextColor : Material.hintTextColor
            }
            VFSwitch {
                id: groupingMode
                anchors.right: parent.right
                height: rowHeight
                entity: root.rangeModule
                enabled: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json"
                controlPropertyName: "PAR_ChannelGrouping"
            }
        }

    }
    GridRect {
        id: upperAreaRight
        anchors.top: parent.top
        height: upperAreaHeight
        anchors.left: upperAreaLeft.right
        anchors.right: parent.right
        Button {
            id: overloadButton
            text: Z.tr("Overload")
            readonly property bool overload: root.rangeModule.PAR_Overload
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: frameMargin
            height: rowHeight
            enabled: overload
            font.pointSize: pointSize
            onClicked: {
                root.rangeModule.PAR_Overload = 0;
            }
            background: Rectangle {
                anchors.fill: parent
                radius: 2
                color: overloadButton.overload ? "darkorange" : Material.switchDisabledHandleColor
            }
        }
    }

    GridRect {
        id: lowerAreaLeft
        anchors.top: upperAreaLeft.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: leftWidth
        GridRect {
            id: uArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: lowerAreaLeft.height * 0.5
            RangeLine {
                anchors.top: parent.top
                height: rowHeight * 2
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: frameMargin
                // TODO:
                // * Less Naive approach
                // * COM5003 REF
                channels: channelCount >= 7 ? [1,2,3,7] : [1,2,3]
            }
        }
        GridRect {
            id: iArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: uArea.bottom
            height: lowerAreaLeft.height * 0.5
            RangeLine {
                anchors.top: parent.top
                height: rowHeight * 2
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: frameMargin
                // TODO:
                // * Less Naive approach
                // * COM5003 REF
                channels: channelCount >= 8 ? [4,5,6,8] : [4,5,6]
            }
        }
    }
}
