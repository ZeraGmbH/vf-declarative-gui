import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import "../../controls"

Row {
    id: row
    property real rowHeight
    property real rowWidth
    property real leftColumWithsScale
    property real rightColumWithsScale

    readonly property int dataColums: 4
    readonly property real columnWidth: rowWidth / (leftColumWithsScale + dataColums + rightColumWithsScale)
    readonly property bool isCurrent: Name === Z.tr("kI") || Name === Z.tr("I") || Name === Z.tr("∠I")
    readonly property string rowColor: index === 0 ? CS.tableShadeColor : Material.backgroundColor
    GridItem {
        width: row.columnWidth * leftColumWithsScale
        height: row.rowHeight
        color: CS.tableShadeColor
        text: Name!==undefined ? Name : ""
        font.bold: true
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: rowColor
        text: FT.formatNumberForScaledValues(L1) + FT.getLambdaPowerTypeString(LOAD_TYPE1)
        textColor: isCurrent ? CS.colorIL1 : CS.colorUL1
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: rowColor
        text: FT.formatNumberForScaledValues(L2) + FT.getLambdaPowerTypeString(LOAD_TYPE2)
        textColor: isCurrent ? CS.colorIL2 : CS.colorUL2
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: rowColor
        text: FT.formatNumberForScaledValues(L3) + FT.getLambdaPowerTypeString(LOAD_TYPE3)
        textColor: isCurrent ? CS.colorIL3 : CS.colorUL3
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: rowColor
        text: FT.formatNumberForScaledValues(Sum) + FT.getLambdaPowerTypeString(LOAD_TYPE_SUM)
    }
    GridItem {
        width: row.columnWidth * rightColumWithsScale
        height: row.rowHeight
        color: rowColor
        text: Unit ? Unit : ""
    }
}
