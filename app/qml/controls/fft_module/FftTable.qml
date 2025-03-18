import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import SlowMachineSettingsHelper 1.0
import FontAwesomeQml 1.0
import ".."
import "../settings"

Rectangle {
    id: root

    readonly property QtObject thdnModule: VeinEntity.getEntity("THDNModule1")
    readonly property int channelCount: GC.showAuxPhases ? ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount : Math.min(ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount, 6)
    readonly property int fftOrder: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTOrder;
    readonly property int rowsDisplayedTotal: 14
    readonly property real rowHeight: height / rowsDisplayedTotal
    readonly property real columnWidth: width/7
    readonly property bool showAngles: GC.showFftTableAngles
    readonly property bool hasHorizScroll: showAngles ? channelCount > 3 : channelCount > 6

    readonly property bool relativeView: GC.showFftTableAsRelative > 0;
    color: Material.backgroundColor

    Keys.forwardTo: [fftFlickable]

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        width: (columnWidth * 0.5) - vBar.width
        height: rowHeight //+ 10 // Where do magic 10 come from?
        // hide item below
        z: 1
        color: Material.backgroundColor
        Button {
            id: settingsButton
            anchors.fill: parent
            anchors.topMargin: -4
            anchors.bottomMargin: -4
            text: FAQ.fa_cogs
            font.pointSize: root.rowHeight*0.45
            onClicked: settingsPopup.open()
        }
    }
    InViewSettingsPopup {
        id: settingsPopup
        rowHeight: root.rowHeight
        settingsRowCount: 2 + (hasAux ? 1 : 0)
        Column {
            anchors.topMargin: rowHeight/2
            anchors.fill: parent
            InViewSettingsCheckShowAux {
                width: settingsPopup.width
                enabledHeight: settingsPopup.inPopupRowHeight
            }
            ZCheckBox {
                text: "<b>" + Z.tr("Relative to fundamental") + "</b>"
                width: settingsPopup.width
                height: settingsPopup.inPopupRowHeight
                checked: GC.showFftTableAsRelative
                onCheckedChanged: SlwMachSettingsHelper.startShowFftTableAsRelativeChange(checked)
            }
            ZCheckBox {
                text: Z.tr("Show angles")
                width: settingsPopup.width
                height: settingsPopup.inPopupRowHeight
                checked: GC.showFftTableAngles
                onCheckedChanged: SlwMachSettingsHelper.startShowFftAnglesChange(checked)
            }
            /*ZCheckBox {
                text: Z.tr("Values as RMS")
                width: settingsPopup.width
                height: settingsPopup.inPopupRowHeight
            }*/
        }
    }

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
                color: GC.tableShadeColor
                x: fftFlickable.contentX //keep item visible on x axis moves
                z: 1
                width: root.columnWidth-vBar.width
                height: root.rowHeight
            }

            Repeater {
                model: root.channelCount
                delegate: GridItem {
                    width: root.columnWidth * (showAngles ? 2 : 1)
                    height: root.rowHeight
                    border.color: "#444" //disable border transparency
                    color: GC.tableShadeColor
                    text: Z.tr(ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+(index+1)].ChannelName)
                    textColor: FT.getColorByIndex(index+1)
                    font.bold: true
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
                    width: root.columnWidth * (showAngles ? 2 : 1)
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
                    width: root.columnWidth * (showAngles ? 2 : 1)
                    height: root.rowHeight
                    GridItem {
                        width: root.columnWidth
                        height: root.rowHeight
                        color: GC.tableShadeColor
                        border.color: "#444" //disable border transparency
                        text: (relativeView ? " [%]" : " ["+ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+parseInt(index+1)].Unit+"]");
                        textColor: FT.getColorByIndex(index+1)
                        font.pixelSize: rowHeight*0.5
                        font.bold: true
                    }
                    Loader {
                        active: showAngles
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
            width: root.columnWidth * (showAngles ? channelCount*2+1 : channelCount+1) - vBar.width
            height: root.rowHeight*(fftOrder+3)

            model: relativeView ? ZGL.FFTRelativeTableModel : ZGL.FFTTableModel
            boundsBehavior: Flickable.OvershootBounds
            cacheBuffer: root.fftOrder*root.rowHeight //prevents visual issue with index counter using "x: fftFlickable.contentX"

            clip: true

            delegate: Row {
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
                    active: showAngles
                    width: active ? root.columnWidth : 0
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
                    active: showAngles
                    width: active ? root.columnWidth : 0
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
                    active: showAngles
                    width: active ? root.columnWidth : 0
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
                    active: showAngles
                    width: active ? root.columnWidth : 0
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
                    active: showAngles
                    width: active ? root.columnWidth : 0
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
                    active: showAngles
                    width: active ? root.columnWidth : 0
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
                    width: active ? root.columnWidth : 0
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
                    active: root.channelCount>6 && showAngles
                    width: active ? root.columnWidth : 0
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
                    width: active ? root.columnWidth : 0
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
                    active: root.channelCount>7 && showAngles
                    width: active ? root.columnWidth : 0
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
