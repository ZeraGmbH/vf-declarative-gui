import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtCharts 2.0
import GlobalConfig 1.0
import SessionState 1.0
import JsonHelper 1.0

Item {
    id:  root
    property var graphHeight
    property var graphWidth
    property bool timerHasTriggered: false
    property var componentsList
    property var jsonData
    onJsonDataChanged:
        loadData()

    function createLineSeries() {
        let lineSeriesList = []
        for(var component in componentsList) {
            if(componentsList[component].includes("ACT_PQS1") || componentsList[component].includes("ACT_PQS2") || componentsList[component].includes("ACT_PQS3")) {
                var series = chartViewPower.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisXPower, axisYPower);
            }
            else {
                series = chartView.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisX, axisYLeft);
            }
            lineSeriesList.push(series)
        }
        return lineSeriesList
    }

    function setColors(lineSeriesList) {
        for(var k = 0; k < lineSeriesList.length; k++) {
            lineSeriesList[k].width = 1
            switch(lineSeriesList[k].name) {
            case "ACT_RMSPN1":
                lineSeriesList[k].color = GC.colorUL1;
                break;
            case "ACT_RMSPN2":
                lineSeriesList[k].color = GC.colorUL2;
                break;
            case "ACT_RMSPN3":
                lineSeriesList[k].color = GC.colorUL3;
                break;
            case "ACT_RMSPN4":
                lineSeriesList[k].color = GC.colorIL1;
                break;
            case "ACT_RMSPN5":
                lineSeriesList[k].color = GC.colorIL2;
                break;
            case "ACT_RMSPN6":
                lineSeriesList[k].color = GC.colorIL3;
                break;
            case "ACT_DC7":
                lineSeriesList[k].color = GC.colorUAux1;
                break;
            case "ACT_DC8":
                lineSeriesList[k].color = GC.colorIAux1;
                break;
            case "ACT_PQS1":
                if(SessionState.emobSession && SessionState.dcSession)
                    lineSeriesList[k].color = GC.colorUAux1;
                else
                    lineSeriesList[k].color = GC.colorUL1;
                break;
            case "ACT_PQS2":
                lineSeriesList[k].color = GC.colorUL2;
                break;
            case "ACT_PQS3":
                lineSeriesList[k].color = GC.colorUL3;
                break;
            }
        }
    }

    function loadData() {
        let lineSeriesList = []
        lineSeriesList = createLineSeries()
        setColors(lineSeriesList)

        var timestamps = Object.keys(jsonData).sort()
        for (var i = 0; i < timestamps.length; i++) {
            var timestamp = timestamps[i]
            var time = jsonHelper.convertTimestampToMs(timestamp)
            var components = jsonHelper.getComponents(jsonData, time)
            for(var v = 0 ; v <components.length; v++) {
                if(components[v].includes("ACT_RMSPN1") || components[v].includes("ACT_RMSPN2") || components[v].includes("ACT_RMSPN3") || components[v].includes("ACT_DC7")) {
                    for(var k = 0; k < lineSeriesList.length; k++) {
                        if(lineSeriesList[k].name === components[v]) {
                            let value = jsonHelper.getValue(jsonData, time, components[v])
                            lineSeriesList[k].append(time, value)
                            lineSeriesList[k].axisY = axisYLeft
                            setMinMax(lineSeriesList[k], axisYLeft)
                        }
                    }
                }
                if(components[v].includes("ACT_RMSPN4") || components[v].includes("ACT_RMSPN5") || components[v].includes("ACT_RMSPN6") || components[v].includes("ACT_DC8")) {
                    for(var k = 0; k < lineSeriesList.length; k++) {
                        if(lineSeriesList[k].name === components[v]) {
                            let value = jsonHelper.getValue(jsonData, time, components[v])
                            lineSeriesList[k].append(time, value)
                            lineSeriesList[k].axisYRight = axisYRight
                            setMinMax(lineSeriesList[k], lineSeriesList[k].axisYRight) //axisYRight
                        }
                    }
                }
                if(components[v].includes("ACT_PQS1") || components[v].includes("ACT_PQS2") || components[v].includes("ACT_PQS3")) {
                    for(var k = 0; k < lineSeriesList.length; k++) {
                        if(lineSeriesList[k].name === components[v]) {
                            let value = jsonHelper.getValue(jsonData, time, components[v])
                            lineSeriesList[k].append(time, value)
                            //lineSeriesList[k].width = 1
                            lineSeriesList[k].axisY = axisYPower
                            setMinMax(lineSeriesList[k], axisYPower) //lineSeriesList[k].axisY
                        }
                    }
                }
            }
        }
    }

    function setMinMax(LineSeries, axisY) {
        var timeArray = []
        var actDataArray = []
        for (var l = 0; l < LineSeries.count; l++) {
            timeArray.push(LineSeries.at(l).x)
            actDataArray.push(LineSeries.at(l).y)
        }
        var minValue = Math.min(...actDataArray)
        var maxValue = Math.max(...actDataArray)
        minValue = Math.floor(minValue/ 10) * 10
        maxValue = Math.ceil(maxValue/ 10) * 10

        axisY.min = minValue
        axisY.max = maxValue

        var maxTimeValue = Math.max(...timeArray)
        axisXPower.max = new Date(maxTimeValue)
        axisX.max = new Date(maxTimeValue)
        if(timerHasTriggered === true){
            var minTimeValue = maxTimeValue - 10000
            axisX.min = new Date(minTimeValue)
            axisXPower.min = new Date(minTimeValue)
        }
        else {
            minTimeValue = Math.min(...timeArray)
            axisX.min = new Date(minTimeValue)
            axisXPower.min = new Date(minTimeValue)
        }
    }

    JsonHelper {
        id: jsonHelper
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        contentHeight: chartView.height + chartViewPower.height
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
                    chartView.width = root.graphWidth
                    chartViewPower.height = root.graphHeight / 2
                    chartViewPower.width = root.graphWidth
                } else if (pinchScale < 1.0) {
                    chartView.height = root.graphHeight / 4
                    chartView.width = root.graphWidth * 1.08
                    chartViewPower.height = root.graphHeight / 4
                    chartViewPower.width = root.graphWidth * 1.08
                }
            }
        }
        Item {}

        ChartView {
            id: chartView
            height: root.graphHeight /4
            width: root.graphWidth * 1.08
            anchors.horizontalCenter: parent.horizontalCenter
            antialiasing: true
            theme: ChartView.ChartThemeDark
            legend.visible: false
            //animationOptions: ChartView.SeriesAnimations

            ValueAxis {
                id: axisYLeft
                color: GC.colorUAux1
                labelsColor: GC.colorUAux1
                titleText: "U"
                labelsFont.pixelSize: height * 0.03
                labelFormat: "%d"
            }
            ValueAxis {
                id: axisYRight
                color: GC.colorIAux1
                labelsColor: GC.colorIAux1
                titleText: "I"
                labelsFont.pixelSize: height * 0.03
                labelFormat: "%d"
            }
            DateTimeAxis {
                id: axisX
                format: "hh:mm:ss"
            }

            LineSeries {
                id: lineSeriesU
                axisX: axisX
                axisY: axisYLeft
                color: GC.colorUAux1
            }
            LineSeries {
                id: lineSeriesI
                axisXTop: axisX
                axisYRight: axisYRight
                color: GC.colorIAux1
            }

            MouseArea {
                id: mA
                anchors.fill: parent
                drag.target: dragTarget
                drag.axis: Drag.XAxis
                property bool chartNotZoomed: true
                onDoubleClicked: {
                    if(chartNotZoomed) {
                        var zoomFactor = 2
                        var center_x = mouse.x
                        var center_y = mouse.y
                        var width_zoom = width/ zoomFactor;
                        var height_zoom = height/ zoomFactor;
                        var rect = Qt.rect(center_x-width_zoom/2, center_y - height_zoom/2, width_zoom, height_zoom)
                        chartView.zoomIn(rect)
                        chartNotZoomed = false
                        mA.drag.axis = Drag.XAndYAxis
                    }
                    else {
                        chartView.zoomReset();
                        chartNotZoomed = true
                        mA.drag.axis = Drag.XAxis
                    }
                }

                Item {
                   id: dragTarget
                   property real oldX : x
                   property real oldY : y
                   onXChanged: {
                       chartView.scrollLeft( x - oldX );
                       oldX = x;
                    }
                   onYChanged: {
                       chartView.scrollUp( y - oldY );
                       oldY = y;
                    }
                }
            }
        }
        ChartView {
            id: chartViewPower
            height: root.graphHeight /4
            width: root.graphWidth * 1.08
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: chartView.bottom
            antialiasing: true
            theme: ChartView.ChartThemeDark
            legend.visible: false

            ValueAxis {
                id: axisYPower
                color: GC.colorUAux1
                labelsColor: GC.colorUAux1
                titleText: "P"
                labelsFont.pixelSize: height * 0.03
                labelFormat: "%d"
            }
            DateTimeAxis {
                id: axisXPower
                format: "hh:mm:ss"
            }
            LineSeries {
                id: lineSeriesP
                axisX: axisXPower
                axisY: axisYPower
                color: GC.colorUAux1
            }

            MouseArea {
                id: mAPower
                anchors.fill: parent
                drag.target: dragTargetPower
                drag.axis: Drag.XAxis
                property bool chartNotZoomed: true
                onDoubleClicked: {
                    if(chartNotZoomed) {
                        var zoomFactor = 2
                        var center_x = mouse.x
                        var center_y = mouse.y
                        var width_zoom = width/ zoomFactor;
                        var height_zoom = height/ zoomFactor;
                        var rect = Qt.rect(center_x-width_zoom/2, center_y - height_zoom/2, width_zoom, height_zoom)
                        chartViewPower.zoomIn(rect)
                        chartNotZoomed = false
                        mAPower.drag.axis = Drag.XAndYAxis
                    }
                    else {
                        chartViewPower.zoomReset();
                        chartNotZoomed = true
                        mAPower.drag.axis = Drag.XAxis
                    }
                }

                Item {
                   id: dragTargetPower
                   property real oldX : x
                   property real oldY : y
                   onXChanged: {
                       chartViewPower.scrollLeft( x - oldX );
                       oldX = x;
                    }
                   onYChanged: {
                       chartViewPower.scrollUp( y - oldY );
                       oldY = y;
                    }
                }
            }
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: {
            timerHasTriggered = true
        }
    }
}
