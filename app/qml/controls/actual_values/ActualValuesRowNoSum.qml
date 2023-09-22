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
    property real rowHeight
    property real rowWidth
    property real leftColumWithsScale
    property real rightColumWithsScale

    readonly property int dataColums: 3
    readonly property real columnWidth: rowWidth / (leftColumWithsScale + dataColums + rightColumWithsScale)
    readonly property bool isCurrent: Name === Z.tr("kI") || Name === Z.tr("I") || Name === Z.tr("∠I")
    GridItem {
        width: columnWidth * leftColumWithsScale
        height: rowHeight
        color: GC.tableShadeColor
        text: Name!==undefined ? Name : ""
        textHorizontalAlignment: index === 0 ? Label.AlignHCenter : Label.AlignRight
        font.bold: true
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberFast(L1)
        textColor: isCurrent ? GC.colorIL1 : GC.colorUL1
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberFast(L2)
        textColor: isCurrent ? GC.colorIL2 : GC.colorUL2
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberFast(L3)
        textColor: isCurrent ? GC.colorIL3 : GC.colorUL3
    }
    GridItem {
        width: columnWidth * rightColumWithsScale
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: Unit ? Unit : ""
    }
}
