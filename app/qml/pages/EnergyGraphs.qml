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

Item {
    id:  root
    readonly property var voltageComponents : [ "ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3", "ACT_DC7"]
    readonly property var currentComponents : [ "ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6", "ACT_DC8"]
    readonly property var powerComponents   : ["ACT_PQS1", "ACT_PQS2", "ACT_PQS3", "ACT_PQS4"]

    property var graphHeight
    property var graphWidth
    property var componentsList
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

            GraphFunctions.appendIfNotDuplicated(series)
            loadAllElements(series)
            GraphFunctions.setColors()
        }
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

    function loadLastElement() {
        var actValU = []
        var actValI = []
        var actValP = []

        //GraphFunctions.prepareCharts(Object.keys(jsonData))
        var timestamps = Object.keys(jsonData).sort()
        var timestamp = timestamps[timestamps.length - 1]
        var time = jsonHelper.convertTimestampToMs(timestamp)
        var components = jsonHelper.getComponents(jsonData, time)
        for(var v = 0 ; v <components.length; v++) {
            if(voltageComponents.includes(components[v]))
                actValU.push({x: time, y: components[v]})
            if(currentComponents.includes(components[v]))
                actValI.push({x: time, y: components[v]})
            if(powerComponents.includes(components[v]))
                actValP.push({x: time, y: components[v]})
        }
        for(let vCompo in voltageComponents)
            GraphFunctions.appendLastElemt(actValU, voltageComponents[vCompo], jsonData, axisYLeft, axisX, axisXPower)
        for(let iCompo in currentComponents)
            GraphFunctions.appendLastElemt(actValI, currentComponents[iCompo], jsonData, axisYRight, axisX, axisXPower)
        for(let pCompo in powerComponents)
            GraphFunctions.appendLastElemt(actValP, powerComponents[pCompo], jsonData, axisYPower, axisX, axisXPower)
    }

    function loadAllElements(LineSerie) {
        var timestamps = Object.keys(jsonData).sort()
        for (var i = 0; i < timestamps.length; i++) {
            var timestamp = timestamps[i]
            var data = jsonData[timestamp]
            var time = jsonHelper.convertTimestampToMs(timestamp)
            var components = jsonHelper.getComponents(jsonData, time)
            for(var v = 0 ; v <components.length; v++) {
                if (LineSerie.name === components[v]) {
                    if(voltageComponents.includes(components[v]))
                        GraphFunctions.appendPointToLineSerie(jsonData, time, components[v], axisYLeft, axisX, axisXPower)
                    if(currentComponents.includes(components[v]))
                        GraphFunctions.appendPointToLineSerie(jsonData, time, components[v], axisYRight, axisX, axisXPower)
                    if(powerComponents.includes(components[v]))
                        GraphFunctions.appendPointToLineSerie(jsonData, time, components[v], axisYPower, axisX, axisXPower)
                }
            }
        }
    }

    JsonHelper {
        id: jsonHelper
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
            anchors.left: chartView.left
            anchors.right: chartView.right
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
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                width: root.width
                height: root.height
                flickableDirection: Flickable.HorizontalFlick
                clip: true
                contentWidth: {
                    var width = 0.0
                    var lineSeriesList = GraphFunctions.lineSeriesList
                    for(var k = 0 ; k < lineSeriesList.length; k++) {
                        if(powerComponents.includes(lineSeriesList[k].name))
                            width = graphWidth * lineSeriesList[k].count * 0.045
                    }
                    return width
                }
                ScrollBar.horizontal: ScrollBar {
                   height: 9
                   policy: ScrollBar.AlwaysOn
                   interactive: true
                   property real oldPosition: 0
                   onPositionChanged: {
                       let axisXRange = axisXPower.max - axisXPower.min;
                       let scrollAmount = (position - oldPosition) * axisXRange * 100;
                       if(position > oldPosition)
                           chartViewPower.scrollLeft(scrollAmount)
                        else
                           chartViewPower.scrollRight(-scrollAmount)
                       oldPosition = position
                   }
                }

                LineSeries {
                    id: lineSeriesP
                    axisX: axisXPower
                    axisY: axisYPower
                    color: GC.colorUAux1
                }
            }
       }
        ChartView {
            id: chartView
            height: root.graphHeight / 2
            width: root.graphWidth * 1.08
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
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                width: root.width
                height: root.height
                flickableDirection: Flickable.HorizontalFlick
                clip: true
                contentHeight: chartView.height
                contentWidth: {
                    var width = 0.0
                    var lineSeriesList = GraphFunctions.lineSeriesList;
                    for (var i = 0; i < lineSeriesList.length; i++) {
                        if (powerComponents.includes(lineSeriesList[i].name)) {
                            width = graphWidth * lineSeriesList[i].count * 0.045;
                        }
                    }
                    return width
                }
                ScrollBar.horizontal: ScrollBar {
                    id: hbar
                    policy: ScrollBar.AlwaysOn
                    anchors.bottom: parent.bottom
                    height: 9
                    interactive: true
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
                }
                LineSeries {
                    id: lineSeriesU
                    axisX: axisX
                    axisY: axisYLeft
                    color: GC.colorUAux1
                }
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
