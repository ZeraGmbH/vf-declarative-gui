import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import "../controls"
import "../controls/actual_values"

Item {
    id: root
    property int rowCount: ZGL.ActualValueOnlyPModel.rowCount() + ZGL.ActualValue4thPhaseDcModel.rowCount()
    property real rowHeight: height/rowCount
    Item {
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        ListView {
            id: acTable
            model: ZGL.ActualValueOnlyPModel
            anchors.top: parent.top
            height: model.rowCount() * rowHeight
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                ActualValuesRow {
                    rowHeight: root.rowHeight
                    columnWidth: root.width/5.2
                }
            }
        }
        ListView {
            id: dcTable
            model: ZGL.ActualValue4thPhaseDcModel
            anchors.top: acTable.bottom
            height: model.rowCount() * rowHeight
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                ActualValuesRow {
                    rowHeight: root.rowHeight
                    columnWidth: root.width/5.2
                }
            }
        }
    }
}
