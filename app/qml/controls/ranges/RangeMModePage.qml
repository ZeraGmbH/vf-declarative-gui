import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ModuleIntrospection 1.0
import MeasChannelInfo 1.0
import ZeraTranslation  1.0
import VeinEntity 1.0
import ZeraVeinComponents 1.0
import ZeraComponents 1.0
import "../../controls"

Item {
    id: root

    readonly property int rowCount: 10
    readonly property real rowHeight: height / rowCount
    readonly property real pointSize: rowHeight > 0 ? rowHeight * 0.325 : 10
    readonly property real upperAreaHeight: rowHeight*2
    readonly property real leftWidth: root.width * 3 / 4
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
                entity: MeasChannelInfo.rangeModule
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
                entity: MeasChannelInfo.rangeModule
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
        OverloadButton {
            anchors.left: parent.left
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
    GridRect {
        id: lowerAreaRight
        anchors.top: upperAreaLeft.bottom
        anchors.bottom: parent.bottom
        anchors.left: lowerAreaLeft.right
        anchors.right: parent.right
        ListView {
            anchors.fill: parent
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
                            labelText =  Z.tr("Ext.")
                            break
                        }
                        return labelText + ":"
                    }
                    height: mmodeEntry.headerHeight
                    anchors.left: parent.left
                    anchors.top: parent.top
                    verticalAlignment: Label.AlignBottom
                    font.pointSize: pointSize
                }
                MeasModeCombo {
                    id: measModeCombo
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: mmodeLabel.bottom
                    height: mmodeEntry.comboHeight
                    power1ModuleIdx: index
                }
            }
        }
    }
}
