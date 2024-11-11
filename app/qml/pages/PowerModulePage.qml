import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import PowerModuleVeinGetter 1.0
import ZeraVeinComponents 1.0
import TableEventDistributor 1.0
import SortFilterProxyModel 0.2
import "../controls"
import "../controls/measurement_modes"

Item {
    id: root

    readonly property real row1stHeight: Math.floor(height/8)
    readonly property real rowHeight: Math.floor((height-2*row1stHeight)/3)
    readonly property int pixelSize: rowHeight*0.4

    readonly property real firstColumnWidth: width*0.1
    readonly property real valueColumnWidth: width*0.208
    readonly property real lastColumnWidth: width-firstColumnWidth-4*valueColumnWidth

    SortFilterProxyModel {
        id: filteredActualValueModel
        sourceModel: ZGL.ActualValueModel
        filters: [
            AnyOf {
                RegExpFilter {
                    roleName: "Name"
                    // empty string for header row
                    pattern: "^$"
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter {
                    roleName: "Type"
                    pattern: "Power" // just power rows
                    caseSensitivity: Qt.CaseInsensitive
                }
            }
        ]
    }
    ListView {
        id: listView
        anchors.top: parent.top
        anchors.bottom: footerRow.top
        width: parent.width
        model: filteredActualValueModel
        boundsBehavior: ListView.StopAtBounds
        interactive: false

        delegate: Component {
            Row {
                id: row
                height: index === 0 ? row1stHeight : rowHeight
                readonly property string rowColor: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                GridItem {
                    width: firstColumnWidth
                    height: parent.height
                    color: GC.tableShadeColor
                    text: Name!==undefined ? Name : ""
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    text: FT.formatNumberForScaledValues(L1)
                    font.pixelSize: pixelSize
                    color: row.rowColor
                    textColor: GC.colorUL1
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    text: FT.formatNumberForScaledValues(L2)
                    font.pixelSize: pixelSize
                    color: row.rowColor
                    textColor: GC.colorUL2
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    text: FT.formatNumberForScaledValues(L3)
                    font.pixelSize: pixelSize
                    color: row.rowColor
                    textColor: GC.colorUL3
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    font.pixelSize: pixelSize
                    color: row.rowColor
                    text: FT.formatNumberForScaledValues(Sum)
                }
                GridItem {
                    width: lastColumnWidth
                    height: parent.height
                    text: Unit
                    font.pixelSize: pixelSize*0.7
                    color: row.rowColor
                }
            }
        }
    }
    Row {
        id: footerRow
        height: root.row1stHeight
        width: parent.width
        anchors.bottom: parent.bottom
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
                                return Z.tr("Ext.")
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
