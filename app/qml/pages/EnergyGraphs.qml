import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtCharts 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import SessionState 1.0
import JsonHelper 1.0
import GraphFunctions 1.0
import ZeraComponents 1.0
import ZeraTranslation  1.0
import Vf_Recorder 1.0
import AxisAutoScaler 1.0

Item {
    id:  root
    property var graphHeight
    property var graphWidth
    readonly property int storageNumber: 0
    readonly property var voltageComponents : [ "ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3", "ACT_DC7"]
    readonly property var currentComponents : [ "ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6", "ACT_DC8"]
    readonly property var powerComponents   : ["ACT_PQS1", "ACT_PQS2", "ACT_PQS3", "ACT_PQS4"]
    readonly property var jsonEnergyDC: { "foo":[{ "EntityId":1060, "Component":["ACT_DC7", "ACT_DC8"]},
                                                 { "EntityId":1073, "Component":["ACT_PQS1"]} ]}
    readonly property var jsonEnergyAC: { "foo":[{ "EntityId":1040, "Component":["ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3", "ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6"]},
                                                 { "EntityId":1070, "Component":["ACT_PQS1", "ACT_PQS2", "ACT_PQS3", "ACT_PQS4"]} ]}

    property int parStartStop
    onParStartStopChanged: {
        if(SessionState.emobSession) {
            if(parStartStop === 1) {
                var inputJson
                if(SessionState.dcSession)
                    inputJson = jsonEnergyDC
                else
                    inputJson = jsonEnergyAC
                if(VeinEntity.getEntity("_System").DevMode) {
                    GraphFunctions.prepareCharts()
                    Vf_Recorder.startLogging(storageNumber, inputJson)
                }
            }
            else if(parStartStop === 0)
                Vf_Recorder.stopLogging(storageNumber)
        }
    }
    property var jsonData : Vf_Recorder.lastStoredValues0
    onJsonDataChanged:
        loadLastElement()

    function createLineSeries(componentsList) {
        for(var component in componentsList) {
            var series;
            if(powerComponents.includes(componentsList[component]))
                series = chartViewPower.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisXPower, axisYPower);
            if(voltageComponents.includes(componentsList[component]))
                series = chartView.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisX, axisYLeft);
            if(currentComponents.includes(componentsList[component]))
                series = chartView.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisX, axisYRight);

            GraphFunctions.lineSeriesList.push(series)
            GraphFunctions.setColors()
        }
        loadAllElements(componentsList)
    }

    function removeLineSeries(componentsList) {
        var lineSeries = GraphFunctions.lineSeriesList
        var indexOfCompoToRemove = []
        for(var i= 0; i<componentsList.length; i++) {
            if(powerComponents.includes(componentsList[i])) {
                var series = chartViewPower.series(componentsList[i])
                if(series !==null)
                    chartViewPower.removeSeries(series)
            }
            if(voltageComponents.includes(componentsList[i]) || currentComponents.includes(componentsList[i])) {
                series = chartView.series(componentsList[i])
                if(series !==null)
                    chartView.removeSeries(series)
            }
            for(var k = 0; k < lineSeries.length; k++) {
                if(lineSeries[k].name === componentsList[i]) {
                    indexOfCompoToRemove.push(k)
                }
            }
        }
        while(indexOfCompoToRemove.length > 0) {
            var index = indexOfCompoToRemove.pop()
            lineSeries.splice(index, 1)
        }
        GraphFunctions.lineSeriesList = lineSeries
    }

    function loadElement(singleJsonData, components, timeDiffSecs) {
        for(var v = 0 ; v <components.length; v++) {
            let value = jsonHelper.getValue(singleJsonData, components[v])
            if(powerComponents.includes(components[v]))
                GraphFunctions.appendPointToSerie(chartViewPower.series(components[v]), timeDiffSecs, value, axisYPower, axisYPowerScaler)
            else if(voltageComponents.includes(components[v]))
                GraphFunctions.appendPointToSerie(chartView.series(components[v]), timeDiffSecs, value, axisYLeft, axisYLeftScaler)
            else if(currentComponents.includes(components[v]))
                GraphFunctions.appendPointToSerie(chartView.series(components[v]), timeDiffSecs, value, axisYRight, axisYRightScaler)
        }
    }

    function loadLastElement() {
        var timestamp = Object.keys(jsonData)[0]
        var timeDiffSecs = GraphFunctions.calculateTimeDiffSecs(timestamp)
        GraphFunctions.setXaxisMinMax(axisX, axisXPower, timeDiffSecs)
        var components = jsonHelper.getComponents(jsonData[timestamp])
        loadElement(jsonData[timestamp], components, timeDiffSecs)
    }

    function loadAllElements(components) {
        var completeJson = Vf_Recorder.storedValues0
        for(var timestamp in completeJson) {
            var jsonWithoutTimestamp = completeJson[timestamp]
            var timeDiffSecs = GraphFunctions.calculateTimeDiffSecs(timestamp)
            loadElement(jsonWithoutTimestamp, components, timeDiffSecs)
        }
    }

    JsonHelper {
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

        ScrollBar.vertical: ScrollBar {
            id: verticalScroll
            width: 8
            policy : flickable.height >= chartView.height + chartViewPower.height ?  ScrollBar.AlwaysOff : ScrollBar.AlwaysOn
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
            height: 32  // root.graphHeight * 0.045
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
                            createLineSeries(phase1Compos)
                        else
                            removeLineSeries(phase1Compos)
                    }
                }
                ZCheckBox {
                    text: Z.tr("L2")
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
                            createLineSeries(phase2Compos)
                        else
                            removeLineSeries(phase2Compos)
                    }

                }
                ZCheckBox {
                    text: Z.tr("L3")
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
                            createLineSeries(phase3Compos)
                        else
                            removeLineSeries(phase3Compos)
                    }
                }
                ZCheckBox {
                    text: Z.tr("Sum")
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
                            createLineSeries(phaseSumCompos)
                        else
                            removeLineSeries(phaseSumCompos)
                    }
                }
            }
        }
        ChartView {
            id: chartViewPower
            height: root.graphHeight / 2 - phasesLoader.height
            anchors.rightMargin: chartView.height * 0.1
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            width: root.graphWidth
            anchors.top: phasesLoader.bottom
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
            }
            ValueAxis {
                id: axisXPower
                titleText: "T[s]"
                titleFont.pointSize: chartViewPower.height * 0.04
                labelsFont.pixelSize: chartViewPower.height * 0.04
                labelFormat: "%d"
            }
            Flickable {
                id : chartViewPowerFlickable
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                width: root.width
                height: root.height
                flickableDirection: Flickable.HorizontalFlick
                clip: true
                interactive: (parStartStop === 1) ? false : true
                ScrollBar.horizontal: ScrollBar {
                   height: 9
                   policy: ScrollBar.AlwaysOn
                   interactive: chartViewPowerFlickable.interactive
                   onPositionChanged: {
                       if(chartViewPowerFlickable.interactive) {
                           let currentPosition = chartViewPowerFlickable.visibleArea.xPosition
                           let positionDiff = position - currentPosition
                           let scrollAmount = chartViewPowerFlickable.contentWidth * positionDiff
                           if(positionDiff < 0)
                               chartViewPower.scrollLeft(-scrollAmount)
                            else
                               chartViewPower.scrollRight(scrollAmount)
                       }
                   }
                   position: 1.0 - size
                }
            }
            LineSeries {
                id: lineSeriesP
                axisX: axisXPower
                axisY: axisYPower
                color: GC.colorUAux1
            }
            onSeriesAdded: {
                chartViewPowerFlickable.contentWidth = Qt.binding(function() {
                    let actualGraphWidth = root.graphWidth * 0.85
                    if((GraphFunctions.lineSeriesList.length > 0) && (GraphFunctions.lineSeriesList[0].count > 20))
                        return actualGraphWidth + ((GraphFunctions.lineSeriesList[0].count - 20) * actualGraphWidth/20)
                    else
                        return actualGraphWidth
                })
            }
       }
        ChartView {
            id: chartView
            height: root.graphHeight / 2
            width: root.graphWidth
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: chartViewPower.bottom
            anchors.topMargin: 0
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
            }
            ValueAxis {
                id: axisX
                titleText: "T[s]"
                titleFont.pointSize: chartView.height * 0.04
                labelsFont.pixelSize: chartView.height * 0.04
                labelFormat: "%d"
            }
            ValueAxis {
                id: axisYRight
                color: GC.colorIAux1
                labelsColor: GC.colorIAux1
                titleText: "I[A]"
                titleFont.pixelSize: chartView.height * 0.06
                labelsFont.pixelSize: chartView.height * 0.04
                labelFormat: "%d"
            }

            Flickable {
                id: chartViewFlickable
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                width: root.width
                height: root.height
                flickableDirection: Flickable.HorizontalFlick
                clip: true
                interactive: (parStartStop === 1) ? false : true
                contentWidth: chartViewPowerFlickable.contentWidth
                ScrollBar.horizontal: ScrollBar {
                    id: hbar
                    policy: ScrollBar.AlwaysOn
                    anchors.bottom: parent.bottom
                    height: 9
                    interactive: chartViewFlickable.interactive
                    property real oldPosition: 0
                    onPositionChanged: {
                        let axisXRange = axisX.max - axisX.min;
                        let scrollAmount = (position - oldPosition) * axisXRange * 100;
                        if(position > oldPosition)
                            chartView.scrollLeft(scrollAmount)
                         else
                            chartView.scrollRight(-scrollAmount)
                        oldPosition = position
                    }
                    position: 1.0 - size
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
        GraphFunctions.lineSeriesList = []
        if(SessionState.emobSession && SessionState.dcSession) {
            var compos = ["ACT_DC7", "ACT_DC8", "ACT_PQS1"]
            createLineSeries(compos)
        }
    }
}
