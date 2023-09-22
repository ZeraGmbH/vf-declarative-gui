import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
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
    GridItem {
        width: row.columnWidth * leftColumWithsScale
        height: row.rowHeight
        color: GC.tableShadeColor
        text: Name!==undefined ? Name : ""
        font.bold: true
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberFast(L1)
        textColor: isCurrent ? GC.colorIL1 : GC.colorUL1
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberFast(L2)
        textColor: isCurrent ? GC.colorIL2 : GC.colorUL2
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberFast(L3)
        textColor: isCurrent ? GC.colorIL3 : GC.colorUL3
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberFast(Sum)
    }
    GridItem {
        width: row.columnWidth * rightColumWithsScale
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: Unit ? Unit : ""
    }
}
