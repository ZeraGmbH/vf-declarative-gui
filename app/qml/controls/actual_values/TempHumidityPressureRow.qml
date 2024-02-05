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

    readonly property bool bleAvail: VeinEntity.hasEntity("BleModule1")
    readonly property bool tempAvail: bleAvail && !isNaN(VeinEntity.getEntity("BleModule1").ACT_TemperatureC)
    readonly property bool humidityAvail: bleAvail && !isNaN(VeinEntity.getEntity("BleModule1").ACT_Humidity)
    readonly property bool pressureAvail: bleAvail && !isNaN(VeinEntity.getEntity("BleModule1").ACT_AirPressure)

    Loader {
        active: tempAvail && humidityAvail && pressureAvail
        sourceComponent: GridItem {
            width: columnWidth * leftColumWithsScale
            height: rowHeight
            color: GC.tableShadeColor
        }
    }
    Loader {
        active: tempAvail
        sourceComponent: GridItem {
            width: columnWidth
            height: rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: FT.formatNumberParamForScaledValues(Temperature, GC.digitsTotal, 1)
        }
    }
    Loader {
        active: humidityAvail
        sourceComponent: GridItem {
            width: columnWidth
            height: rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: FT.formatNumberParamForScaledValues(Humidity, GC.digitsTotal, 1)
        }
    }
    Loader {
        active: pressureAvail
        sourceComponent: GridItem {
            width: columnWidth
            height: rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: FT.formatNumberParamForScaledValues(Pressure, GC.digitsTotal, 1)
        }
    }
    Loader {
        active: tempAvail || humidityAvail || pressureAvail
        sourceComponent: GridItem {
            width: columnWidth * rightColumWithsScale
            height: rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
        }
    }
}
