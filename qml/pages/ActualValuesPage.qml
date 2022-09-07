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
    readonly property QtObject model: ZGL.ActualValueModel
    Item {
        anchors.fill: parent
        ListView {
            anchors.fill: parent
            model: root.model
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                ActualValuesRow {
                    rowHeight: root.height / root.model.rowCount()
                    rowWidth: root.width
                    leftColumWithsScale: 0.7
                    rightColumWithsScale: 0.5
                }
            }
        }
    }
}
