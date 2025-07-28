import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import ZeraThemeConfig 1.0
import "../controls"

Item {
    id: ced_root

    readonly property int row1stHeight: Math.floor(height/8)
    readonly property int rowHeight: Math.floor((height-row1stHeight)/3)
    readonly property int pixelSize: rowHeight*0.3
    readonly property int columnWidth1st: pixelSize * 1.5
    readonly property int columnWidthLast: pixelSize * 1.3
    readonly property int columnWidth: (width-(columnWidth1st+columnWidthLast))/4 // 3phases + sum

    readonly property QtObject power2Module1: VeinEntity.getEntity("POWER2Module1")

    // We are:
    // not part of swipe/tab combo
    // loaded on demand (see main.qml / pageLoader.source)
    Component.onCompleted: {
        GC.currentGuiContext = GC.guiContextEnum.GUI_CED_POWER
    }

    function getProperty(index) {
        var retVal=String("");
        switch(index) {
        case 0:
            retVal = "ACT_PP%1";
            break;
        case 1:
            retVal = "ACT_PM%1";
            break;
        case 2:
            retVal = "ACT_P%1";
            break;
        }
        return retVal;
    }

    function getIntrospection(index) {
        var retVal;
        switch(index) {
        case 0:
            retVal = ModuleIntrospection.p2m1Introspection.ComponentInfo.ACT_PP1;
            break;
        case 1:
            retVal = ModuleIntrospection.p2m1Introspection.ComponentInfo.ACT_PM1;
            break;
        case 2:
            retVal = ModuleIntrospection.p2m1Introspection.ComponentInfo.ACT_P1;
            break;
        }
        return retVal;
    }
    Item {
        anchors.fill: parent
        Row {
            id: heardersRow
            GridRect {
                width: columnWidth1st
                height: row1stHeight
                color: ZTC.tableHeaderColor
                //spacer
            }
            GridItem {
                width: columnWidth
                height: row1stHeight
                color: ZTC.tableHeaderColor
                text: Z.tr("L1")
                textColor: CS.colorUL1
                font.pixelSize: pixelSize
            }
            GridItem {
                width: columnWidth
                height: row1stHeight
                color: ZTC.tableHeaderColor
                text: Z.tr("L2")
                textColor: CS.colorUL2
                font.pixelSize: pixelSize
            }
            GridItem {
                width: columnWidth
                height: row1stHeight
                color: ZTC.tableHeaderColor
                text: Z.tr("L3")
                textColor: CS.colorUL3
                font.pixelSize: pixelSize
            }
            GridItem {
                width: columnWidth
                height: row1stHeight
                color: ZTC.tableHeaderColor
                text: "Σ"
                textColor: CS.colorUL3
                font.pixelSize: pixelSize
            }
            GridItem {
                width: columnWidthLast
                height: row1stHeight
                color: ZTC.tableHeaderColor
                text: "[ ]"
                font.pixelSize: pixelSize
            }
        }

        ListView {
            anchors.top: heardersRow.bottom
            height: rowHeight*count
            width: parent.width
            //used number as model since the ListModel cannot use scripted values
            model: 3
            boundsBehavior: ListView.StopAtBounds
            interactive: false

            delegate: Component {
                Row {
                    GridItem {
                        //title
                        width: columnWidth1st
                        height: rowHeight
                        color: ZTC.tableHeaderColor
                        font.pixelSize: pixelSize
                        text: {
                            var retVal = "";
                            switch(index) {
                            case 0:
                                retVal = "+P";
                                break;
                            case 1:
                                retVal = "-P";
                                break;
                            case 2:
                                retVal = "P";
                                break;
                            }
                            return retVal;
                        }
                    }
                    GridItem {
                        //l1
                        width: columnWidth
                        height: rowHeight
                        textColor: CS.colorUL1
                        text: FT.formatNumber(power2Module1[String(ced_root.getProperty(index)).arg(1)]);
                        font.pixelSize: pixelSize
                    }
                    GridItem {
                        //l2
                        width: columnWidth
                        height: rowHeight
                        textColor: CS.colorUL2
                        text: FT.formatNumber(power2Module1[String(ced_root.getProperty(index)).arg(2)]);
                        font.pixelSize: pixelSize
                    }
                    GridItem {
                        //l3
                        width: columnWidth
                        height: rowHeight
                        textColor: CS.colorUL3
                        text: FT.formatNumber(power2Module1[String(ced_root.getProperty(index)).arg(3)]);
                        font.pixelSize: pixelSize
                    }
                    GridItem {
                        //pSum
                        width: columnWidth
                        height: rowHeight
                        text: FT.formatNumber(power2Module1[String(ced_root.getProperty(index)).arg(4)]);
                        font.pixelSize: pixelSize
                    }
                    GridItem {
                        //unit
                        width: columnWidthLast
                        height: rowHeight
                        text: ced_root.getIntrospection(index).Unit;
                        font.pixelSize: pixelSize
                    }
                }
            }
        }
    }
}
