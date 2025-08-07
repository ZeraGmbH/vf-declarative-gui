import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.14
import TableEventDistributor 1.0
import "../controls/actual_values"

Rectangle {
    id: root
    readonly property QtObject model: ZGL.ActualValueModel
    readonly property real rowHeight: height / model.rowCount()
    color: Material.backgroundColor
    ListView {
        anchors.fill: parent
        model: root.model
        boundsBehavior: Flickable.StopAtBounds
        delegate:  ActualValuesRow {
            rowHeight: root.rowHeight
            rowWidth: root.width
            leftColumWithsScale: 0.9
            rightColumWithsScale: 0.4
        }
    }
}
