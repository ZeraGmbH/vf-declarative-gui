import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtCharts 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import SessionState 1.0
import VfRecorderJsonHelper 1.0
import GraphFunctions 1.0
import ZeraComponents 1.0
import ZeraTranslation  1.0
import Vf_Recorder 1.0
import AxisAutoScaler 1.0

Item {
    id:  root
    property var graphHeight
    property var graphWidth
    property bool logging : false
    readonly property int xAxisTimeSpanSecs: 8
    readonly property int storageNumber: 0
    readonly property var voltageComponents : [ "ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3", "ACT_DC7"]
    readonly property var currentComponents : [ "ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6", "ACT_DC8"]
    readonly property var powerComponents   : ["ACT_PQS1", "ACT_PQS2", "ACT_PQS3", "ACT_PQS4"]
    readonly property var jsonEnergyDC: { "foo":[{ "EntityId":1060, "Component":["ACT_DC7", "ACT_DC8"]},
                                                 { "EntityId":1073, "Component":["ACT_PQS1"]} ]}
    readonly property var jsonEnergyAC: { "foo":[{ "EntityId":1040, "Component":["ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3", "ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6"]},
                                                 { "EntityId":1070, "Component":["ACT_PQS1", "ACT_PQS2", "ACT_PQS3", "ACT_PQS4"]} ]}
    property real contentWidth: 0.0
    property real chartWidth: root.graphWidth * 0.8356
    property int maxVisibleXPoints: xAxisTimeSpanSecs * 2
    property real singlePointWidth: chartWidth/(maxVisibleXPoints - 1)
    property int maxXValue: 0

    readonly property string currentSession: SessionState.currentSession
    onCurrentSessionChanged: {
        Vf_Recorder.clearJson(storageNumber)
        if(parStartStop === 1)
            Vf_Recorder.stopLogging(storageNumber)
    }
    property int parStartStop
    onParStartStopChanged: {
        if(SessionState.emobSession) {
            if(parStartStop === 1) {
                logging = true
                var inputJson
                if(SessionState.dcSession)
                    inputJson = jsonEnergyDC
                else
                    inputJson = jsonEnergyAC
                if(VeinEntity.getEntity("_System").DevMode) {
                    clearCharts()
                    Vf_Recorder.startLogging(storageNumber, inputJson)
                }
            }
            else if(parStartStop === 0) {
                logging = false
                Vf_Recorder.stopLogging(storageNumber)
            }
        }
    }
    property var jsonData : Vf_Recorder.lastStoredValues0
    onJsonDataChanged:
        loadLastElement()

    function clearCharts() {
        for(var i= 0; i < chartView.count; i++)
            chartView.series(i).clear()
        for(var j= 0; j < chartViewPower.count; j++)
            chartViewPower.series(j).clear()
        resetAxesMinMax()
    }

    function resetAxesMinMax() {
        axisXPower.min = 0
        axisXPower.max = root.xAxisTimeSpanSecs
        axisX.min = 0
        axisX.max = root.xAxisTimeSpanSecs

        axisYLeft.min = 0
        axisYLeft.max = 10
        axisYRight.min = 0
        axisYRight.max = 10
        axisYPower.min = 0
        axisYPower.max = 10
    }

    function createLineSeries(componentsList) {
        for(var component in componentsList) {
            var series;
            if(powerComponents.includes(componentsList[component]))
                series = chartViewPower.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisXPower, axisYPower);
            if(voltageComponents.includes(componentsList[component]))
                series = chartView.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisX, axisYLeft);
            if(currentComponents.includes(componentsList[component]))
                series = chartView.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisX, axisYRight);

            series.width = 1
            series.color = GraphFunctions.getChannelColor(componentsList[component])
        }
        loadAllElements(componentsList)
    }

    function findSerie(componentName) {
        let series = null
        if(powerComponents.includes(componentName))
            series = chartViewPower.series(componentName)
        if(voltageComponents.includes(componentName) || currentComponents.includes(componentName))
            series = chartView.series(componentName)
        return series
    }

    function enableSeries(componentsList) {
        for(var i= 0; i<componentsList.length; i++) {
            var series = findSerie(componentsList[i])
            if(series !==null)
                series.style = Qt.SolidLine
        }
    }

    function removeLineSeries(componentsList) {
        for(var i= 0; i<componentsList.length; i++) {
            var series = findSerie(componentsList[i])
            if(series !==null)
                series.style = Qt.NoPen
        }
    }

    function setXaxisMinMax(axisX, timeDiffSecs) {
        if(axisX.max < timeDiffSecs) {
            axisX.max = timeDiffSecs + xAxisTimeSpanSecs
            axisX.min = 0
        }
        maxXValue = timeDiffSecs
    }

    function setYaxisMinMax(axisY, minValue, maxValue) {
        if(axisY.min === 0 || axisY.min > minValue) //0 is the default min value
            axisY.min = minValue
        if(axisY.max < maxValue)
            axisY.max = maxValue
    }

    function recalculateYAxisMinMax(axisY, minValue, maxValue) {
        if(axisY.min > minValue)
            axisY.min = minValue
        if(axisY.max < maxValue)
            axisY.max = maxValue
    }

    function appendPointToSerie(serie, timeDiffSecs, value, loadAllElts, axisX, axisY, axisYScaler) {
        if(serie !== null) {
            serie.append(timeDiffSecs, value)
            if(timeDiffSecs === 0)//first sample
                axisYScaler.reset(value, 0.0)
            axisYScaler.scaleToNewActualValue(value)
            setXaxisMinMax(axisX, timeDiffSecs)
            if(loadAllElts) {
                recalculateYAxisMinMax(axisY, axisYScaler.getRoundedMinValue(), axisYScaler.getRoundedMaxValue())
            }
            else
                setYaxisMinMax(axisY, axisYScaler.getRoundedMinValue(), axisYScaler.getRoundedMaxValue())
        }
    }

    function calculateContentWidth(timeDiffSecs) {
        let actualPoints = timeDiffSecs * 2
        if ((GC.showCurvePhaseOne || GC.showCurvePhaseTwo || GC.showCurvePhaseThree || GC.showCurveSum) && (actualPoints > maxVisibleXPoints))
            root.contentWidth = root.contentWidth + singlePointWidth
        else
            root.contentWidth = chartWidth
    }

    function loadElement(singleJsonData, components, timeDiffSecs, loadAllElts) {
        for(var v = 0 ; v <components.length; v++) {
            let value = jsonHelper.getValue(singleJsonData, components[v])
            if(powerComponents.includes(components[v]))
                appendPointToSerie(chartViewPower.series(components[v]), timeDiffSecs, value, loadAllElts, axisXPower, axisYPower, axisYPowerScaler)
            else if(voltageComponents.includes(components[v]))
                appendPointToSerie(chartView.series(components[v]), timeDiffSecs, value, loadAllElts, axisX, axisYLeft, axisYLeftScaler)
            else if(currentComponents.includes(components[v]))
                appendPointToSerie(chartView.series(components[v]), timeDiffSecs, value, loadAllElts, axisX, axisYRight, axisYRightScaler)
            }
        calculateContentWidth(timeDiffSecs)
    }

    function loadLastElement() {
        var timestamp = Object.keys(jsonData)[0]
        var timeDiffSecs = GraphFunctions.calculateTimeDiffSecs(timestamp)
        var components = jsonHelper.getComponents(jsonData[timestamp])
        loadElement(jsonData[timestamp], components, timeDiffSecs, false)
    }

    function loadAllElements(components) {
        var completeJson = Vf_Recorder.storedValues0
        for(var timestamp in completeJson) {
            var jsonWithoutTimestamp = completeJson[timestamp]
            var timeDiffSecs = GraphFunctions.calculateTimeDiffSecs(timestamp)
            loadElement(jsonWithoutTimestamp, components, timeDiffSecs, true)
        }
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

    Flickable {
        id: flickable
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        contentHeight: chartView.height + chartViewPower.height + phasesLoader.height
        width: root.width
        height: root.height
        flickableDirection: Flickable.VerticalFlick
        clip: true
        onMovementEnded: {
            let pageHeight = chartView.height
            let currentPage = Math.round(contentY / pageHeight);
            contentY = currentPage * pageHeight
        }

        ScrollBar.vertical: ScrollBar {
            id: verticalScroll
            width: flickable.width * 0.013
            anchors.right: parent.right
            policy : flickable.height >= chartView.height + chartViewPower.height ?  ScrollBar.AlwaysOff : ScrollBar.AlwaysOn
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
                    chartView.height = root.graphHeight /2
                    chartViewPower.height = root.graphHeight / 2 - phasesLoader.height
                }
                else if (pinchScale < 1.0) {
                    chartView.height = root.graphHeight / 4 - phasesLoader.height/2
                    chartViewPower.height = root.graphHeight / 4 - phasesLoader.height/2
                }
            }
        }
        Item {}

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
                    text: Z.tr("L1")
                    width: root.graphWidth
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    checked: GC.showCurvePhaseOne
                    onCheckedChanged:
                        checkCombo = checked
                    property var checkCombo: GC.showCurvePhaseOne
                    onCheckComboChanged: {
                        GC.setPhaseOne(checked)
                        var phase1Compos = ["ACT_RMSPN1", "ACT_RMSPN4", "ACT_PQS1"]
                        if(checked)
                            enableSeries(phase1Compos)
                        else
                            removeLineSeries(phase1Compos)
                    }
                }
                ZCheckBox {
                    text: Z.tr("L2")
                    width: root.graphWidth
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    checked: GC.showCurvePhaseTwo
                    onCheckStateChanged:
                        checkCombo = checked
                    property var checkCombo: GC.showCurvePhaseTwo
                    onCheckComboChanged: {
                        GC.setPhaseTwo(checked)
                        var phase2Compos = ["ACT_RMSPN2", "ACT_RMSPN5", "ACT_PQS2"]
                        if(checked)
                            enableSeries(phase2Compos)
                        else
                            removeLineSeries(phase2Compos)
                    }
                }
                ZCheckBox {
                    text: Z.tr("L3")
                    width: parent.width
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    checked: GC.showCurvePhaseThree
                    onCheckStateChanged:
                        checkCombo = checked
                    property var checkCombo: GC.showCurvePhaseThree
                    onCheckComboChanged: {
                        GC.setPhaseThree(checked)
                        var phase3Compos = ["ACT_RMSPN3", "ACT_RMSPN6", "ACT_PQS3"]
                        if(checked)
                            enableSeries(phase3Compos)
                        else
                            removeLineSeries(phase3Compos)
                    }
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
                    onCheckComboChanged: {
                        GC.setSum(checked)
                        var phaseSumCompos = ["ACT_PQS4"]
                        if(checked)
                            enableSeries(phaseSumCompos)
                        else
                            removeLineSeries(phaseSumCompos)
                    }
                }
            }
        }

        ChartView {
            id: chartViewPower
            height: root.graphHeight / 2 - phasesLoader.height
            width: root.graphWidth * 1.032
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            anchors.top: phasesLoader.bottom
            x: - root.graphWidth * 0.032
            antialiasing: true
            theme: ChartView.ChartThemeDark
            legend.visible: false

            ValueAxis {
                id: axisYPower
                color: GC.colorUAux1
                labelsColor: GC.colorUAux1
                titleText: "P[W]"
                titleFont.pixelSize: chartViewPower.height * 0.06
                labelsFont.pixelSize: chartViewPower.height * 0.04
                labelFormat: "%d"
                min: 0
                max : 10
            }
            ValueAxis {
                id: axisXPower
                titleText: "T[s]"
                titleFont.pointSize: chartViewPower.height * 0.04
                labelsFont.pixelSize: chartViewPower.height * 0.04
                labelFormat: "%d"
                min: 0
                max : xAxisTimeSpanSecs
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
                    height: root.height * 0.03
                    policy: ScrollBar.AlwaysOn
                    anchors.bottom: parent.bottom
                    interactive: !logging
                    position: 1.0 - size
                    onPositionChanged: {
                        let newXMin
                        newXMin = root.maxXValue * position
                        axisXPower.min = Math.ceil(newXMin)
                        axisXPower.max = Math.ceil(newXMin + xAxisTimeSpanSecs)
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
                            axisXPower.min = 0
                            axisXPower.max = root.maxXValue
                        }
                    }
                }
            }
            LineSeries {
                id: lineSeriesP
                axisX: axisXPower
                axisY: axisYPower
                color: GC.colorUAux1
            }
        }
        ChartView {
            id: chartView
            height: root.graphHeight / 2
            width: root.graphWidth * 1.065
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: chartViewPower.bottom
            anchors.topMargin: 0
            x: - root.graphWidth * 0.032
            antialiasing: true
            theme: ChartView.ChartThemeDark
            legend.visible: false

            ValueAxis {
                id: axisYLeft
                color: GC.colorUAux1
                labelsColor: GC.colorUAux1
                titleText: "U[V]"
                titleFont.pixelSize: chartView.height * 0.06
                labelsFont.pixelSize: chartView.height * 0.04
                labelFormat: "%d"
                min: 0
                max : 10
            }
            ValueAxis {
                id: axisX
                titleText: "T[s]"
                titleFont.pointSize: chartView.height * 0.04
                labelsFont.pixelSize: chartView.height * 0.04
                labelFormat: "%d"
                min: 0
                max : xAxisTimeSpanSecs
            }
            ValueAxis {
                id: axisYRight
                color: GC.colorIAux1
                labelsColor: GC.colorIAux1
                titleText: "I[A]"
                titleFont.pixelSize: chartView.height * 0.06
                labelsFont.pixelSize: chartView.height * 0.04
                labelFormat: "%d"
                min: 0
                max : 10
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
                    height: root.height * 0.03
                    policy: ScrollBar.AlwaysOn
                    anchors.bottom: parent.bottom
                    interactive: !logging
                    position: 1.0 - size
                    onPositionChanged: {
                        let newXMin
                        newXMin = root.maxXValue * position
                        axisX.min = Math.ceil(newXMin)
                        axisX.max = Math.ceil(newXMin + xAxisTimeSpanSecs)
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
                            axisX.min = 0
                            axisX.max = root.maxXValue
                        }
                    }
                }
            }
            LineSeries {
                id: lineSeriesU
                axisX: axisX
                axisY: axisYLeft
                color: GC.colorUAux1
            }
            LineSeries {
                id: lineSeriesI
                axisX: axisX
                axisYRight: axisYRight
                color: GC.colorIAux1
            }
        }
    }
    Component.onCompleted: {
        var compos
        if(SessionState.emobSession) {
            if(SessionState.dcSession) {
                compos = ["ACT_DC7", "ACT_DC8", "ACT_PQS1"]
                createLineSeries(compos)
            }
            else {
                compos = ["ACT_RMSPN1", "ACT_RMSPN4", "ACT_PQS1"]
                createLineSeries(compos)
                compos = ["ACT_RMSPN2", "ACT_RMSPN5", "ACT_PQS2"]
                createLineSeries(compos)
                compos = ["ACT_RMSPN3", "ACT_RMSPN6", "ACT_PQS3"]
                createLineSeries(compos)
                compos = ["ACT_PQS4"]
                createLineSeries(compos)
            }
        }
    }
}
