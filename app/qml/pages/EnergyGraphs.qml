import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtCharts 2.15
import VeinEntity 1.0

Item {
    id:  root
    property var jsonData
    onJsonDataChanged:
        loadData()

    function loadData() {
        // Convert JSON data to arrays of points
        var timeFormat = Qt.formatDateTime
        var actValI = []
        var actValU = []
        var actValP = []
        var timestamps = Object.keys(jsonData).sort()

        for (var i = 0; i < timestamps.length; i++) {
            var valuesSameTime = []
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
        for (var j = 0; j < actValU.length; j++) {
            lineSeriesU.append(actValU[j].x, actValU[j].y)
        }
        setAxisMinMax(actValU, lineSeriesU)

        for (var l = 0; l < actValI.length; l++) {
            lineSeriesI.append(actValI[l].x, actValI[l].y)
        }
        setAxisMinMax(actValI, lineSeriesI)

        for (var k = 0; k < actValP.length; k++) {
            lineSeriesP.append(actValP[k].x, actValP[k].y)
        }
        setAxisMinMax(actValP, lineSeriesP)
    }

    function setAxisMinMax(actData, lineSeries) {
        var timeArray = []
        var actDataArray = []
        if(actData.length !== 0) {
            for (var l = 0; l < actData.length; l++) {
                timeArray.push(actData[l].x)
                actDataArray.push(actData[l].y)
            }
            var minValue = Math.min(...timeArray)
            var maxValue = Math.max(...timeArray)
            lineSeries.axisX.min = new Date(minValue)
            lineSeries.axisX.max = new Date(maxValue)

            minValue = Math.min(...actDataArray)
            maxValue = Math.max(...actDataArray)
            lineSeries.axisY.min = minValue
            lineSeries.axisY.max = maxValue
            lineSeries.applyNiceNumbers()
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
        anchors.fill: parent
        antialiasing: true

        LineSeries {
            id: lineSeriesU
            name: "U"

            axisX: DateTimeAxis {
                format: "hh:mm:ss"
            }
            axisY: ValueAxis {
            }
        }
        LineSeries {
            id: lineSeriesI
            name: "I"

            axisX: DateTimeAxis {
                format: "hh:mm:ss"
                labelsVisible: false
                lineVisible: false
            }
            axisY: ValueAxis {
            }
        }
        LineSeries {
            id: lineSeriesP
            name: "P"

            axisX: DateTimeAxis {
                format: "hh:mm:ss"
                labelsVisible: false
                lineVisible: false
            }
            axisY: ValueAxis {
            }
        }
    }

}
