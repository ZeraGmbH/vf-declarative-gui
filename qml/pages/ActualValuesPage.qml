import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import "../controls"

Item {
    id: root

    readonly property int rowHeight: Math.floor(height/14)
    readonly property int columnWidth: width/5.25

    Item {
        width: root.columnWidth*5.25
        height: root.height
        anchors.centerIn: parent
        ListView {
            anchors.fill: parent
            model: ZGL.ActualValueModel
            boundsBehavior: Flickable.StopAtBounds

            delegate: Component {
                Row {
                    width: root.columnWidth*5.2
                    height: root.rowHeight
                    readonly property bool isCurrent: Name === Z.tr("kI") || Name === Z.tr("I") || Name === Z.tr("∠I")
                    GridItem {
                        width: root.columnWidth*0.7
                        height: root.rowHeight
                        color: GC.tableShadeColor
                        text: Name!==undefined ? Name : ""
                        font.bold: true
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                        text: L1!==undefined ? FT.formatNumber(L1) : ""
                        textColor: isCurrent ? GC.colorIL1 : GC.colorUL1
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                        text: L2!==undefined ? FT.formatNumber(L2) : ""
                        textColor: isCurrent ? GC.colorIL2 : GC.colorUL2
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                        text: L3!==undefined ? FT.formatNumber(L3) : ""
                        textColor: isCurrent ? GC.colorIL3 : GC.colorUL3
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                        text: Sum ? FT.formatNumber(Sum) : ""
                    }
                    GridItem {
                        width: root.columnWidth/2
                        height: root.rowHeight
                        color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                        text: Unit ? Unit : ""
                    }
                }
            }
        }
    }
}
