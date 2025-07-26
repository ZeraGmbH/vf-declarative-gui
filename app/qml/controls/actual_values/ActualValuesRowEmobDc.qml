import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import ColorSettings 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import "../../controls"

Row {
    property real rowHeight
    property real rowWidth
    property color colorU
    property color colorI

    readonly property int dataColums: 3
    readonly property real columnWidth: rowWidth / (dataColums)
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? CS.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(DC_U)
        textColor: colorU
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? CS.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(DC_I)
        textColor: colorI
    }
    GridItem {
        width: columnWidth
        height: rowHeight
        color: index === 0 ? CS.tableShadeColor : Material.backgroundColor
        text: FT.formatNumberForScaledValues(DC_P)
        textColor: colorU
    }
}
