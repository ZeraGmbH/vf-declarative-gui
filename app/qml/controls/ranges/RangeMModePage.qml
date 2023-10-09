import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ModuleIntrospection 1.0
import MeasChannelInfo 1.0
import PowerModuleVeinGetter 1.0
import ZeraTranslation  1.0
import VeinEntity 1.0
import ZeraVeinComponents 1.0
import ZeraComponents 1.0
import FontAwesomeQml 1.0
import "../../controls"
import "../../controls/measurement_modes"

Item {
    id: root

    property bool showMeasModes: PwrModVeinGetter.canSessionChangeMMode
    property bool showRatioLines: true
    property bool enableRangeAutomaticAndGrouping: true

    readonly property int rowCount: 10
    readonly property real rowHeight: height / rowCount
    readonly property real pointSize: rowHeight > 0 ? rowHeight * 0.325 : 10
    readonly property real upperAreaHeight: rowHeight*2
    readonly property real leftWidth: root.width * (showMeasModes ? 0.8 : 1)
    readonly property real frameMargin: rowHeight * 0.3

    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

    GridRect {
        id: upperAreaLeft
        anchors.top: parent.top
        height: upperAreaHeight
        anchors.left: parent.left
        width: leftWidth
        Item {
            id: rangeAutomaticLine
            anchors.top: parent.top
            anchors.left: parent.left
            width: leftWidth * 0.5
            height: rowHeight
            VFSwitch {
                id: autoMode
                text: Z.tr("Range automatic")
                anchors.left: parent.left
                anchors.leftMargin: frameMargin
                anchors.right: parent.right
                height: rowHeight
                font.pointSize: pointSize
                entity: rangeModule
                enabled: enableRangeAutomaticAndGrouping
                controlPropertyName: "PAR_RangeAutomatic"
            }
        }
        Item {
            anchors.top: rangeAutomaticLine.bottom
            anchors.left: parent.left
            width: leftWidth * 0.5
            height: rowHeight
            VFSwitch {
                id: groupingMode
                text: Z.tr("Range grouping")
                anchors.left: parent.left
                anchors.leftMargin: frameMargin
                anchors.right: parent.right
                height: rowHeight
                font.pointSize: pointSize
                entity: rangeModule
                enabled: enableRangeAutomaticAndGrouping
                controlPropertyName: "PAR_ChannelGrouping"
            }
        }
        OverloadButton {
            id: overloadButton
            anchors.left: rangeAutomaticLine.right
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: frameMargin
            height: rowHeight
            font.pointSize: pointSize
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
                id: uRangeLine
                anchors.top: parent.top
                height: rowHeight * 2
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: frameMargin
                spacing: frameMargin
                channels: MeasChannelInfo.voltageChannelIds
            }
            Loader {
                sourceComponent: uRatio
                active: showRatioLines
                anchors.top: uRangeLine.bottom
                height: rowHeight
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: frameMargin
                anchors.topMargin: 1.5*frameMargin
            }
            Component {
                id: uRatio
                RatioLine {
                    anchors.fill: parent
                    prescalingGroup: 0
                }
            }
        }
        GridRect {
            id: iArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: uArea.bottom
            height: lowerAreaLeft.height * 0.5
            RangeLine {
                id: iRangeLine
                anchors.top: parent.top
                height: rowHeight * 2
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: frameMargin
                spacing: frameMargin
                channels: MeasChannelInfo.currentChannelIds
            }
            Loader {
                sourceComponent: iRatio
                active: showRatioLines
                anchors.top: iRangeLine.bottom
                height: rowHeight
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: frameMargin
                anchors.topMargin: 1.55*frameMargin
            }
            Component {
                id: iRatio
                RatioLine {
                    anchors.fill: parent
                    prescalingGroup: 1
                }
            }
        }
    }

    Loader {
        sourceComponent: measModeComponent
        active: showMeasModes
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: upperAreaLeft.right
        anchors.right: parent.right
    }
    Component {
        id: measModeComponent
        GridRect {
            anchors.fill: parent
            Item {
                id: upperAreaRight
                anchors.top: parent.top
                height: upperAreaHeight
                anchors.left: parent.left
                anchors.right: parent.right
                Label {
                    text: Z.tr("Measurement modes:")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: rowHeight*2
                    wrapMode: Label.WordWrap
                    anchors.margins: frameMargin
                    verticalAlignment: Label.AlignBottom
                    font.pointSize: pointSize
                }
            }
            MeasModeComboListView {
                anchors.top: upperAreaRight.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: frameMargin
            }
        }
    }
}
