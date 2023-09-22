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
    property color colorU
    property color colorI

    readonly property int dataColums: 3
    readonly property real columnWidth: rowWidth / (leftColumWithsScale + dataColums + rightColumWithsScale)
    GridItem {
        width: columnWidth * leftColumWithsScale
        height: rowHeight
        color: GC.tableShadeColor
        text: NAME !== undefined ? NAME : ""
        textHorizontalAlignment: index === 0 ? Label.AlignHCenter : Label.AlignRight
        font.bold: true
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(DC_U)
        textColor: colorU
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(DC_I)
        textColor: colorI
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(DC_P)
    }
    GridItem {
        width: columnWidth * rightColumWithsScale
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
    }
}
