pragma Singleton
import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import SessionState 1.0
import JsonHelper 1.0


Item {
    property var lineSeriesList: []
    property bool timerHasTriggered: false

    function setColors() {
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
            case "ACT_PQS4":
                lineSeriesList[k].color = "white";
                break;
            }
        }
    }

    function setMinMax(LineSeries, axisY,axisX, axisXPower) {
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

        if(axisY.min === 0 || axisY.min > minValue) //0 is the default min value
            axisY.min = minValue

        if(axisY.max < maxValue)
            axisY.max = maxValue

        var maxTimeValue = Math.max(...timeArray)
        axisXPower.max = maxTimeValue
        axisX.max = maxTimeValue
        if(timerHasTriggered === true){
            var minTimeValue = maxTimeValue - 10
            axisX.min = minTimeValue
            axisXPower.min = minTimeValue
        }
        else {
            axisX.min = 0
            axisXPower.min = 0
        }
    }

    function appendLastElemt(actVal, compoName, jsonData, axisY, axisX, axisXPower) {
        var timestamps = Object.keys(jsonData).sort()
        var firstTimestamp = jsonHelper.convertTimestampToMs(timestamps[0])
        var lastEltTime = jsonHelper.findLastElementOfCompo(actVal, compoName)
        var testTimeSecs = (lastEltTime - firstTimestamp)/1000
        if(lastEltTime !== "0") {
            for(var k = 0; k < lineSeriesList.length; k++) {
                if(lineSeriesList[k].name === compoName) {
                    let value = jsonHelper.getValue(jsonData, lastEltTime, compoName)
                    lineSeriesList[k].append(testTimeSecs , value)
                    setMinMax(lineSeriesList[k], axisY, axisX, axisXPower)
                }
            }
        }
    }

    function prepareCharts(timestamps) {
        if(timestamps.length <= 1) {
            for(let i = 0; i < lineSeriesList.length; i++ )
                lineSeriesList[i].clear()
            timer.restart()
            timerHasTriggered = false
        }
    }

    function appendIfNotDuplicated(series) {
        var appendSerie = true
        if(lineSeriesList.length === 0)
            appendSerie = true
        else {
            for(var index = 0; index < lineSeriesList.length; index++) {
                if(lineSeriesList[index].name === series.name) {
                    appendSerie = false
                    break;
                }
            }
        }
        if(appendSerie)
            lineSeriesList.push(series)
        lineSeriesList = [].concat.apply([], lineSeriesList)
    }

    JsonHelper {
        id : jsonHelper
    }

    Timer {
        id: timer
        interval: 10000
        repeat: true
        running: true
        onTriggered: {
            timerHasTriggered = true
        }
    }
}
