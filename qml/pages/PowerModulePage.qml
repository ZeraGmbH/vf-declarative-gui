import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import PowerModuleVeinGetter 1.0
import ZeraVeinComponents 1.0
import "../controls"

Item {
    id: root

    readonly property int row1stHeight: Math.floor(height/8)
    readonly property int rowHeight: Math.floor((height-2*row1stHeight)/3)

    readonly property int firstColumnWidth: width*0.05
    readonly property int valueColumnWidth: width*0.22
    readonly property int lastColumnWidth: width-firstColumnWidth-4*valueColumnWidth

    Row {
        id: heardersRow
        height: root.row1stHeight
        GridRect {
            width: firstColumnWidth
            height: parent.height
            color: GC.tableShadeColor
            //spacer
        }
        GridItem {
            width: valueColumnWidth
            height: parent.height
            color: GC.tableShadeColor
            text: Z.tr("L1")
            textColor: GC.colorUL1
            font.pixelSize: rowHeight*0.4
        }
        GridItem {
            width: valueColumnWidth
            height: parent.height
            color: GC.tableShadeColor
            text: Z.tr("L2")
            textColor: GC.colorUL2
            font.pixelSize: rowHeight*0.4
        }
        GridItem {
            width: valueColumnWidth
            height: parent.height
            color: GC.tableShadeColor
            text: Z.tr("L3")
            textColor: GC.colorUL3
            font.pixelSize: rowHeight*0.4
        }
        GridItem {
            width: valueColumnWidth
            height: parent.height
            color: GC.tableShadeColor
            text: "Σ"
            font.pixelSize: rowHeight*0.4
        }
        GridItem {
            width: lastColumnWidth
            height: parent.height
            color: GC.tableShadeColor
            text: "[ ]"
            font.pixelSize: rowHeight*0.3
        }
    }

    ListView {
        id: listView
        anchors.top: heardersRow.bottom
        height: root.rowHeight*count
        width: parent.width
        //used number as model since the ListModel cannot use scripted values
        model: 3
        boundsBehavior: ListView.StopAtBounds
        interactive: false

        delegate: Component {
            Row {
                height: root.rowHeight
                GridItem {
                    width: firstColumnWidth
                    height: parent.height
                    color: GC.tableShadeColor
                    text: (PwrModVeinGetter.getEntityJsonInfo(index).ComponentInfo.ACT_PQS1.ChannelName).slice(0,1); //(P/Q/S)1 -> (P/Q/S)
                    font.pixelSize: height*0.4

                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    clip: true
                    text: FT.formatNumber(PwrModVeinGetter.getEntity(index).ACT_PQS1);
                    textColor: GC.colorUL1
                    font.pixelSize: height*0.4
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    clip: true
                    text: FT.formatNumber(PwrModVeinGetter.getEntity(index).ACT_PQS2);
                    textColor: GC.colorUL2
                    font.pixelSize: height*0.4
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    clip: true
                    text: FT.formatNumber(PwrModVeinGetter.getEntity(index).ACT_PQS3);
                    textColor: GC.colorUL3
                    font.pixelSize: height*0.4
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    clip: true
                    text: FT.formatNumber(PwrModVeinGetter.getEntity(index).ACT_PQS4);
                    font.pixelSize: height*0.4
                }
                GridItem {
                    width: lastColumnWidth
                    height: parent.height
                    clip: true
                    text: PwrModVeinGetter.getEntityJsonInfo(index).ComponentInfo.ACT_PQS1.Unit
                    font.pixelSize: height*0.25
                }
            }
        }
    }
    Row {
        id: footerRow
        height: root.row1stHeight
        width: parent.width
        anchors.top: listView.bottom
        GridRect {
            id: measModeGrid
            width: parent.width
            height: parent.height
            Repeater {
                model: VeinEntity.hasEntity("POWER1Module4") ? 4 : 3
                Item {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    x: root.firstColumnWidth+root.valueColumnWidth*(index)
                    width: root.valueColumnWidth
                    Label {
                        text: {
                            switch(index) {
                            case 0:
                                return VeinEntity.getEntity("POWER1Module1").ACT_PowerDisplayName
                            case 1:
                                return VeinEntity.getEntity("POWER1Module2").ACT_PowerDisplayName
                            case 2:
                                return VeinEntity.getEntity("POWER1Module3").ACT_PowerDisplayName
                            case 3:
                                return Z.tr("ext.")
                            }
                        }
                        height: parent.height
                        anchors.left: parent.left
                        anchors.rightMargin: GC.standardTextHorizMargin
                        anchors.leftMargin: GC.standardTextHorizMargin / 2
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: measModeGrid.height*0.4
                    }
                    MeasModeCombo {
                        id: measModeCombo
                        width: parent.width * 0.75
                        height: parent.height
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        power1ModuleIdx: index
                    }
                }
            }
        }
    }
}
