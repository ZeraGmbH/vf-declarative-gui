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

    readonly property bool noTemp: isNaN(VeinEntity.getEntity("BleModule1").ACT_TemperatureC)
    readonly property bool noHumidity: isNaN(VeinEntity.getEntity("BleModule1").ACT_Humidity)
    readonly property bool noPressure: isNaN(VeinEntity.getEntity("BleModule1").ACT_AirPressure)

    Loader {
        active: !noTemp || !noHumidity || !noPressure
        sourceComponent: GridItem {
            width: columnWidth * leftColumWithsScale
            height: rowHeight
            color: GC.tableShadeColor
        }
    }
    Loader {
        active: !noTemp
        sourceComponent: GridItem {
            width: columnWidth
            height: rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: FT.formatNumberForScaledValues(Temperature)
        }
    }
    Loader {
        active: !noHumidity
        sourceComponent: GridItem {
            width: columnWidth
            height: rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: FT.formatNumberForScaledValues(Humidity)
        }
    }
    Loader {
        active: !noPressure
        sourceComponent: GridItem {
            width: columnWidth
            height: rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: FT.formatNumberForScaledValues(Pressure)
        }
    }
    Loader {
        active: !noTemp && !noHumidity && !noPressure
        sourceComponent: GridItem {
            width: columnWidth * rightColumWithsScale
            height: rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        }
    }
}
