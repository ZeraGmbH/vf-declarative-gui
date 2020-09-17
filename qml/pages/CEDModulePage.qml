import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import "qrc:/qml/controls" as CCMP

CCMP.ModulePage {
    id: ced_root

    readonly property int row1stHeight: Math.floor(height/8)
    readonly property int rowHeight: Math.floor((height-row1stHeight)/3)
    readonly property int pixelSize: rowHeight*0.3
    readonly property int columnWidth1st: pixelSize * 1.5
    readonly property int columnWidthLast: pixelSize * 1.3
    readonly property int columnWidth: (width-(columnWidth1st+columnWidthLast))/4 // 3phases + sum

    readonly property QtObject power2Module1: VeinEntity.getEntity("POWER2Module1")

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
            CCMP.GridRect {
                width: columnWidth1st
                height: row1stHeight
                color: GC.tableShadeColor
                //spacer
            }
            CCMP.GridItem {
                width: columnWidth
                height: row1stHeight
                color: GC.tableShadeColor
                text: Z.tr("L1")
                textColor: GC.colorUL1
                font.pixelSize: pixelSize
            }
            CCMP.GridItem {
                width: columnWidth
                height: row1stHeight
                color: GC.tableShadeColor
                text: Z.tr("L2")
                textColor: GC.colorUL2
                font.pixelSize: pixelSize
            }
            CCMP.GridItem {
                width: columnWidth
                height: row1stHeight
                color: GC.tableShadeColor
                text: Z.tr("L3")
                textColor: GC.colorUL3
                font.pixelSize: pixelSize
            }
            CCMP.GridItem {
                width: columnWidth
                height: row1stHeight
                color: GC.tableShadeColor
                text: "Σ"
                textColor: GC.colorUL3
                font.pixelSize: pixelSize
            }
            CCMP.GridItem {
                width: columnWidthLast
                height: row1stHeight
                color: GC.tableShadeColor
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
                    CCMP.GridItem {
                        //title
                        width: columnWidth1st
                        height: rowHeight
                        color: GC.tableShadeColor
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
                    CCMP.GridItem {
                        //l1
                        width: columnWidth
                        height: rowHeight
                        textColor: GC.colorUL1
                        text: GC.formatNumber(power2Module1[String(ced_root.getProperty(index)).arg(1)]);
                        font.pixelSize: pixelSize
                    }
                    CCMP.GridItem {
                        //l2
                        width: columnWidth
                        height: rowHeight
                        textColor: GC.colorUL2
                        text: GC.formatNumber(power2Module1[String(ced_root.getProperty(index)).arg(2)]);
                        font.pixelSize: pixelSize
                    }
                    CCMP.GridItem {
                        //l3
                        width: columnWidth
                        height: rowHeight
                        textColor: GC.colorUL3
                        text: GC.formatNumber(power2Module1[String(ced_root.getProperty(index)).arg(3)]);
                        font.pixelSize: pixelSize
                    }
                    CCMP.GridItem {
                        //pSum
                        width: columnWidth
                        height: rowHeight
                        text: GC.formatNumber(power2Module1[String(ced_root.getProperty(index)).arg(4)]);
                        font.pixelSize: pixelSize
                    }
                    CCMP.GridItem {
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
