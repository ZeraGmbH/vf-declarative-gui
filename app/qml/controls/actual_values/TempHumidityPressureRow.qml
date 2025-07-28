import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import ZeraThemeConfig 1.0
import "../../controls"

Row {
    property real rowHeight
    property real rowWidth
    property real leftColumWithsScale
    property real rightColumWithsScale

    readonly property int dataColums: 3
    readonly property real columnWidth: rowWidth / (leftColumWithsScale + dataColums + rightColumWithsScale)

    readonly property bool bleAvail: VeinEntity.hasEntity("BleModule1")
    readonly property bool bluetoothOn: bleAvail && VeinEntity.getEntity("BleModule1").PAR_BluetoothOn

    Loader {
        active: bluetoothOn
        sourceComponent: GridItem {
            width: columnWidth * leftColumWithsScale
            height: rowHeight
            color: ZTC.tableHeaderColor
            }
        }

    Loader {
        active: bluetoothOn
        sourceComponent: GridItem {
            width: columnWidth
            height: rowHeight
            color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
            text: FT.formatNumberParamForScaledValues(Temperature, GC.digitsTotal, 1)
            }
        }

    Loader {
        active: bluetoothOn
        sourceComponent: GridItem {
            width: columnWidth
            height: rowHeight
            color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
            text: FT.formatNumberParamForScaledValues(Humidity, GC.digitsTotal, 1)
            }
        }

    Loader {
       active: bluetoothOn
       sourceComponent: GridItem {
            width: columnWidth
            height: rowHeight
            color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
             text: FT.formatNumberParamForScaledValues(Pressure, GC.digitsTotal, 1)
            }
        }

    Loader {
       active: bluetoothOn
       sourceComponent: GridItem {
            width: columnWidth * rightColumWithsScale
            height: rowHeight
            color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
            }
        }
}
