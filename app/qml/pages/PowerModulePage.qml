import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ColorSettings 1.0
import FunctionTools 1.0
import PowerModuleVeinGetter 1.0
import ZeraVeinComponents 1.0
import TableEventDistributor 1.0
import SortFilterProxyModel 0.2
import "../controls"

Item {
    id: root

    readonly property real row1stHeight: Math.floor(height/5)
    readonly property real rowHeight: Math.floor((height-row1stHeight)/3)
    readonly property int pixelSize: rowHeight*0.4

    readonly property real firstColumnWidth: width*0.1
    readonly property real valueColumnWidth: width*0.208
    readonly property real lastColumnWidth: width-firstColumnWidth-4*valueColumnWidth

    SortFilterProxyModel {
        id: filteredActualValueModel
        sourceModel: ZGL.ActualValueModel
        filters: [
            AnyOf {
                RegExpFilter {
                    roleName: "Name"
                    // empty string for header row
                    pattern: "^$"
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter {
                    roleName: "Type"
                    pattern: "Power" // just power rows
                    caseSensitivity: Qt.CaseInsensitive
                }
            }
        ]
    }
    ListView {
        id: listView
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        model: filteredActualValueModel
        boundsBehavior: ListView.StopAtBounds
        interactive: false

        delegate: Component {
            Row {
                id: row
                height: index === 0 ? row1stHeight : rowHeight
                readonly property string rowColor: index === 0 ? CS.tableShadeColor : Material.backgroundColor
                GridItem {
                    width: firstColumnWidth
                    height: parent.height
                    color: CS.tableShadeColor
                    text: Name!==undefined ? Name : ""
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    text: FT.formatNumberForScaledValues(L1)
                    font.pixelSize: pixelSize
                    color: row.rowColor
                    textColor: CS.colorUL1
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    text: FT.formatNumberForScaledValues(L2)
                    font.pixelSize: pixelSize
                    color: row.rowColor
                    textColor: CS.colorUL2
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    text: FT.formatNumberForScaledValues(L3)
                    font.pixelSize: pixelSize
                    color: row.rowColor
                    textColor: CS.colorUL3
                }
                GridItem {
                    width: valueColumnWidth
                    height: parent.height
                    font.pixelSize: pixelSize
                    color: row.rowColor
                    text: FT.formatNumberForScaledValues(Sum)
                }
                GridItem {
                    width: lastColumnWidth
                    height: parent.height
                    text: Unit
                    font.pixelSize: pixelSize*0.7
                    color: row.rowColor
                }
            }
        }
    }
}
