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
        ZGL.ActualValueLemDCPerPhaseUModel.rowCount() +
        ZGL.ActualValueLemDcSingleIModel.rowCount() +
        ZGL.ActualValueLemDcPerPhasePModel.rowCount()
    readonly property real rowHeight: height/rowCount
    readonly property real leftColumWithsScale: 0.092
    readonly property real rightColumWithsScale: 0.092
    property real topMarginPage

    Item {
        width: parent.width
        height: parent.height
        anchors.fill: parent
        anchors.topMargin: topMarginPage
        ListView {
            id: dcUTable
            model: ZGL.ActualValueLemDCPerPhaseUModel
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
            model: ZGL.ActualValueLemDcSingleIModel
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
            model: ZGL.ActualValueLemDcPerPhasePModel
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
