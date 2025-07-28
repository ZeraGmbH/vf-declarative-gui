import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import ZeraThemeConfig 1.0
import "../../controls"

Row {
    id: row
    property real rowHeight
    property real rowWidth
    property real leftColumWithsScale
    property real rightColumWithsScale
    property bool noHeaderRows

    readonly property int dataColums: 4
    readonly property real columnWidth: rowWidth * (1-(leftColumWithsScale+rightColumWithsScale)) / dataColums
    readonly property bool isCurrent: Name === Z.tr("kI") || Name === Z.tr("I") || Name === Z.tr("∠I")
    readonly property bool isHeaderRow: index === 0 && !noHeaderRows
    GridItem {
        width: row.rowWidth * leftColumWithsScale
        height: row.rowHeight
        color: ZTC.tableHeaderColor
        text: Name!==undefined ? Name : ""
        font.bold: true
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: isHeaderRow ? ZTC.tableHeaderColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(L1)
        textColor: isCurrent ? CS.colorIL1 : CS.colorUL1
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: isHeaderRow ? ZTC.tableHeaderColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(L2)
        textColor: isCurrent ? CS.colorIL2 : CS.colorUL2
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: isHeaderRow ? ZTC.tableHeaderColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(L3)
        textColor: isCurrent ? CS.colorIL3 : CS.colorUL3
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: isHeaderRow ? ZTC.tableHeaderColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(AUX)
        textColor: isCurrent ? CS.colorIAux1 : CS.colorUAux1
    }
    GridItem {
        width: row.rowWidth * rightColumWithsScale
        height: row.rowHeight
        color: isHeaderRow ? ZTC.tableHeaderColor : Material.backgroundColor
        text: Unit ? Unit : ""
    }
}
