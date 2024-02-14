import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import "../controls"
import "../controls/actual_values"

Item {
    id: root
    readonly property bool bleAvail: VeinEntity.hasEntity("BleModule1")
    readonly property bool bluetoothOn: VeinEntity.getEntity("BleModule1").PAR_BluetoothOn

    readonly property int rowCount: {
        let showTempHumidPressure = root.bleAvail && root.bluetoothOn
        if(showTempHumidPressure)
            return ZGL.ActualValueEmobAcModel.rowCount() +
                   ZGL.ActualValueEmobAcSumModel.rowCount() +
                   ZGL.TempHumidityPressureModel.rowCount()
        else
            return ZGL.ActualValueEmobAcModel.rowCount() +
                   ZGL.ActualValueEmobAcSumModel.rowCount()
    }

    readonly property real rowHeight: height/rowCount
    readonly property real leftColumWithsScale: 0.4
    readonly property real rightColumWithsScale: 0.4

    Item {
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        ListView {
            id: acTable
            model: ZGL.ActualValueEmobAcModel
            anchors.top: parent.top
            height: model.rowCount() * rowHeight
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                ActualValuesRowNoSum {
                    rowHeight: root.rowHeight
                    rowWidth: root.width
                    leftColumWithsScale: root.leftColumWithsScale
                    rightColumWithsScale: root.rightColumWithsScale
                }
            }
        }
        ListView {
            id: acSumTable
            model: ZGL.ActualValueEmobAcSumModel
            anchors.top: acTable.bottom
            height: model.rowCount() * rowHeight
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                ActualValuesRowAcSum {
                    rowHeight: root.rowHeight
                    rowWidth: root.width
                    leftColumWithsScale: root.leftColumWithsScale
                    rightColumWithsScale: root.leftColumWithsScale
                }
            }
        }
        ListView {
            id: tempHumPressTable
            model: ZGL.TempHumidityPressureModel
            anchors.top: acSumTable.bottom
            height: model.rowCount() * rowHeight
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                TempHumidityPressureRow {
                    rowHeight: root.rowHeight
                    rowWidth: root.width
                    leftColumWithsScale: root.leftColumWithsScale
                    rightColumWithsScale: root.leftColumWithsScale
                }
            }
        }
    }
}
