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
    readonly property int rowCount:
        ZGL.ActualValueDCPerPhaseUModel.rowCount() +
        ZGL.ActualValueDCSinglePhaseIModel.rowCount() +
        ZGL.ActualValueDCPerPhasePModel.rowCount()
    readonly property real rowHeight: height/rowCount
    readonly property real leftColumWithsScale: 0.092
    readonly property real rightColumWithsScale: 0.092

    Item {
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        ListView {
            id: dcUTable
            model: ZGL.ActualValueDCPerPhaseUModel
            height: model.rowCount() * rowHeight
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                ActualValuesRowDcPerPhase {
                    rowHeight: root.rowHeight
                    rowWidth: root.width
                    leftColumWithsScale: root.leftColumWithsScale
                    rightColumWithsScale: root.rightColumWithsScale
                    noHeaderRows: false
                }
            }
        }
        ListView {
            id: dciTable
            anchors.top: dcUTable.bottom
            model: ZGL.ActualValueDCSinglePhaseIModel
            height: model.rowCount() * rowHeight
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                ActualValuesRowDcOnePhase {
                    rowHeight: root.rowHeight
                    rowWidth: root.width
                    leftColumWithsScale: root.leftColumWithsScale
                    rightColumWithsScale: root.rightColumWithsScale
                    noHeaderRows: true
                }
            }
        }
        ListView {
            id: dcpTable
            anchors.top: dciTable.bottom
            model: ZGL.ActualValueDCPerPhasePModel
            height: model.rowCount() * rowHeight
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                ActualValuesRowDcPerPhase {
                    rowHeight: root.rowHeight
                    rowWidth: root.width
                    leftColumWithsScale: root.leftColumWithsScale
                    rightColumWithsScale: root.rightColumWithsScale
                    noHeaderRows: true
                }
            }
        }
    }
}
