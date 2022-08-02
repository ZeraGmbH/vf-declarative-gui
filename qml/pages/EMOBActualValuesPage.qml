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
    Item {
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        ListView {
            anchors.fill: parent
            model: ZGL.ActualValueOnlyPModel
            boundsBehavior: Flickable.StopAtBounds

            delegate: Component {
                ActualValuesRow {
                    rowHeight: root.height/8
                    columnWidth: root.width/5.2
                }
            }
        }
    }
}
