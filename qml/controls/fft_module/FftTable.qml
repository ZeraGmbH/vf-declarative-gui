import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import "qrc:/qml/controls" as CCMP

Item {
    id: root

    readonly property QtObject thdnModule: VeinEntity.getEntity("THDNModule1")
    readonly property int channelCount: GC.showAuxPhasesDecoupled ? ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount : Math.min(ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount, 6)
    readonly property int fftOrder: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTOrder;
    readonly property int rowsDisplayedTotal: 14
    readonly property int rowHeight: Math.floor(height/rowsDisplayedTotal)
    readonly property int columnWidth: width/7
    readonly property bool hasHorizScroll: GC.showFftTablePhase ? channelCount > 3 : channelCount > 6

    readonly property bool relativeView: GC.showFftTableAsRelative > 0;

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
                delegate: CCMP.GridRect {
                    width: root.columnWidth*(GC.showFftTablePhase ? 2 : 1)
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
                        color: GC.getColorByIndex(index+1)
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

            CCMP.GridItem {
                border.color: "#444" //disable border transparency
                x: fftFlickable.contentX //keep item visible on x axis moves
                z: 1
                width: root.columnWidth-vBar.width
                textAnchors.rightMargin: 2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: Z.tr("THDN:")
                textColor: Material.primaryTextColor
                font.bold: true
            }

            Repeater {
                model: root.channelCount
                CCMP.GridItem {
                    width: root.columnWidth* (GC.showFftTablePhase ? 2 : 1)
                    height: root.rowHeight
                    readonly property string componentName: String("ACT_THDN%1").arg(index+1);
                    readonly property string unit: ModuleIntrospection.thdnIntrospection.ComponentInfo[componentName].Unit
                    text: GC.formatNumber(thdnModule[componentName]) + unit
                    textColor: GC.getColorByIndex(index+1)
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

            CCMP.GridItem {
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
                    width: root.columnWidth*(GC.showFftTablePhase ? 2 : 1)
                    height: root.rowHeight
                    CCMP.GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: GC.tableShadeColor
                        border.color: "#444" //disable border transparency
                        text: Z.tr("Amp") + (relativeView ? " [%]" : " ["+ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+parseInt(index+1)].Unit+")");
                        textColor: GC.getColorByIndex(index+1)
                        font.pixelSize: rowHeight*0.5
                        font.bold: true
                    }
                    Loader {
                        active: GC.showFftTablePhase
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            color: GC.tableShadeColor
                            border.color: "#444" //disable border transparency
                            text: Z.tr("Phase") + " [°)"
                            textColor: GC.getColorByIndex(index+1)
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
            width: root.columnWidth*(GC.showFftTablePhase ? channelCount*2+1 : channelCount+1) - vBar.width
            height: root.rowHeight*(fftOrder+3)

            model: relativeView ? ZGL.FFTRelativeTableModel : ZGL.FFTTableModel
            boundsBehavior: Flickable.OvershootBounds
            cacheBuffer: root.fftOrder*root.rowHeight //prevents visual issue with index counter using "x: fftFlickable.contentX"

            clip: true

            delegate: Component {
                Row {
                    id: row
                    readonly property int rowVisibleOffset: 0 // 0: full visible / 1: all visible (partial) / >1: not visible above/below
                    readonly property int rowOffset: root.rowHeight * rowVisibleOffset
                    function isRowVisible() {
                        return row.y + row.rowOffset >= fftFlickable.contentY &&
                                fftFlickable.contentY + root.rowHeight*(rowsDisplayedTotal-4) + rowOffset >= row.y
                    }

                    property bool updateRowContents: isRowVisible()
                    readonly property bool movingVertically: vBar.active || fftFlickable.movingVertically
                    /* We switch between two modes to get low CPU load on user idle and fast flicking:
                       1. When user does not interact in FftTable we can reduce number of rows updated
                          to those visible only. This also improves situations when FftTable is loaded but
                          not visible.
                       2. Scrolling/flicking causes high CPU load at isRowVisible so get back
                          to update of all rows when user moves table vertically */
                    onMovingVerticallyChanged: {
                        if(movingVertically) {
                            // we intend to break property binding here
                            updateRowContents = true
                        }
                        else {
                            updateRowContents = Qt.binding(function() {
                                return isRowVisible()
                            });
                        }
                    }

                    height: root.rowHeight

                    CCMP.GridItem {
                        border.color: "#444" //disable border transparency
                        x: fftFlickable.contentX //keep item visible
                        z: 1
                        width: root.columnWidth-vBar.width
                        height: root.rowHeight
                        color: Qt.lighter(GC.tableShadeColor, 1.0+(index/150))
                        text: index
                        font.bold: true
                    }
                    CCMP.GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT1.Unit : ""
                        text: updateRowContents && AmplitudeL1 !== undefined ? GC.formatNumber(AmplitudeL1) + unit : text
                        textColor: GC.colorUL1
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTablePhase
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: updateRowContents && VectorL1 !== undefined ? GC.formatNumber(VectorL1) : text
                            textColor: GC.colorUL1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    CCMP.GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT2.Unit : ""
                        text: updateRowContents && AmplitudeL2 !== undefined ? GC.formatNumber(AmplitudeL2) + unit : text
                        textColor: GC.colorUL2
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTablePhase
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: updateRowContents && VectorL2 !== undefined ? GC.formatNumber(VectorL2) : text
                            textColor: GC.colorUL2
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    CCMP.GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT3.Unit : ""
                        text: updateRowContents && AmplitudeL3 !== undefined ? GC.formatNumber(AmplitudeL3) + unit : text
                        textColor: GC.colorUL3
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTablePhase
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: updateRowContents && VectorL3 !== undefined ? GC.formatNumber(VectorL3) : text
                            textColor: GC.colorUL3
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    CCMP.GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT4.Unit : ""
                        text: updateRowContents && AmplitudeL4 !== undefined ? GC.formatNumber(AmplitudeL4) + unit : text
                        textColor: GC.colorIL1
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTablePhase
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: updateRowContents && VectorL4 !== undefined ? GC.formatNumber(VectorL4) : text
                            textColor: GC.colorIL1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    CCMP.GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT5.Unit : ""
                        text: updateRowContents && AmplitudeL5 !== undefined ? GC.formatNumber(AmplitudeL5) + unit : text
                        textColor: GC.colorIL2
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTablePhase
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: updateRowContents && VectorL5 !== undefined ? GC.formatNumber(VectorL5) : text
                            textColor: GC.colorIL2
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    CCMP.GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT6.Unit : ""
                        text: updateRowContents && AmplitudeL6 !== undefined ? GC.formatNumber(AmplitudeL6) + unit : text
                        textColor: GC.colorIL3
                        font.pixelSize: rowHeight*0.5
                    }
                    Loader {
                        active: GC.showFftTablePhase
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: updateRowContents && VectorL6 !== undefined ? GC.formatNumber(VectorL6) : text
                            textColor: GC.colorIL3
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    Loader {
                        active: root.channelCount>6
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT7.Unit : ""
                            text: updateRowContents && AmplitudeL7 !== undefined ? GC.formatNumber(AmplitudeL7) + unit : text
                            textColor: GC.colorUAux1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    Loader {
                        active: root.channelCount>6 && GC.showFftTablePhase
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: updateRowContents && VectorL7 !== undefined ? GC.formatNumber(VectorL7) : text
                            textColor: GC.colorUAux1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    Loader {
                        active: root.channelCount>7
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            property string unit: index===1 && relativeView ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT8.Unit : ""
                            text: updateRowContents && AmplitudeL8 !== undefined ? GC.formatNumber(AmplitudeL8) + unit : text
                            textColor: GC.colorIAux1
                            font.pixelSize: rowHeight*0.5
                        }
                    }
                    Loader {
                        active: root.channelCount>7 && GC.showFftTablePhase
                        sourceComponent: CCMP.GridItem {
                            width: root.columnWidth
                            height: root.rowHeight
                            text: updateRowContents && VectorL8 !== undefined ? GC.formatNumber(VectorL8) : text
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
