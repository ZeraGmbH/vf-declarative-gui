import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtCharts 2.0
import GlobalConfig 1.0
import ColorSettings 1.0
import SessionState 1.0
import VfRecorderJsonHelper 1.0
import ZeraComponents 1.0
import ZeraTranslation  1.0
import AxisAutoScaler 1.0
import ZeraThemeConfig 1.0
import VeinEntity 1.0
import RecorderFetchAndCache 1.0
import LineSeriesFiller 1.0

Item {
    id: root
    property var graphHeight
    property var graphWidth
    property int parStartStop

    readonly property var recorderEntity: VeinEntity.getEntity("RecorderModule1")

    readonly property var voltageComponentsAC: ["ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3"]
    readonly property var currentComponentsAC: ["ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6"]
    readonly property var voltageComponentsDC: ["ACT_DC7"]
    readonly property var currentComponentsDC: ["ACT_DC8"]
    readonly property var powerComponentsACDC: ["ACT_PQS1", "ACT_PQS2", "ACT_PQS3", "ACT_PQS4"]
    property bool logging : SessionState.emobSession && (parStartStop === 1) ? true : false
    onLoggingChanged: {
        if(logging) {
            resetCharts()
            recorderEntity.PAR_StartStopRecording = true
        }
        else
            recorderEntity.PAR_StartStopRecording = false
    }

    property real timeDiffSecs : 0.0
    readonly property int xAxisTimeSpanSecs: 8
    property real contentWidth: 0.0
    property real chartWidth: root.graphWidth * 0.8356
    property int maxVisibleXPoints: (xAxisTimeSpanSecs * 2) //per second 2 points
    property real singlePointWidth: chartWidth/maxVisibleXPoints
    property int lastTimestamp

    Connections {
        target: RecorderFetchAndCache
        function onSigTimeLastValue(msSinceStart) {
            timeDiffSecs = msSinceStart / 1000
            calculateContentWidth()
        }
    }

    function resetCharts() {
        // clear all series
        for(var i= 0; i < chartViewUI.count; i++)
            chartViewUI.series(i).clear()
        for(var j= 0; j < chartViewPower.count; j++)
            chartViewPower.series(j).clear()
        // reset Y-axis min/max, X-axis is managed differently with property binding
        axisYPowerItem.reset()
        axisYLeftItem.reset()
        axisYRightItem.reset()
    }

    function calculateContentWidth() {
        let actualPoints = Math.round(timeDiffSecs* 2)+1
        if (actualPoints > maxVisibleXPoints)
            root.contentWidth = actualPoints * singlePointWidth
        else
            root.contentWidth = chartWidth
    }

    function scaleYAxis(axisY, axisYScalar, value) {
        if(root.timeDiffSecs === 0)
            axisYScalar.reset(value, 0.0)
        axisYScalar.scaleToNewActualValue(value)
        if(axisY !== axisYPowerItem.valueAxis)
            axisY.min = axisYScalar.getUIRoundedMinValueWithMargin();
        else {
            if(axisY.min === 0 || axisY.min > axisYScalar.getPowerRoundedMinValueWithMargin()) //0 is the default min value
                axisY.min = axisYScalar.getPowerRoundedMinValueWithMargin()
        }
        if(axisY.max < axisYScalar.getRoundedMaxValueWithMargin())
            axisY.max = axisYScalar.getRoundedMaxValueWithMargin()
    }

    VfRecorderJsonHelper {
        id: jsonHelper
    }
    AxisAutoScaler {
        id: axisYPowerScaler
    }
    AxisAutoScaler {
        id: axisYLeftScaler
    }
    AxisAutoScaler {
        id: axisYRightScaler
    }

    Loader {
        id: phasesLoader
        height: root.height * 0.13
        active: SessionState.emobSession && !SessionState.dcSession
        sourceComponent: RowLayout {
            id: phases
            visible: SessionState.emobSession && !SessionState.dcSession
            width: root.graphWidth
            height: parent.height

            Label {
                id: phaseLabel
                text: Z.tr("Select phase to display:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: GC.standardTextHorizMargin
                verticalAlignment: Label.AlignVCenter
            }
            ZCheckBox {
                text: "<font color='" + CS.colorUL1 + "'>" + Z.tr("L1") + "</font>"
                width: root.graphWidth
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                checked: GC.showCurvePhaseOne
                onCheckedChanged:
                    checkCombo = checked
                property var checkCombo: GC.showCurvePhaseOne
                onCheckComboChanged:
                    GC.setPhaseOne(checked)
            }
            ZCheckBox {
                text: "<font color='" + CS.colorUL2 + "'>" + Z.tr("L2") + "</font>"
                width: root.graphWidth
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                checked: GC.showCurvePhaseTwo
                onCheckStateChanged:
                    checkCombo = checked
                property var checkCombo: GC.showCurvePhaseTwo
                onCheckComboChanged:
                    GC.setPhaseTwo(checked)
            }
            ZCheckBox {
                text: "<font color='" + CS.colorUL3 + "'>" + Z.tr("L3") + "</font>"
                width: parent.width
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                checked: GC.showCurvePhaseThree
                onCheckStateChanged:
                    checkCombo = checked
                property var checkCombo: GC.showCurvePhaseThree
                onCheckComboChanged:
                    GC.setPhaseThree(checked)
            }
            ZCheckBox {
                text: "Σ"
                width: parent.width
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                checked: GC.showCurveSum
                onCheckStateChanged:
                    checkCombo = checked
                property var checkCombo: GC.showCurveSum
                onCheckComboChanged:
                    GC.setSum(checked)
            }
        }
    }

    Flickable {
        id: verticalFlickable
        anchors.top: phasesLoader.active ? phasesLoader.bottom : root.top
        boundsBehavior: Flickable.StopAtBounds
        contentHeight: chartViewUI.height + chartViewPower.height
        width: root.width
        height: phasesLoader.active ? root.height - phasesLoader.height : root.height
        property int chartsHeight: phasesLoader.active ? root.graphHeight /2 - phasesLoader.height : root.graphHeight /2
        flickableDirection: Flickable.VerticalFlick
        clip: true
        onMovementEnded: {
            let pageHeight = chartViewUI.height
            let currentPage = Math.round(contentY / pageHeight);
            contentY = currentPage * pageHeight
        }

        ScrollBar.vertical: ScrollBar {
            id: verticalScroll
            width: verticalFlickable.width * 0.013
            anchors.right: parent.right
            policy : verticalFlickable.height >= chartViewUI.height + chartViewPower.height ?  ScrollBar.AlwaysOff : ScrollBar.AlwaysOn
            snapMode: ScrollBar.SnapOnRelease
            stepSize: 1
        }

        PinchArea {
            id: pinchArea
            MouseArea {
                anchors.fill: parent
            }
            anchors.fill: parent
            pinch.dragAxis: Pinch.YAxis
            onPinchUpdated: (pinch) => {
                let pinchScale = pinch.scale * pinch.previousScale
                if (pinchScale > 1.0) {
                    chartViewUI.height = verticalFlickable.chartsHeight
                    chartViewPower.height = verticalFlickable.chartsHeight
                }
                else if (pinchScale < 1.0) {
                    chartViewUI.height = verticalFlickable.chartsHeight/2
                    chartViewPower.height = verticalFlickable.chartsHeight/2
                }
            }
        }

        ChartView {
            id: chartViewPower
            height: verticalFlickable.chartsHeight
            width: root.graphWidth
            antialiasing: true
            theme: ZTC.isDarkTheme ? ChartView.ChartThemeDark : ChartView.ChartThemeLight
            legend.visible: false
            margins {right: root.graphWidth * 0.067; left: root.graphWidth * 0.004; top: 0; bottom: 0}
            property bool loggingActive: logging
            property int pinchedXMin: 0
            property int pinchedXMax: xAxisTimeSpanSecs
            onLoggingActiveChanged: {
                if(!logging) {
                    pinchedXMin = 0
                    pinchedXMax = root.timeDiffSecs
                }
            }
            property bool ready: false
            Component.onCompleted: {
                ready = true
            }
            EnergyGraphsYAxis {
                id: axisYPowerItem
                graphWidth: root.graphWidth
                chartView: chartViewPower
                title: "P"
                unitBase: "W"
            }
            ValueAxis {
                id: axisXPower
                titleText: "T[s]"
                titleFont.pointSize: chartViewPower.height * 0.04
                labelsFont.pixelSize: chartViewPower.height * 0.04
                labelFormat: "%d"
                property int currentMax: max
                min: {
                    if(chartViewPower.loggingActive)
                        return 0;
                    else
                        return Math.max(chartViewPower.pinchedXMin, 0)
                }
                max: {
                    if (chartViewPower.loggingActive)
                        return ((Math.floor(timeDiffSecs/xAxisTimeSpanSecs)) + 1) * xAxisTimeSpanSecs
                    else
                        return chartViewPower.pinchedXMax
                }
            }

            Flickable {
                id : chartViewPowerFlickable
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                width: root.width
                height: root.height
                flickableDirection: Flickable.HorizontalFlick
                clip: true
                contentWidth: root.contentWidth
                interactive: !logging
                onInteractiveChanged: {
                    if(!interactive)
                        contentWidth = root.chartWidth
                }
                ScrollBar.horizontal: ScrollBar {
                    id: powerScrollBar
                    height: root.height * 0.025
                    policy: ScrollBar.AlwaysOn
                    anchors.bottom: parent.bottom
                    interactive: !logging
                    position: 1.0 - size
                    onPositionChanged: {
                        chartViewPower.pinchedXMin = Math.ceil(root.timeDiffSecs * position)
                        chartViewPower.pinchedXMax = chartViewPower.pinchedXMin + xAxisTimeSpanSecs
                    }
                }
                PinchArea {
                    id: chartViewPowerPinchArea
                    anchors.fill: parent
                    pinch.dragAxis: Pinch.XAxis
                    enabled: !logging
                    onPinchUpdated: (pinch) => {
                        if(pinch.scale > 1)
                            chartViewPowerFlickable.contentWidth = root.contentWidth
                        else {
                            chartViewPowerFlickable.contentWidth = root.chartWidth
                            chartViewPower.pinchedXMax = root.timeDiffSecs
                        }
                    }
                }
            }
            LineSeries {
                id: powerLineSeriesL1
                name: powerComponentsACDC[0]
                axisX: axisXPower
                axisY: axisYPowerItem.valueAxis
                color: SessionState.dcSession ? CS.colorUAux1 : CS.colorUL1
                visible: GC.showCurvePhaseOne || SessionState.dcSession
                LineSeriesFiller {
                    lineSeries: powerLineSeriesL1
                    entityId: 1070
                    componentName: powerComponentsACDC[0]
                }
                onPointAdded: (index) => scaleYAxis(axisYPowerItem.valueAxis, axisYPowerScaler, at(index).y)
            }
            LineSeries {
                id: powerLineSeriesL2
                name: powerComponentsACDC[1]
                axisX: axisXPower
                axisY: axisYPowerItem.valueAxis
                color: CS.colorUL2
                visible: GC.showCurvePhaseTwo && !SessionState.dcSession
                LineSeriesFiller {
                    lineSeries: powerLineSeriesL2
                    entityId: 1070
                    componentName: powerComponentsACDC[1]
                }
                onPointAdded: (index) => scaleYAxis(axisYPowerItem.valueAxis, axisYPowerScaler, at(index).y)
            }
            LineSeries {
                id: powerLineSeriesL3
                name: powerComponentsACDC[2]
                axisX: axisXPower
                axisY: axisYPowerItem.valueAxis
                color: CS.colorUL3
                visible: GC.showCurvePhaseThree && !SessionState.dcSession
                LineSeriesFiller {
                    lineSeries: powerLineSeriesL3
                    entityId: 1070
                    componentName: powerComponentsACDC[2]
                }
                onPointAdded: (index) => scaleYAxis(axisYPowerItem.valueAxis, axisYPowerScaler, at(index).y)
            }
            LineSeries {
                id: powerLineSeriesSum
                name: powerComponentsACDC[3]
                axisX: axisXPower
                axisY: axisYPowerItem.valueAxis
                color: ZTC.primaryTextColor
                visible: GC.showCurveSum && !SessionState.dcSession
                LineSeriesFiller {
                    lineSeries: powerLineSeriesSum
                    entityId: 1070
                    componentName: powerComponentsACDC[3]
                }
                onPointAdded: (index) => scaleYAxis(axisYPowerItem.valueAxis, axisYPowerScaler, at(index).y)
            }
        }
        ChartView {
            id: chartViewUI
            height: phasesLoader.active ? root.graphHeight / 2 - phasesLoader.height : root.graphHeight / 2
            width: root.graphWidth
            anchors.top: chartViewPower.bottom
            antialiasing: true
            theme: ZTC.isDarkTheme ? ChartView.ChartThemeDark : ChartView.ChartThemeLight
            legend.visible: false
            margins {right: 0; left: 0; top: 0; bottom: 0}
            property bool loggingActive: logging
            property int pinchedXMin: 0
            property int pinchedXMax: xAxisTimeSpanSecs
            onLoggingActiveChanged: {
                if(!logging) {
                    pinchedXMin = 0
                    pinchedXMax = root.timeDiffSecs
                }
            }
            property bool ready: false
            Component.onCompleted: {
                ready = true
            }

            EnergyGraphsYAxis {
                id: axisYLeftItem
                graphWidth: root.graphWidth
                chartView: chartViewUI
                title: "U"
                unitBase: "V"
            }

            ValueAxis {
                id: axisX
                titleText: "T[s]"
                titleFont.pointSize: chartViewUI.height * 0.04
                labelsFont.pixelSize: chartViewUI.height * 0.04
                labelFormat: "%d"
                min: {
                    if(chartViewUI.loggingActive)
                        return 0
                    else
                        return Math.max(chartViewUI.pinchedXMin, 0)
                }

                max : {
                    if (chartViewUI.loggingActive)
                        return ((Math.floor(timeDiffSecs/xAxisTimeSpanSecs)) + 1) * xAxisTimeSpanSecs;
                    else
                        return chartViewUI.pinchedXMax;
                }
            }

            EnergyGraphsYAxis {
                id: axisYRightItem
                graphWidth: root.graphWidth
                onTheRight: true
                chartView: chartViewUI
                title: "I"
                unitBase: "A"
            }

            Flickable {
                id: chartViewFlickable
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                width: root.width
                height: root.height
                flickableDirection: Flickable.HorizontalFlick
                clip: true
                contentWidth: root.contentWidth
                interactive: !logging
                onInteractiveChanged: {
                    if(!interactive)
                        contentWidth = root.chartWidth
                }
                ScrollBar.horizontal: ScrollBar {
                    id: uIScrollBar
                    height: root.height * 0.025
                    policy: ScrollBar.AlwaysOn
                    anchors.bottom: parent.bottom
                    interactive: !logging
                    position: 1.0 - size
                    onPositionChanged: {
                        chartViewUI.pinchedXMin = Math.ceil(root.timeDiffSecs * position)
                        chartViewUI.pinchedXMax = chartViewUI.pinchedXMin + xAxisTimeSpanSecs
                    }
                }
                PinchArea {
                    id: chartViewPinchArea
                    anchors.fill: parent
                    pinch.dragAxis: Pinch.XAxis
                    enabled: !logging
                    onPinchUpdated: (pinch) => {
                        if(pinch.scale > 1)
                            chartViewFlickable.contentWidth = root.contentWidth
                        else {
                            chartViewFlickable.contentWidth = root.chartWidth
                            chartViewUI.pinchedXMax = root.timeDiffSecs
                        }
                    }
                }
            }

            LineSeries {
                id: lineSeriesUL1
                name: voltageComponentsAC[0]
                axisX: axisX
                axisY: axisYLeftItem.valueAxis
                color: CS.colorUL1
                visible: GC.showCurvePhaseOne && !SessionState.dcSession
                LineSeriesFiller {
                    lineSeries: lineSeriesUL1
                    entityId: 1040
                    componentName: voltageComponentsAC[0]
                }
                onPointAdded: (index) => scaleYAxis(axisYLeftItem.valueAxis, axisYLeftScaler, at(index).y)
            }
            LineSeries {
                id: lineSeriesUL2
                name: voltageComponentsAC[1]
                axisX: axisX
                axisY: axisYLeftItem.valueAxis
                color: CS.colorUL2
                visible: GC.showCurvePhaseTwo && !SessionState.dcSession
                LineSeriesFiller {
                    lineSeries: lineSeriesUL2
                    entityId: 1040
                    componentName: voltageComponentsAC[1]
                }
                onPointAdded: (index) => scaleYAxis(axisYLeftItem.valueAxis, axisYLeftScaler, at(index).y)
            }
            LineSeries {
                id: lineSeriesUL3
                name: voltageComponentsAC[2]
                axisX: axisX
                axisY: axisYLeftItem.valueAxis
                color: CS.colorUL3
                visible: GC.showCurvePhaseThree && !SessionState.dcSession
                LineSeriesFiller {
                    lineSeries: lineSeriesUL3
                    entityId: 1040
                    componentName: voltageComponentsAC[2]
                }
                onPointAdded: (index) => scaleYAxis(axisYLeftItem.valueAxis, axisYLeftScaler, at(index).y)
            }
            LineSeries {
                id: lineSeriesIL1
                name: currentComponentsAC[0]
                axisX: axisX
                axisYRight: axisYRightItem.valueAxis
                color: CS.colorIL1
                LineSeriesFiller {
                    lineSeries: lineSeriesIL1
                    entityId: 1040
                    componentName: currentComponentsAC[0]
                }
                visible: GC.showCurvePhaseOne && !SessionState.dcSession
                onPointAdded: (index) => scaleYAxis(axisYRightItem.valueAxis, axisYRightScaler, at(index).y)
            }
            LineSeries {
                id: lineSeriesIL2
                name: currentComponentsAC[1]
                axisX: axisX
                axisYRight: axisYRightItem.valueAxis
                color: CS.colorIL2
                LineSeriesFiller {
                    lineSeries: lineSeriesIL2
                    entityId: 1040
                    componentName: currentComponentsAC[1]
                }
                visible: GC.showCurvePhaseTwo && !SessionState.dcSession
                onPointAdded: (index) => scaleYAxis(axisYRightItem.valueAxis, axisYRightScaler, at(index).y)
            }
            LineSeries {
                id: lineSeriesIL3
                name: currentComponentsAC[2]
                axisX: axisX
                axisYRight: axisYRightItem.valueAxis
                color: CS.colorIL3
                LineSeriesFiller {
                    lineSeries: lineSeriesIL3
                    entityId: 1040
                    componentName: currentComponentsAC[2]
                }
                visible: GC.showCurvePhaseThree && !SessionState.dcSession
                onPointAdded: (index) => scaleYAxis(axisYRightItem.valueAxis, axisYRightScaler, at(index).y)
            }
            LineSeries {
                name: voltageComponentsDC[0]
                axisX: axisX
                axisY: axisYLeftItem.valueAxis
                color: CS.colorUAux1
                visible: SessionState.dcSession
                onPointAdded: (index) => scaleYAxis(axisYLeftItem.valueAxis, axisYLeftScaler, at(index).y)
            }
            LineSeries {
                name: currentComponentsDC[0]
                axisX: axisX
                axisYRight: axisYRightItem.valueAxis
                color: CS.colorIAux1
                visible: SessionState.dcSession
                onPointAdded: (index) => scaleYAxis(axisYRightItem.valueAxis, axisYRightScaler, at(index).y)
            }
        }
    }
}
