import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ModuleIntrospection 1.0
import MeasChannelInfo 1.0
import ZeraTranslation  1.0
import VeinEntity 1.0
import ZeraVeinComponents 1.0
import ZeraComponents 1.0
import FontAwesomeQml 1.0
import "../../controls"

Item {
    id: root

    property bool showMeasModes: true
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
            Label {
                text: Z.tr("Range automatic:")
                anchors.left: parent.left
                anchors.leftMargin: frameMargin
                verticalAlignment: Label.AlignVCenter
                height: rowHeight
                font.pointSize: pointSize
                color: enableRangeAutomaticAndGrouping ? Material.primaryTextColor : Material.hintTextColor
            }
            VFSwitch {
                id: autoMode
                anchors.right: parent.right
                height: rowHeight
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
            Label {
                text: Z.tr("Range grouping:")
                anchors.left: parent.left
                anchors.leftMargin: frameMargin
                verticalAlignment: Label.AlignVCenter
                height: rowHeight
                font.pointSize: pointSize
                color: enableRangeAutomaticAndGrouping ? Material.primaryTextColor : Material.hintTextColor
            }
            VFSwitch {
                id: groupingMode
                anchors.right: parent.right
                height: rowHeight
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
                anchors.top: parent.top
                height: rowHeight * 2
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: frameMargin
                spacing: frameMargin
                channels: MeasChannelInfo.voltageChannelIds
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
                spacing: frameMargin
                channels: MeasChannelInfo.currentChannelIds
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

            ListView {
                id: lowerAreaRight
                anchors.top: upperAreaRight.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: frameMargin
                model: VeinEntity.hasEntity("POWER1Module4") ? 4 : 3
                delegate: Item {
                    id: mmodeEntry
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: rowHeight * 2
                    readonly property real headerHeight: height * 0.2
                    readonly property real comboHeight: height * 0.6
                    Label {
                        id: mmodeLabel
                        height: mmodeEntry.headerHeight
                        anchors.left: parent.left
                        anchors.top: parent.top
                        verticalAlignment: Label.AlignBottom
                        font.pointSize: pointSize
                        text: {
                            let labelText = ""
                            switch(index) {
                            case 0:
                                labelText = VeinEntity.getEntity("POWER1Module1").ACT_PowerDisplayName
                                break
                            case 1:
                                labelText = VeinEntity.getEntity("POWER1Module2").ACT_PowerDisplayName
                                break
                            case 2:
                                labelText = VeinEntity.getEntity("POWER1Module3").ACT_PowerDisplayName
                                break
                            case 3:
                                let power4Name = VeinEntity.getEntity("POWER1Module4").ACT_PowerDisplayName
                                let power4NameColored = "<font color='" + "lawngreen" + "'>" + power4Name + "</font>"
                                labelText = String("P/Q/S").replace(power4Name, power4NameColored)
                                break
                            }
                            return labelText + ":"
                        }
                    }
                    Label {
                        id: labelBnc
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: headerHeight
                        font.pointSize: pointSize
                        verticalAlignment: Label.AlignBottom
                        text: FAQ.fa_dot_circle
                        visible: measModeCombo.entity.PAR_FOUT0 !== ""
                    }
                    MeasModeCombo {
                        id: measModeCombo
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: mmodeLabel.bottom
                        height: mmodeEntry.comboHeight
                        power1ModuleIdx: index
                        pointSize: root.pointSize
                    }
                }
            }
        }
    }
}
