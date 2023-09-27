import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import ".."

Item {
    id: root

    readonly property QtObject glueLogic: ZGL;
    readonly property int channelCount: ModuleIntrospection.p3m1Introspection.ModuleInfo.HPWCount;
    readonly property int hpwOrder: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTOrder; //the power3module harmonic order depends on the fftmodule
    property int rowHeight: Math.floor(height/12)
    property int columnWidth: (width - vBar.width - width/20)/9

    readonly property bool relativeView: GC.showFftTableAsRelative > 0;
    readonly property string relativeUnit: relativeView ? " %" : "";
    property real topMarginPage

    Keys.forwardTo: [fftFlickable]
    ScrollBar {
        z: 1
        id: vBar
        anchors.right: parent.right
        anchors.top: fftFlickable.top
        anchors.topMargin: harmonicHeaders.height
        anchors.bottom: fftFlickable.bottom
        orientation: Qt.Vertical
        policy: ScrollBar.AlwaysOn
        width: 8
    }

    Flickable {
        id: fftFlickable
        anchors.topMargin: topMarginPage
        anchors.fill: parent
        anchors.bottomMargin: parent.height%root.rowHeight
        anchors.rightMargin: vBar.width
        contentWidth: root.columnWidth*(1+root.channelCount*2)
        contentHeight: root.rowHeight*(hpwOrder+1)
        clip: true
        interactive: true
        boundsBehavior: Flickable.OvershootBounds
        flickableDirection: Flickable.VerticalFlick

        Keys.onUpPressed:  {
            if(!atYBeginning) {
                flick(0, Math.sqrt(rowHeight)*173.2)
            }
        }
        Keys.onDownPressed: {
            if(!atYEnd) {
                flick(0, -Math.sqrt(rowHeight)*173.2)
            }
        }
        ScrollBar.vertical: vBar

        Row {
            id: harmonicHeaders
            anchors.left: parent.left
            anchors.right: parent.right
            y: fftFlickable.contentY
            z: 1
            height: root.rowHeight

            GridItem {
                border.color: "#444" //disable border transparency
                x: fftFlickable.contentX //keep item visible
                z: 1
                width: root.width/20
                height: root.rowHeight
                color: GC.tableShadeColor
                text: "n"
                textColor: Material.primaryTextColor
                font.bold: true
            }

            Repeater {
                model: root.channelCount
                delegate: Row {
                    width: root.columnWidth*3
                    height: root.rowHeight
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: GC.tableShadeColor
                        border.color: "#444" //disable border transparency
                        text: Z.tr(ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPP%1").arg(index+1)].ChannelName) + relativeUnit //P
                        textColor: FT.getColorByIndex(index+1)
                        font.bold: true
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: GC.tableShadeColor
                        border.color: "#444" //disable border transparency
                        text: Z.tr(ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPQ%1").arg(index+1)].ChannelName) + relativeUnit //Q
                        textColor: FT.getColorByIndex(index+1)
                        font.bold: true
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: GC.tableShadeColor
                        border.color: "#444" //disable border transparency
                        text: Z.tr(ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPS%1").arg(index+1)].ChannelName) + relativeUnit //S
                        textColor: FT.getColorByIndex(index+1)
                        font.bold: true
                    }
                }
            }
        }

        ListView {
            id: lvHarmonics
            z: -1
            y: harmonicHeaders.height
            width: root.columnWidth*17
            height: root.rowHeight*(hpwOrder+1)

            model: relativeView ? glueLogic.HPWRelativeTableModel : glueLogic.HPWTableModel
            boundsBehavior: Flickable.OvershootBounds
            cacheBuffer: root.hpwOrder*root.rowHeight //prevents visual issue with index counter using "x: fftFlickable.contentX"
            clip: true

            delegate: Component {
                Row {
                    height: root.rowHeight

                    GridItem {
                        border.color: "#444" //disable border transparency
                        x: fftFlickable.contentX //keep item visible
                        z: 1
                        width: root.width/20
                        height: root.rowHeight
                        color: Qt.lighter(GC.tableShadeColor, 1.0+(index/150))
                        text: index
                        font.bold: true
                    }
                    //S1
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        text: FT.formatNumber(PowerS1P) + (relativeView && index===1 ? ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPP1.Unit : "")
                        textColor: GC.colorUL1
                        font.pixelSize: rowHeight*0.5
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        text: FT.formatNumber(PowerS1Q) + (relativeView && index===1 ? ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPQ1.Unit : "")
                        textColor: GC.colorUL1
                        font.pixelSize: rowHeight*0.5
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        text: FT.formatNumber(PowerS1S) + (relativeView && index===1 ? ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPS1.Unit : "")
                        textColor: GC.colorUL1
                        font.pixelSize: rowHeight*0.5
                    }
                    //S2
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        text: FT.formatNumber(PowerS2P) + (relativeView && index===1 ? ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPP2.Unit : "")
                        textColor: GC.colorUL2
                        font.pixelSize: rowHeight*0.5
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        text: FT.formatNumber(PowerS2Q) + (relativeView && index===1 ? ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPQ2.Unit : "")
                        textColor: GC.colorUL2
                        font.pixelSize: rowHeight*0.5
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        text: FT.formatNumber(PowerS2S) + (relativeView && index===1 ? ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPS2.Unit : "")
                        textColor: GC.colorUL2
                        font.pixelSize: rowHeight*0.5
                    }
                    //S3
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        text: FT.formatNumber(PowerS3P) + (relativeView && index===1 ? ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPP3.Unit : "")
                        textColor: GC.colorUL3
                        font.pixelSize: rowHeight*0.5
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        text: FT.formatNumber(PowerS3Q) + (relativeView && index===1 ? ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPQ3.Unit : "")
                        textColor: GC.colorUL3
                        font.pixelSize: rowHeight*0.5
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        text: FT.formatNumber(PowerS3S) + (relativeView && index===1 ? ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPS3.Unit : "")
                        textColor: GC.colorUL3
                        font.pixelSize: rowHeight*0.5
                    }
                }
            }
        }
    }
}
