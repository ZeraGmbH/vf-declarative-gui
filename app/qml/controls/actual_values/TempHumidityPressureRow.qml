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
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(Temperature)
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(Humidity)
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(Pressure)
    }
    GridItem {
        width: columnWidth * rightColumWithsScale
        height: rowHeight
        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
    }
}
