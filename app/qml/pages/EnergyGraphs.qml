import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtCharts 2.15
import VeinEntity 1.0

Item {
    id:  root
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

    ChartView {
        id: chartView
        height: root.height/2
        width: root.width * 1.09
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        antialiasing: true
        theme: ChartView.ChartThemeDark
        legend.visible: false
        //animationOptions: ChartView.SeriesAnimations

        ValueAxis {
            id: axisYLeft
            color: "dodgerblue"
            labelsColor: "dodgerblue"
            titleText: "U"
        }
        ValueAxis {
            id: axisYRight
            color: "green"
            labelsColor: "green"
            titleText: "I"
        }
        DateTimeAxis {
            id: axisX
            format: "hh:mm:ss"
        }

        LineSeries {
            id: lineSeriesU
            axisX: axisX
            axisY: axisYLeft
        }
        LineSeries {
            id: lineSeriesI
            axisXTop: axisX
            axisYRight: axisYRight
        }
    }

    ChartView {
        id: chartViewPower
        height: root.height/2
        width: root.width * 1.08
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.top: chartView.bottom
        antialiasing: true
        theme: ChartView.ChartThemeDark
        legend.visible: false

        ValueAxis {
            id: axisYPower
            color: "firebrick"
            labelsColor: "firebrick"
            titleText: "P"
        }
        DateTimeAxis {
            id: axisXPower
            format: "hh:mm:ss"
        }
        LineSeries {
            id: lineSeriesP
            axisX: axisXPower
            axisY: axisYPower
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
