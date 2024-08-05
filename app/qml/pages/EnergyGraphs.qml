import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtCharts 2.0
import GlobalConfig 1.0

Item {
    id:  root
    property var graphHeight
    property var graphWidth
    property bool timerHasTriggered: false
    property var jsonData
    onJsonDataChanged:
        loadData()

    function loadData() {
        // Convert JSON data to arrays of points
        var actValU = []
        var actValI = []
        var actValP = []
        var timestamps = Object.keys(jsonData).sort()

        for (var i = 0; i < timestamps.length; i++) {
            var timestamp = timestamps[i]
            var data = jsonData[timestamp]
            var time = convertStrTimestampToMsecsSinceEpoch(timestamp)

            for (var entity in data) {
                var values = Object.keys(data[entity])
                if(values.includes("ACT_RMSPN1")) {
                    actValU.push({x: time, y: data[entity]["ACT_RMSPN1"]})
                }
                if(values.includes("ACT_RMSPN2")) {
                    actValI.push({x: time, y: data[entity]["ACT_RMSPN2"]})
                }
                if(values.includes("ACT_PQS4")) {
                    actValP.push({x: time, y: data[entity]["ACT_PQS4"]})
                }
            }
        }

        // append points to splineSeries
        lineSeriesU.clear()
        for (var l = 0; l < actValU.length; l++) {
            lineSeriesU.append(actValU[l].x, actValU[l].y)
            setAxisMinMax(actValU, lineSeriesU, axisYLeft)
        }

        lineSeriesI.clear()
        for (var l = 0; l < actValI.length; l++) {
            lineSeriesI.append(actValI[l].x, actValI[l].y)
            setAxisMinMax(actValI, lineSeriesI, axisYRight)
        }

        lineSeriesP.clear()
        for (var l = 0; l < actValP.length; l++) {
            lineSeriesP.append(actValP[l].x, actValP[l].y)
            setAxisMinMax(actValP, lineSeriesP, axisYPower)
        }
    }

    function setAxisMinMax(actData, lineSeries, axisY) {
        var timeArray = []
        var actDataArray = []
        for (var l = 0; l < actData.length; l++) {
            timeArray.push(actData[l].x)
            actDataArray.push(actData[l].y)
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

    function convertStrTimestampToMsecsSinceEpoch(strTimestamp) {
        var parts = strTimestamp.split(" ");
        var dateParts = parts[0].split("-");
        var timeParts = parts[1].split(":");
        var splitMs = timeParts[2].split(".");
        var milliseconds = splitMs[1]
        timeParts[2] = parseInt(timeParts[2]);
        var date = new Date(dateParts[2], dateParts[1] - 1, dateParts[0], timeParts[0], timeParts[1], timeParts[2], milliseconds);
        return date.getTime();
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
