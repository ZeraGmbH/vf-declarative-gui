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

    readonly property var voltageComponentsAC: ["ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3"]
    readonly property var currentComponentsAC: ["ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6"]
    readonly property var voltageComponentsDC: ["ACT_DC7"]
    readonly property var currentComponentsDC: ["ACT_DC8"]
    readonly property var powerComponentsACDC: ["ACT_PQS1", "ACT_PQS2", "ACT_PQS3", "ACT_PQS4"]

    readonly property bool dcSession: SessionState.dcSession
    property var voltageComponents: dcSession ? voltageComponentsDC : voltageComponentsAC
    property var currentComponents: dcSession ? currentComponentsDC : currentComponentsAC
    property var powerComponents: dcSession ? powerComponentsACDC[0] : powerComponentsACDC

    readonly property var jsonEnergyDC: {"foo":[{"EntityId":1060, "Component":voltageComponentsDC.concat(currentComponentsDC)},
                                                {"EntityId":1073, "Component":powerComponentsACDC[0]}]}
    readonly property var jsonEnergyAC: {"foo":[{"EntityId":1040, "Component":voltageComponentsAC.concat(currentComponentsAC)},
                                                {"EntityId":1070, "Component":powerComponentsACDC}]}

    property bool logging : false
    property real timeDiffSecs : 0.0
    readonly property int xAxisTimeSpanSecs: 8
    readonly property int storageNumber: 0
    property real contentWidth: 0.0
    property real chartWidth: root.graphWidth * 0.8356
    property int maxVisibleXPoints: (xAxisTimeSpanSecs * 2) +1
    property real singlePointWidth: chartWidth/(maxVisibleXPoints - 1)

    readonly property string currentSession: SessionState.currentSession
    onCurrentSessionChanged: {
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
    property var jsonData : Vf_Recorder.latestStoredValues0
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
        axisYLeft.min = 0
        axisYLeft.max = 10
        axisYRight.min = 0
        axisYRight.max = 10
        axisYPower.min = 0
        axisYPower.max = 10
    }

    function setYaxisMinMax(axisY, minValue, maxValue) {
        if(axisY.min === 0 || axisY.min > minValue) //0 is the default min value
            axisY.min = minValue
        if(axisY.max < maxValue)
            axisY.max = maxValue
    }

    function appendPointToSerie(serie, value, axisY, axisYScaler) {
        if(serie !== null) {
            serie.append(timeDiffSecs, value)
            if(timeDiffSecs === 0)//first sample
                axisYScaler.reset(value, 0.0)
            axisYScaler.scaleToNewActualValue(value)
            setYaxisMinMax(axisY, axisYScaler.getRoundedMinValue(), axisYScaler.getRoundedMaxValue())
        }
    }

    function calculateContentWidth() {
        let actualPoints = Math.round(timeDiffSecs* 2)+1
        if (actualPoints > maxVisibleXPoints) {
            root.contentWidth = actualPoints * singlePointWidth
        }
        else
            root.contentWidth = chartWidth
    }

    function loadLastElement() {
        var timestamp = Object.keys(jsonData)[0]
        timeDiffSecs = GraphFunctions.calculateTimeDiffSecs(timestamp)
        var components = jsonHelper.getComponents(jsonData[timestamp])

        for(var v = 0 ; v <components.length; v++) {
            let value = jsonHelper.getValue(jsonData[timestamp], components[v])
            if(powerComponents.includes(components[v]))
                appendPointToSerie(chartViewPower.series(components[v]), value, axisYPower, axisYPowerScaler)
            else if(voltageComponents.includes(components[v]))
                appendPointToSerie(chartView.series(components[v]), value, axisYLeft, axisYLeftScaler)
            else if(currentComponents.includes(components[v]))
                appendPointToSerie(chartView.series(components[v]), value, axisYRight, axisYRightScaler)
        }
        calculateContentWidth()
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
                onCheckComboChanged:
                    GC.setPhaseOne(checked)
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
                onCheckComboChanged:
                    GC.setPhaseTwo(checked)
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
        id: flickable
        anchors.top: {
            if(phasesLoader.active)
                return phasesLoader.bottom
            }
        boundsBehavior: Flickable.StopAtBounds
        contentHeight: chartView.height + chartViewPower.height
        width: root.width
        height: phasesLoader.active ? root.height - phasesLoader.height : root.height
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
                    chartView.height = phasesLoader.active ? root.graphHeight /2 - phasesLoader.height : root.graphHeight /2
                    chartViewPower.height = phasesLoader.active ? root.graphHeight /2 - phasesLoader.height : root.graphHeight /2
                }
                else if (pinchScale < 1.0) {
                    chartView.height = phasesLoader.active ? root.graphHeight / 4 - phasesLoader.height/2 : root.graphHeight / 4
                    chartViewPower.height = phasesLoader.active ? root.graphHeight / 4 - phasesLoader.height/2 : root.graphHeight / 4
                }
            }
        }
        Item {}

        ChartView {
            id: chartViewPower
            height: phasesLoader.active ? root.graphHeight / 2 - phasesLoader.height : root.graphHeight / 2
            width: root.graphWidth
            antialiasing: true
            theme: ChartView.ChartThemeDark
            legend.visible: false
            margins {right: root.graphWidth * 0.067; left: root.graphWidth * 0.004; top: 0; bottom: 0}
            property bool loggingActive: logging
            property int pinchedXMin: 0
            property int pinchedXMax: xAxisTimeSpanSecs
            onLoggingActiveChanged: {
                pinchedXMin = 0
                pinchedXMax = root.timeDiffSecs
            }

            ValueAxis {
                id: axisYPower
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
                property int currentMax: max
                min: {
                    if(logging)
                        return 0
                    else
                        return chartViewPower.pinchedXMin
                }
                max: {
                    if (logging)
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
                        chartViewPower.pinchedXMin = Math.ceil(root.timeDiffSecs * position)
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
            LineSeries {style: GC.showCurvePhaseOne || SessionState.dcSession? Qt.SolidLine : Qt.NoPen; name: powerComponentsACDC[0]; axisX: axisXPower; axisY: axisYPower; color: SessionState.dcSession ? GC.colorUAux1 : GC.colorUL1}
            LineSeries {style: GC.showCurvePhaseTwo ? Qt.SolidLine : Qt.NoPen; name: powerComponentsACDC[1]; axisX: axisXPower; axisY: axisYPower; color: GC.colorUL2; visible: !SessionState.dcSession}
            LineSeries {style: GC.showCurvePhaseThree ? Qt.SolidLine : Qt.NoPen; name: powerComponentsACDC[2]; axisX: axisXPower; axisY: axisYPower; color: GC.colorUL3; visible: !SessionState.dcSession}
            LineSeries {style: GC.showCurveSum ? Qt.SolidLine : Qt.NoPen; name: powerComponentsACDC[3]; axisX: axisXPower; axisY: axisYPower; color: "white"; visible: !SessionState.dcSession}
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
                pinchedXMin = 0
                pinchedXMax = root.timeDiffSecs
            }

            ValueAxis {
                id: axisYLeft
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
                min: {
                    if(logging)
                        return 0
                    else
                        return chartView.pinchedXMin
                }
                max :  {
                    if (logging)
                        return ((Math.floor(timeDiffSecs/xAxisTimeSpanSecs)) + 1) * xAxisTimeSpanSecs
                    else
                        return chartView.pinchedXMax
                }
            }
            ValueAxis {
                id: axisYRight
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
                    height: root.height * 0.025
                    policy: ScrollBar.AlwaysOn
                    anchors.bottom: parent.bottom
                    interactive: !logging
                    position: 1.0 - size
                    onPositionChanged: {
                        chartView.pinchedXMin = Math.ceil(root.timeDiffSecs * position)
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

            LineSeries {style: GC.showCurvePhaseOne ? Qt.SolidLine : Qt.NoPen; name: voltageComponentsAC[0]; axisX: axisX; axisY: axisYLeft; color: GC.colorUL1; visible: !SessionState.dcSession}
            LineSeries {style: GC.showCurvePhaseTwo ? Qt.SolidLine : Qt.NoPen; name: voltageComponentsAC[1]; axisX: axisX; axisY: axisYLeft; color: GC.colorUL2; visible: !SessionState.dcSession}
            LineSeries {style: GC.showCurvePhaseThree ? Qt.SolidLine : Qt.NoPen; name: voltageComponentsAC[2]; axisX: axisX; axisY: axisYLeft; color: GC.colorUL3; visible: !SessionState.dcSession}
            LineSeries {style: GC.showCurvePhaseOne ? Qt.SolidLine : Qt.NoPen; name: currentComponentsAC[0]; axisX: axisX; axisYRight: axisYRight; color: GC.colorIL1; visible: !SessionState.dcSession}
            LineSeries {style: GC.showCurvePhaseTwo ? Qt.SolidLine : Qt.NoPen; name: currentComponentsAC[1]; axisX: axisX; axisYRight: axisYRight; color: GC.colorIL2; visible: !SessionState.dcSession}
            LineSeries {style: GC.showCurvePhaseThree ? Qt.SolidLine : Qt.NoPen; name: currentComponentsAC[2]; axisX: axisX; axisYRight: axisYRight; color: GC.colorIL3; visible: !SessionState.dcSession}
            LineSeries {style: Qt.SolidLine; name: voltageComponentsDC[0]; axisX: axisX; axisY: axisYLeft; color: GC.colorUAux1; visible: SessionState.dcSession}
            LineSeries {style: Qt.SolidLine; name: currentComponentsDC[0]; axisX: axisX; axisYRight: axisYRight; color: GC.colorIAux1; visible: SessionState.dcSession}
        }
    }
}
