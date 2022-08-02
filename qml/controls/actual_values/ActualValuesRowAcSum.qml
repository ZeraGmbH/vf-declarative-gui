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
    property color colorU
    property color colorI
    GridItem {
        width: row.columnWidth*0.7
        height: row.rowHeight
        color: GC.tableShadeColor
        text: NAME !== undefined ? NAME : ""
        font.bold: true
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: SUM_P !== undefined ? FT.formatNumber(SUM_P) : ""
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: SUM_LAMDA !== undefined ? FT.formatNumber(SUM_LAMDA) : ""
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FREQ !== undefined ? FT.formatNumber(FREQ) : ""
    }
    GridItem {
        width: row.columnWidth/2
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
    }
}