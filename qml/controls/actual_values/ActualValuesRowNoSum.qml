import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import "../../controls"

Row {
    id: row
    property real rowHeight
    property real columnWidth
    readonly property bool isCurrent: Name === Z.tr("kI") || Name === Z.tr("I") || Name === Z.tr("∠I")
    GridItem {
        width: row.columnWidth*0.7
        height: row.rowHeight
        color: GC.tableShadeColor
        text: Name!==undefined ? Name : ""
        textHorizontalAlignment: index === 0 ? Label.AlignHCenter : Label.AlignRight
        font.bold: true
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: L1!==undefined ? FT.formatNumber(L1) : ""
        textColor: isCurrent ? GC.colorIL1 : GC.colorUL1
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: L2!==undefined ? FT.formatNumber(L2) : ""
        textColor: isCurrent ? GC.colorIL2 : GC.colorUL2
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: L3!==undefined ? FT.formatNumber(L3) : ""
        textColor: isCurrent ? GC.colorIL3 : GC.colorUL3
    }
    GridItem {
        width: row.columnWidth/2
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: Unit ? Unit : ""
    }
}