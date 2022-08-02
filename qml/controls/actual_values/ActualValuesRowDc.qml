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
        textHorizontalAlignment: index === 0 ? Label.AlignHCenter : Label.AlignRight
        font.bold: true
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: DC_U !== undefined ? FT.formatNumber(DC_U) : ""
        textColor: colorU
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: DC_I !== undefined ? FT.formatNumber(DC_I) : ""
        textColor: colorI
    }
    GridItem {
        width: row.columnWidth
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: DC_P !== undefined ? FT.formatNumber(DC_P) : ""
    }
    GridItem {
        width: row.columnWidth/2
        height: row.rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
    }
}
