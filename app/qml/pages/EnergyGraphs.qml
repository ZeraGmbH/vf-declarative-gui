import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtCharts 2.0
import VeinEntity 1.0


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
        var lastElt = actValU[actValU.length - 1]
        if(lastElt !== undefined) {
            lineSeriesU.append(lastElt.x, lastElt.y)
            setAxisMinMax(actValU, lineSeriesU, axisYLeft)
        }

        lastElt = actValI[actValI.length - 1]
        if(lastElt !== undefined) {
            lineSeriesI.append(lastElt.x, lastElt.y)
            setAxisMinMax(actValI, lineSeriesI, axisYRight)
        }

        lastElt = actValP[actValP.length - 1]
        if(lastElt !== undefined) {
            lineSeriesP.append(lastElt.x, lastElt.y)
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
        contentHeight: chartView.height + chartViewPower.height
        flickableDirection: Flickable.VerticalFlick
        clip: true
        ScrollBar.vertical: ScrollBar {
            width: 8
            policy : flickable.height >= chartView.height + chartViewPower.height ?  ScrollBar.AlwaysOff : ScrollBar.AlwaysOn
        }

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
                color: "gold"
                labelsColor: "gold"
                titleText: "U"
                labelsFont.pixelSize: height * 0.03
                labelFormat: "%d"
            }
            ValueAxis {
                id: axisYRight
                color: "green"
                labelsColor: "green"
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
                color: "gold"
            }
            LineSeries {
                id: lineSeriesI
                axisXTop: axisX
                axisYRight: axisYRight
                color: "green"
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
                color: "dodgerblue"
                labelsColor: "dodgerblue"
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
                color: "dodgerblue"
            }
        }
    }

    PinchArea {
        id: pinchArea
        anchors.fill: root
        onPinchUpdated: {
            let pinchScale = pinch.scale * pinch.previousScale
            if(pinchScale > 1.0) {
                chartView.height = root.graphHeight /2
                chartView.width = root.graphWidth
                chartViewPower.height = root.graphHeight / 2
                chartViewPower.width = root.graphWidth
            }
            else if (pinchScale < 1.0) {
                chartView.height = root.graphHeight / 4
                chartView.width = root.graphWidth * 1.08
                chartViewPower.height = root.graphHeight / 4
                chartViewPower.width = root.graphWidth * 1.08
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
