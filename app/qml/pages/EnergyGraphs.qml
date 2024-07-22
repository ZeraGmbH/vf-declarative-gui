import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtCharts 2.15
import VeinEntity 1.0

Item {
    id:  root
    property int timeStep: 0
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
            setAxisMinMax(actValU, lineSeriesU)
        }

        lastElt = actValI[actValI.length - 1]
        if(lastElt !== undefined) {
            lineSeriesI.append(lastElt.x, lastElt.y)
            setAxisMinMax(actValI, lineSeriesI)
        }

        lastElt = actValP[actValP.length - 1]
        if(lastElt !== undefined) {
            lineSeriesP.append(lastElt.x, lastElt.y)
            setAxisMinMax(actValP, lineSeriesP)
        }
    }

    function setAxisMinMax(actData, lineSeries) {
        var timeArray = []
        var actDataArray = []
        for (var l = 0; l < actData.length; l++) {
            timeArray.push(actData[l].x)
            actDataArray.push(actData[l].y)
        }
        var maxTimeValue = Math.max(...timeArray)
        lineSeries.axisX.max = new Date(maxTimeValue)

        var minValue = Math.min(...actDataArray)
        var maxValue = Math.max(...actDataArray)
        lineSeries.axisY.min = minValue
        lineSeries.axisY.max = maxValue

        if(timerHasTriggered === true) {
            timeStep++;
        }
        if(timeStep > 10){
            increaseXaxisTimeScale(lineSeries)
        }
        else {
            var minTimeValue = Math.min(...timeArray)
            lineSeries.axisX.min = new Date(minTimeValue)
        }
    }

    function increaseXaxisTimeScale(lineSeries) {
        var maxTimeValue = lineSeries.axisX.max
        var minTimeValue = lineSeries.axisX.min
        minTimeValue = maxTimeValue - 10000
        lineSeries.axisX.min = new Date(minTimeValue)
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
        Layout.fillHeight: true
        Layout.fillWidth: true
        anchors.fill: parent
        antialiasing: true
        theme: ChartView.ChartThemeDark
        //animationOptions: ChartView.SeriesAnimations

        LineSeries {
            id: lineSeriesU
            name: "U"
            color: "dodgerblue"
            axisX: DateTimeAxis {
                format: "hh:mm:ss"
            }
            axisY: ValueAxis {
                color: "dodgerblue"
                labelsColor: "dodgerblue"
                minorGridVisible: false
            }
        }

        LineSeries {
            id: lineSeriesI
            name: "I"
            color: "green"
            axisX: DateTimeAxis {
                format: "hh:mm:ss"
                labelsVisible: false
                lineVisible: false
            }
            axisY: ValueAxis {
                color: "green"
                labelsColor: "green"
            }
        }
        LineSeries {
            id: lineSeriesP
            name: "P"
            color: "firebrick"
            axisX: DateTimeAxis {
                format: "hh:mm:ss"
                labelsVisible: false
                lineVisible: false
            }
            axisY: ValueAxis {
                color: "firebrick"
                labelsColor: "firebrick"
            }
        }

        Rectangle {
            id: horizontalScrollMask
            width: 50
            height: 20
            visible: true
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton

            onMouseXChanged: {
                if ((mouse.buttons & Qt.LeftButton) == Qt.LeftButton) {
                    chartView.scrollLeft(mouseX - horizontalScrollMask.x);
                    horizontalScrollMask.x = mouseX;
                }
            }
            onPressed: {
                if (mouse.button == Qt.LeftButton) {
                    horizontalScrollMask.x = mouseX;
                }
            }
        }
    }

    Timer {
        id:mytimer1
        interval: 10000
        repeat: true
        running: true
        onTriggered: {
            timerHasTriggered = true
        }
    }
}
