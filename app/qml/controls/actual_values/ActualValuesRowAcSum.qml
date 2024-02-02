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
    GridItem {
        width: columnWidth * leftColumWithsScale
        height: rowHeight
        color: GC.tableShadeColor
        text: NAME !== undefined ? NAME : ""
        font.bold: true
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: Material.backgroundColor
        text: FT.formatNumberForScaledValues(SUM_P)
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: Material.backgroundColor
        text: FT.formatNumberForScaledValues(SUM_LAMDA) + FT.getLambdaPowerTypeString(SUM_LAMDA_LOAD_TYPE)
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: Material.backgroundColor
        text: FT.formatNumberForScaledValues(FREQ)
    }
    GridItem {
        width: columnWidth * rightColumWithsScale
        height: rowHeight
        color: Material.backgroundColor
    }
}
