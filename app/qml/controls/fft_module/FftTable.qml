import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import ".."

Rectangle {
    id: root

    readonly property QtObject thdnModule: VeinEntity.getEntity("THDNModule1")
    readonly property int channelCount: GC.showAuxPhases ? ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount : Math.min(ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount, 6)
    readonly property int fftOrder: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTOrder;
    readonly property int rowsDisplayedTotal: 14
    readonly property int rowHeight: Math.floor(height/rowsDisplayedTotal)
    readonly property int columnWidth: width/7
    readonly property bool hasHorizScroll: GC.showFftTableAngle ? channelCount > 3 : channelCount > 6

    readonly property bool relativeView: GC.showFftTableAsRelative > 0;
    color: Material.backgroundColor

    Keys.forwardTo: [fftFlickable]

    ScrollBar {
        z: 1
        id: vBar
        anchors.right: parent.right
        anchors.top: fftFlickable.top
        anchors.topMargin: root.rowHeight*3
        anchors.bottom: fftFlickable.bottom
        orientation: Qt.Vertical
        policy: ScrollBar.AlwaysOn
        width: 8
    }
    ScrollBar {
        id: hBar
        anchors.top: fftFlickable.bottom
        anchors.left: fftFlickable.left
        anchors.right: fftFlickable.right
        orientation: Qt.Horizontal
        height: 8
        policy: hasHorizScroll ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }

    Flickable {
        id: fftFlickable
        anchors.fill: parent
        anchors.bottomMargin: parent.height%root.rowHeight
        anchors.rightMargin: vBar.width
        contentWidth: lvHarmonics.width
        contentHeight: root.rowHeight*(fftOrder+3)
        clip: true
        interactive: true
        boundsBehavior: Flickable.OvershootBounds
        flickableDirection: hasHorizScroll ? Flickable.HorizontalAndVerticalFlick : Flickable.VerticalFlick

        ScrollBar.horizontal: hBar
        ScrollBar.vertical: vBar
        // The following dance is necessary to improve swiping into next tab.
        onAtXBeginningChanged: {
            helperMouseArea.enabled = hasHorizScroll && atXBeginning
        }
        onAtXEndChanged: {
            helperMouseArea.enabled = hasHorizScroll && atXEnd
        }

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
        Keys.onLeftPressed: {
            if(atXBeginning) {
                event.accepted = false;
            }
            else {
                flick(Math.sqrt(width)*30, 0)
            }
        }
        Keys.onRightPressed: {
            if(atXEnd) {
                event.accepted = false
            }
            else {
                flick(-Math.sqrt(width)*30, 0)
            }
        }

        Row {
            id: titleRow
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.rowHeight
            y: fftFlickable.contentY //keep item visible on y axis moves
            z: 1

            Rectangle {
                color: Material.backgroundColor //hide item below
                x: fftFlickable.contentX //keep item visible on x axis moves
                z: 1
                width: root.columnWidth-vBar.width
                height: root.rowHeight
            }

            Repeater {
                model: root.channelCount
                delegate: GridRect {
                    width: root.columnWidth*(GC.showFftTableAngle ? 2 : 1)
                    height: root.rowHeight
                    color: GC.tableShadeColor
                    border.color: "#444" //disable border transparency
                    Text {
                        text: Z.tr(ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+(index+1)].ChannelName)
                        anchors.centerIn: parent
                        anchors.rightMargin: 8
                        font.pixelSize: rowHeight*0.5
                        font.family: "Droid Sans Mono"
                        font.bold: true
                        color: FT.getColorByIndex(index+1)
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        textFormat: Text.PlainText
                    }
                }
            }
        }

        Row {
            id: thdnHeaders
            anchors.top: titleRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.rowHeight

            GridItem {
                border.color: "#444" //disable border transparency
                x: fftFlickable.contentX //keep item visible on x axis moves
                z: 1
                width: root.columnWidth-vBar.width
                height: root.rowHeight
                color: GC.tableShadeColor
                text: Z.tr("THDN:")
                textColor: Material.primaryTextColor
                font.bold: true
            }

            Repeater {
                model: root.channelCount
                GridItem {
                    width: root.columnWidth* (GC.showFftTableAngle ? 2 : 1)
                    height: root.rowHeight
                    readonly property string componentName: String("ACT_THDN%1").arg(index+1);
                    readonly property string unit: ModuleIntrospection.thdnIntrospection.ComponentInfo[componentName].Unit
                    text: FT.formatNumber(thdnModule[componentName]) + unit
                    textColor: FT.getColorByIndex(index+1)
                    font.pixelSize: rowHeight*0.5
                    border.color: "#444" //disable border transparency
                }
            }
        }

        Row {
            id: harmonicHeaders
            anchors.top: thdnHeaders.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.rowHeight

            GridItem {
                border.color: "#444" //disable border transparency
                x: fftFlickable.contentX //keep item visible
                z: 1
                width: root.columnWidth-vBar.width
                height: root.rowHeight
                color: GC.tableShadeColor
                text: "n"
                textColor: Material.primaryTextColor
                font.bold: true
            }

            Repeater {
                model: root.channelCount
                delegate: Row {
                    width: root.columnWidth*(GC.showFftTableAngle ? 2 : 1)
                    height: root.rowHeight
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: GC.tableShadeColor
                        border.color: "#444" //disable border transparency
                        text: (relativeView ? " [%]" : " ["+ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+parseInt(index+1)].Unit+"]");
                        textHorizontalAlignment: Label.AlignHCenter
                        textColor: FT.getColorByIndex(index+1)
                        font.pixelSize: rowHeight*0.5
                        font.bold: true
                    }
                    Loader {
                        active: GC.showFftTableAngle
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            color: GC.tableShadeColor
                            border.color: "#444" //disable border transparency
                            text: Z.tr("Phase") + " [°]"
                            textColor: FT.getColorByIndex(index+1)
                            font.pixelSize: rowHeight*0.5
                            font.bold: true
                        }
                    }
                }
            }
        }

        ListView {
            id: lvHarmonics
            z: -1
            y: root.rowHeight*3
            width: root.columnWidth*(GC.showFftTableAngle ? channelCount*2+1 : channelCount+1) - vBar.width
            height: root.rowHeight*(fftOrder+3)

            model: relativeView ? ZGL.FFTRelativeTableModel : ZGL.FFTTableModel
            boundsBehavior: Flickable.OvershootBounds
            cacheBuffer: root.fftOrder*root.rowHeight //prevents visual issue with index counter using "x: fftFlickable.contentX"

            clip: true

            delegate: Component {
                Row {
                    id: row
                    height: root.rowHeight

                    GridItem {
                        border.color: "#444" //disable border transparency
                        x: fftFlickable.contentX //keep item visible
                        z: 1
                        width: root.columnWidth-vBar.width
                        height: root.rowHeight
                        color: Qt.lighter(GC.tableShadeColor, 1.0+(index/150))
                        text: index
                        font.bold: true
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT1.Unit : ""
                        text: FT.formatNumber(AmplitudeL1) + unit
                        textColor: GC.colorUL1
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTableAngle
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: FT.formatNumber(AngleL1)
                            textColor: GC.colorUL1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT2.Unit : ""
                        text: FT.formatNumber(AmplitudeL2) + unit
                        textColor: GC.colorUL2
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTableAngle
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: FT.formatNumber(AngleL2)
                            textColor: GC.colorUL2
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT3.Unit : ""
                        text: FT.formatNumber(AmplitudeL3) + unit
                        textColor: GC.colorUL3
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTableAngle
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: FT.formatNumber(AngleL3)
                            textColor: GC.colorUL3
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT4.Unit : ""
                        text: FT.formatNumber(AmplitudeL4) + unit
                        textColor: GC.colorIL1
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTableAngle
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: FT.formatNumber(AngleL4)
                            textColor: GC.colorIL1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT5.Unit : ""
                        text: FT.formatNumber(AmplitudeL5) + unit
                        textColor: GC.colorIL2
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTableAngle
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: FT.formatNumber(AngleL5)
                            textColor: GC.colorIL2
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT6.Unit : ""
                        text: FT.formatNumber(AmplitudeL6) + unit
                        textColor: GC.colorIL3
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTableAngle
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: FT.formatNumber(AngleL6)
                            textColor: GC.colorIL3
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    Loader {
                        active: root.channelCount>6
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT7.Unit : ""
                            text: FT.formatNumber(AmplitudeL7) + unit
                            textColor: GC.colorUAux1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    Loader {
                        active: root.channelCount>6 && GC.showFftTableAngle
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: FT.formatNumber(AngleL7)
                            textColor: GC.colorUAux1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    Loader {
                        active: root.channelCount>7
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT8.Unit : ""
                            text: FT.formatNumber(AmplitudeL8) + unit
                            textColor: GC.colorIAux1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    Loader {
                        active: root.channelCount>7 && GC.showFftTableAngle
                        sourceComponent: GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: FT.formatNumber(AngleL8)
                            textColor: GC.colorIAux1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                }
            }
        }
    }
    MouseArea {
        id: helperMouseArea
        anchors.fill: parent
        anchors.rightMargin: vBar.width
        anchors.bottomMargin: hBar.height
        enabled: false
        drag.axis: Drag.XAxis
        property real oldXPos: 0
        onPositionChanged: {
            // can we swipe contents left?
            if(mouse.x > oldXPos && fftFlickable.atXEnd)
                enabled = false
            // can we swipe contents right?
            if(mouse.x < oldXPos && fftFlickable.atXBeginning)
                enabled = false
            oldXPos = mouse.x
        }
    }
}
