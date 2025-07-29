import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation 1.0
import ZeraThemeConfig 1.0
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
        color: ZTC.tableHeaderColor
        text: Name!==undefined ? Name : ""
        textHorizontalAlignment: index === 0 ? Label.AlignHCenter : Label.AlignRight
        font.bold: true
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(L1) + FT.getLambdaPowerTypeString(LOAD_TYPE1)
        textColor: isCurrent ? CS.colorIL1 : CS.colorUL1
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(L2) + FT.getLambdaPowerTypeString(LOAD_TYPE2)
        textColor: isCurrent ? CS.colorIL2 : CS.colorUL2
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(L3) + FT.getLambdaPowerTypeString(LOAD_TYPE3)
        textColor: isCurrent ? CS.colorIL3 : CS.colorUL3
    }
    GridItem {
        width: columnWidth * rightColumWithsScale
        height: rowHeight
        color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
        text: Unit ? Unit : ""
    }
}
