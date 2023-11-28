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
    readonly property int rowCount: ZGL.ActualValueEmobDcModel.rowCount() +
                                    ZGL.TempHumidityPressureModel.rowCount() + 6
    readonly property real rowHeight: height/rowCount

    ListView {
        id: dcTable
        model: ZGL.ActualValueEmobDcModel
        height: model.rowCount() * rowHeight
        boundsBehavior: Flickable.StopAtBounds
        delegate: Component {
            ActualValuesRowEmobDc {
                rowHeight: root.rowHeight
                rowWidth: root.width
                colorU: GC.colorUAux1
                colorI: GC.colorIAux1
            }
        }
    }
    ListView {
        id: tempHumPressTable
        model: ZGL.TempHumidityPressureModel
        anchors.top: dcTable.bottom
        height: model.rowCount() * rowHeight
        boundsBehavior: Flickable.StopAtBounds
        delegate: Component {
            TempHumidityPressureRow {
                rowHeight: root.rowHeight
                rowWidth: root.width
            }
        }
    }
}
