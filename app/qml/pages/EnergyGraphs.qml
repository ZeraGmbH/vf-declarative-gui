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
import Vf_Recorder 1.0
import AxisAutoScaler 1.0
import SingleValueScaler 1.0

Item {
    id: root
    property var graphHeight
    property var graphWidth
    property int parStartStop

    readonly property int storageNumber: 0
    readonly property var voltageComponentsAC: ["ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3"]
    readonly property var currentComponentsAC: ["ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6"]
    readonly property var voltageComponentsDC: ["ACT_DC7"]
    readonly property var currentComponentsDC: ["ACT_DC8"]
    readonly property var powerComponentsACDC: ["ACT_PQS1", "ACT_PQS2", "ACT_PQS3", "ACT_PQS4"]

    readonly property bool dcSession: SessionState.emobSession && SessionState.dcSession

    readonly property var jsonEnergyDC: {"foo":[{"EntityId":1060, "Component":voltageComponentsDC.concat(currentComponentsDC)},
                                                {"EntityId":1073, "Component":powerComponentsACDC[0]}]}
    readonly property var jsonEnergyAC: {"foo":[{"EntityId":1040, "Component":voltageComponentsAC.concat(currentComponentsAC)},
                                                {"EntityId":1070, "Component":powerComponentsACDC}]}
    readonly property var vfRecorderInputJson: dcSession ? jsonEnergyDC : jsonEnergyAC

    property bool logging : SessionState.emobSession && (parStartStop === 1) ? true : false
    onLoggingChanged: {
        if(logging) {
            resetCharts()
            Vf_Recorder.startLogging(storageNumber, vfRecorderInputJson)
        }
        else
            Vf_Recorder.stopLogging(storageNumber)
    }
    readonly property string currentSession: SessionState.currentSession
    onCurrentSessionChanged: {
        if(logging)
            Vf_Recorder.stopLogging(storageNumber)
    }

    property real timeDiffSecs : 0.0
    readonly property int xAxisTimeSpanSecs: 8
    property real contentWidth: 0.0
    property real chartWidth: root.graphWidth * 0.8356
    property int maxVisibleXPoints: (xAxisTimeSpanSecs * 2) //per second 2 points
    property real singlePointWidth: chartWidth/maxVisibleXPoints

    property var jsonData : Vf_Recorder.latestStoredValues0
    onJsonDataChanged: {
        var timestamp = Object.keys(jsonData)[0]
        var timeMs = jsonHelper.convertTimestampToMs(timestamp)
        timeDiffSecs = (timeMs - Vf_Recorder.firstTimestamp0)/1000
        var components = jsonHelper.getComponents(jsonData[timestamp])

        for(var v = 0 ; v <components.length; v++) {
            let serie = chartViewPower.series(components[v])
            if(serie !== null) {
                serie.append(timeDiffSecs, jsonHelper.getValue(jsonData[timestamp], components[v]))
                if(loggingTimer.hasTriggered)
                    removePoint(chartViewPower, components[v])
            }
            serie = chartView.series(components[v])
            if(serie !== null) {
                serie.append(timeDiffSecs, jsonHelper.getValue(jsonData[timestamp], components[v]))
                if(loggingTimer.hasTriggered)
                    removePoint(chartView, components[v])
            }
        }
        calculateContentWidth()
    }

    function resetCharts() {
        // clear all series
        for(var i= 0; i < chartView.count; i++)
            chartView.series(i).clear()
        for(var j= 0; j < chartViewPower.count; j++)
            chartViewPower.series(j).clear()
        // reset Y-axis min/max, X-axis is managed differently with property binding
        axisYPower.min = 0
        axisYPower.max = 10
        axisYLeft.min = 0
        axisYLeft.max = 10
        axisYRight.min = 0
        axisYRight.max = 10
    }

    function calculateContentWidth() {
        let actualPoints = Math.round(timeDiffSecs* 2)+1
        if (actualPoints > maxVisibleXPoints) {
            if(!loggingTimer.hasTriggered)
                root.contentWidth = actualPoints * singlePointWidth
        }
        else
            root.contentWidth = chartWidth
    }

    function scaleYAxis(axisY, axisYScalar, value) {
        if(root.timeDiffSecs === 0)
            axisYScalar.reset(value, 0.0)
        axisYScalar.scaleToNewActualValue(value)
        if(axisY.min === 0 || axisY.min > axisYScalar.getRoundedMinValueWithMargin()) //0 is the default min value
            axisY.min = axisYScalar.getRoundedMinValueWithMargin()
        if(axisY.max < axisYScalar.getRoundedMaxValueWithMargin())
            axisY.max = axisYScalar.getRoundedMaxValueWithMargin()
    }

    function removePoint(chartView, componentName) {
        let point  = chartView.series(componentName).at(1)
        loggingTimer.timerMin = point.x
        chartView.series(componentName).remove(0)
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
    SingleValueScaler {
        id: singleValueScaler
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
                text: Z.tr("Select phase to display: ")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                text: Z.tr("Sum")
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
        anchors.top: {
            if(phasesLoader.active)
                return phasesLoader.bottom
            }
        boundsBehavior: Flickable.StopAtBounds
        contentHeight: chartView.height + chartViewPower.height
        width: root.width
        height: phasesLoader.active ? root.height - phasesLoader.height : root.height
        property int chartsHeight: phasesLoader.active ? root.graphHeight /2 - phasesLoader.height : root.graphHeight /2
        flickableDirection: Flickable.VerticalFlick
        clip: true
        onMovementEnded: {
            let pageHeight = chartView.height
            let currentPage = Math.round(contentY / pageHeight);
            contentY = currentPage * pageHeight
        }

        ScrollBar.vertical: ScrollBar {
            id: verticalScroll
            width: verticalFlickable.width * 0.013
            anchors.right: parent.right
            policy : verticalFlickable.height >= chartView.height + chartViewPower.height ?  ScrollBar.AlwaysOff : ScrollBar.AlwaysOn
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
            onPinchUpdated: {
                let pinchScale = pinch.scale * pinch.previousScale
                if (pinchScale > 1.0) {
                    chartView.height = verticalFlickable.chartsHeight
                    chartViewPower.height = verticalFlickable.chartsHeight
                }
                else if (pinchScale < 1.0) {
                    chartView.height = verticalFlickable.chartsHeight/2
                    chartViewPower.height = verticalFlickable.chartsHeight/2
                }
            }
        }

        ChartView {
            id: chartViewPower
            height: verticalFlickable.chartsHeight
            width: root.graphWidth
            antialiasing: true
            theme: ChartView.ChartThemeDark
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

            ValueAxis {
                id: axisYPower
                titleText: "P[" + axisYPower.unitPrefix + "W]"
                titleFont.pixelSize: chartViewPower.height * 0.06
                labelsFont.pixelSize: chartViewPower.height * 0.04
                min: 0
                max: 10
                labelsVisible: false
                property int perDivision: (max - min) / (tickCount - 1)
                property real scale: 1
                property string unitPrefix: ""
                onMaxChanged: {
                    singleValueScaler.scaleSingleValForQML(max)
                    scale = singleValueScaler.getScaleFactor()
                    unitPrefix = singleValueScaler.getUnitPrefix()
                }
            }
            Repeater {
                model: axisYPower.tickCount
                delegate: Text {
                    text: ((axisYPower.max - (index * axisYPower.perDivision)) * axisYPower.scale).toFixed(2)
                    color: axisYPower.labelsColor
                    font.pixelSize: chartViewPower.height * 0.04
                    x: (chartViewPower.plotArea.x * 0.9) - width
                    y: (chartViewPower.plotArea.y * 0.4) + (index * (chartViewPower.plotArea.height / (axisYPower.tickCount - 1)))
                }
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
                        return Math.max(0, loggingTimer.timerMin);
                    else
                        return Math.max(chartViewPower.pinchedXMin, loggingTimer.timerMin)
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
                contentWidth: root.chartWidth
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
                        chartViewPower.pinchedXMin = loggingTimer.timerMin + Math.ceil((root.timeDiffSecs - loggingTimer.timerMin) * position)
                        chartViewPower.pinchedXMax = chartViewPower.pinchedXMin + xAxisTimeSpanSecs
                    }
                }
                PinchArea {
                    id: chartViewPowerPinchArea
                    anchors.fill: parent
                    pinch.dragAxis: Pinch.XAxis
                    enabled: !logging
                    onPinchUpdated: {
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
                name: powerComponentsACDC[0]
                axisX: axisXPower
                axisY: axisYPower
                color: SessionState.dcSession ? CS.colorUAux1 : CS.colorUL1
                visible: GC.showCurvePhaseOne || SessionState.dcSession
                onPointAdded: scaleYAxis(axisYPower, axisYPowerScaler, at(index).y)
            }
            LineSeries {
                name: powerComponentsACDC[1]
                axisX: axisXPower
                axisY: axisYPower
                color: CS.colorUL2
                visible: GC.showCurvePhaseTwo && !SessionState.dcSession
                onPointAdded: scaleYAxis(axisYPower, axisYPowerScaler, at(index).y)
            }
            LineSeries {
                name: powerComponentsACDC[2]
                axisX: axisXPower
                axisY: axisYPower
                color: CS.colorUL3
                visible: GC.showCurvePhaseThree && !SessionState.dcSession
                onPointAdded: scaleYAxis(axisYPower, axisYPowerScaler, at(index).y)
            }
            LineSeries {
                name: powerComponentsACDC[3]
                axisX: axisXPower
                axisY: axisYPower
                color: "white"
                visible: GC.showCurveSum && !SessionState.dcSession
                onPointAdded: scaleYAxis(axisYPower, axisYPowerScaler, at(index).y)
            }
        }
        ChartView {
            id: chartView
            height: phasesLoader.active ? root.graphHeight / 2 - phasesLoader.height : root.graphHeight / 2
            width: root.graphWidth
            anchors.top: chartViewPower.bottom
            antialiasing: true
            theme: ChartView.ChartThemeDark
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

            ValueAxis {
                id: axisYLeft
                titleText: "U[" + axisYLeft.unitPrefix + "V]"
                titleFont.pixelSize: chartView.height * 0.06
                labelsFont.pixelSize: chartView.height * 0.04
                min: 0
                max : 10
                labelsVisible: false
                property int perDivision: (max - min) / (tickCount - 1)
                property real scale: 1
                property string unitPrefix: ""
                onMaxChanged: {
                    singleValueScaler.scaleSingleValForQML(max)
                    scale = singleValueScaler.getScaleFactor()
                    unitPrefix = singleValueScaler.getUnitPrefix()
                }
            }
            Repeater {
                model: axisYLeft.tickCount
                delegate: Text {
                    text: ((axisYLeft.max - (index * axisYLeft.perDivision)) * axisYLeft.scale).toFixed(2)
                    color: axisYLeft.labelsColor
                    font.pixelSize: chartView.height * 0.04
                    x: (chartView.plotArea.x * 0.9) - width
                    y: (chartView.plotArea.y * 0.4) + (index * (chartView.plotArea.height / (axisYLeft.tickCount - 1)))
                }
            }
            ValueAxis {
                id: axisX
                titleText: "T[s]"
                titleFont.pointSize: chartView.height * 0.04
                labelsFont.pixelSize: chartView.height * 0.04
                labelFormat: "%d"
                min: {
                    if(chartView.loggingActive)
                        return Math.max(0, loggingTimer.timerMin)
                    else
                        return Math.max(chartView.pinchedXMin, loggingTimer.timerMin)
                }

                max : {
                    if (chartView.loggingActive)
                        return ((Math.floor(timeDiffSecs/xAxisTimeSpanSecs)) + 1) * xAxisTimeSpanSecs;
                    else
                        return chartView.pinchedXMax;
                }
            }
            ValueAxis {
                id: axisYRight
                titleText: "I[" + axisYRight.unitPrefix + "A]"
                titleFont.pixelSize: chartView.height * 0.06
                labelsFont.pixelSize: chartView.height * 0.04
                min: 0
                max : 10
                labelsVisible: false
                property int perDivision: (max - min) / (tickCount - 1)
                property real scale: 1
                property string unitPrefix: ""
                onMaxChanged: {
                    singleValueScaler.scaleSingleValForQML(max)
                    scale = singleValueScaler.getScaleFactor()
                    unitPrefix = singleValueScaler.getUnitPrefix()
                }
            }
            Repeater {
                model: axisYRight.tickCount
                delegate: Text {
                    text: ((axisYRight.max - (index * axisYRight.perDivision)) * axisYRight.scale).toFixed(2)
                    color: axisYRight.labelsColor
                    font.pixelSize: chartView.height * 0.04
                    x: root.graphWidth - chartView.plotArea.x + 5
                    y: (chartView.plotArea.y * 0.4) + (index * (chartView.plotArea.height / (axisYRight.tickCount - 1)))
                }
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
                        chartView.pinchedXMin = loggingTimer.timerMin + Math.ceil((root.timeDiffSecs - loggingTimer.timerMin) * position)
                        chartView.pinchedXMax = chartView.pinchedXMin + xAxisTimeSpanSecs
                    }
                }
                PinchArea {
                    id: chartViewPinchArea
                    anchors.fill: parent
                    pinch.dragAxis: Pinch.XAxis
                    enabled: !logging
                    onPinchUpdated: {
                        if(pinch.scale > 1)
                            chartViewFlickable.contentWidth = root.contentWidth
                        else {
                            chartViewFlickable.contentWidth = root.chartWidth
                            chartView.pinchedXMax = root.timeDiffSecs
                        }
                    }
                }
            }

            LineSeries {
                name: voltageComponentsAC[0]
                axisX: axisX
                axisY: axisYLeft
                color: CS.colorUL1
                visible: GC.showCurvePhaseOne && !SessionState.dcSession
                onPointAdded: scaleYAxis(axisYLeft, axisYLeftScaler, at(index).y)
            }
            LineSeries {
                name: voltageComponentsAC[1]
                axisX: axisX
                axisY: axisYLeft
                color: CS.colorUL2
                visible: GC.showCurvePhaseTwo && !SessionState.dcSession
                onPointAdded: scaleYAxis(axisYLeft, axisYLeftScaler, at(index).y)
            }
            LineSeries {
                name: voltageComponentsAC[2]
                axisX: axisX
                axisY: axisYLeft
                color: CS.colorUL3
                visible: GC.showCurvePhaseThree && !SessionState.dcSession
                onPointAdded: scaleYAxis(axisYLeft, axisYLeftScaler, at(index).y)
            }
            LineSeries {
                name: currentComponentsAC[0]
                axisX: axisX
                axisYRight: axisYRight
                color: CS.colorIL1
                visible: GC.showCurvePhaseOne && !SessionState.dcSession
                onPointAdded: scaleYAxis(axisYRight, axisYRightScaler, at(index).y)
            }
            LineSeries {
                name: currentComponentsAC[1]
                axisX: axisX
                axisYRight: axisYRight
                color: CS.colorIL2
                visible: GC.showCurvePhaseTwo && !SessionState.dcSession
                onPointAdded: scaleYAxis(axisYRight, axisYRightScaler, at(index).y)
            }
            LineSeries {
                name: currentComponentsAC[2]
                axisX: axisX
                axisYRight: axisYRight
                color: CS.colorIL3
                visible: GC.showCurvePhaseThree && !SessionState.dcSession
                onPointAdded: scaleYAxis(axisYRight, axisYRightScaler, at(index).y)
            }
            LineSeries {
                name: voltageComponentsDC[0]
                axisX: axisX
                axisY: axisYLeft
                color: CS.colorUAux1
                visible: SessionState.dcSession
                onPointAdded: scaleYAxis(axisYLeft, axisYLeftScaler, at(index).y)
            }
            LineSeries {
                name: currentComponentsDC[0]
                axisX: axisX
                axisYRight: axisYRight
                color: CS.colorIAux1
                visible: SessionState.dcSession
                onPointAdded: scaleYAxis(axisYRight, axisYRightScaler, at(index).y)
            }
        }
    }

    Timer {
        id: loggingTimer
        interval: 300000 //5mins
        property double timerMin : 0
        property bool hasTriggered: false
        running: root.logging
        onRunningChanged: {
            if(running) {
                hasTriggered = false
                timerMin = 0
            }
        }
        onTriggered:
            hasTriggered = true
    }
}
