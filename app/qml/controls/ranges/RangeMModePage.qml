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
    anchors.rightMargin: showMeasModes ? -8 : 0 // hack to compensate Main.Qml global margin in StackLayout

    readonly property int rowCount: 10
    readonly property real rowHeight: height / rowCount
    readonly property real pointSize: rowHeight > 0 ? rowHeight * 0.325 : 10
    readonly property real upperAreaHeight: rowHeight*2
    readonly property real leftWidth: root.width * (showMeasModes ? 0.775 : 1)
    readonly property real frameMargin: rowHeight * 0.3

    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

    GridRect {
        id: upperAreaLeft
        anchors { top: parent.top; left: parent.left }
        height: upperAreaHeight
        width: leftWidth
        Item {
            id: rangeAutomaticLine
            anchors { top: parent.top; left: parent.left }
            height: rowHeight
            VFSwitch {
                text: Z.tr("Range automatic")
                anchors { left: parent.left; leftMargin: frameMargin }
                leftPadding: 0
                height: rowHeight
                width: implicitWidth * 1.05
                font.pointSize: pointSize
                entity: rangeModule
                enabled: enableRangeAutomaticAndGrouping
                controlPropertyName: "PAR_RangeAutomatic"
            }
        }
        Item {
            anchors { top: rangeAutomaticLine.bottom; left: parent.left }
            height: rowHeight
            VFSwitch {
                text: Z.tr("Range grouping")
                anchors { left: parent.left; leftMargin: frameMargin }
                leftPadding: 0
                height: rowHeight
                width: implicitWidth * 1.05
                font.pointSize: pointSize
                entity: rangeModule
                enabled: enableRangeAutomaticAndGrouping
                controlPropertyName: "PAR_ChannelGrouping"
            }
        }
        OverloadButton {
            id: overloadButton
            anchors { margins: frameMargin; right: parent.right; verticalCenter: parent.verticalCenter }
            implicitWidth: parent.width * 0.33
            height: rowHeight
            font.pointSize: pointSize
        }
    }

    GridRect {
        id: lowerAreaLeft
        anchors { top: upperAreaLeft.bottom; bottom: parent.bottom; left: parent.left }
        width: leftWidth
        GridRect {
            id: uArea
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: lowerAreaLeft.height * 0.5
            RangeLine {
                id: uRangeLine
                anchors { top:parent.top; margins: frameMargin; left: parent.left; right: parent.right }
                height: rowHeight * 2
                spacing: frameMargin
                channels: MeasChannelInfo.voltageChannelIds
                rangeComboRows: 6
            }
            Loader {
                sourceComponent: uRatio
                active: showRatioLines
                anchors { top: uRangeLine.bottom; topMargin: 1.5*frameMargin; margins: frameMargin; left: parent.left; right: parent.right }
                height: rowHeight
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
            anchors { top: uArea.bottom; left: parent.left; right: parent.right }
            height: lowerAreaLeft.height * 0.5
            RangeLine {
                id: iRangeLine
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: frameMargin }
                height: rowHeight * 2
                spacing: frameMargin
                channels: MeasChannelInfo.currentChannelIds
                rangeComboRows: 5
            }
            Loader {
                sourceComponent: iRatio
                active: showRatioLines
                anchors { top: iRangeLine.bottom; topMargin: 1.55*frameMargin; margins: frameMargin; left: parent.left; right: parent.right }
                height: rowHeight
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
        anchors { top: parent.top; bottom: parent.bottom; left: upperAreaLeft.right; right: parent.right }
    }
    Component {
        id: measModeComponent
        Item {
            anchors.fill: parent
            Item {
                id: upperAreaRight
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: upperAreaHeight
                Label {
                    text: Z.tr("Measurement modes")
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: frameMargin }
                    height: rowHeight*2
                    wrapMode: Label.WordWrap
                    verticalAlignment: Label.AlignBottom
                    font.pointSize: pointSize
                }
            }
            MeasModeComboListView {
                anchors { top: upperAreaRight.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: frameMargin }
            }
        }
    }
}
