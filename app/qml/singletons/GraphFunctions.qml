pragma Singleton
import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import SessionState 1.0
import JsonHelper 1.0


Item {
    property var lineSeriesList: []

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

    function setMinMax(LineSeries, axisY,axisX, axisXPower, timerHasTriggered) {
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
        axisXPower.max = new Date(maxTimeValue)
        axisX.max = new Date(maxTimeValue)
        if(timerHasTriggered === true){
            var minTimeValue = maxTimeValue - 10000
            axisX.min = new Date(minTimeValue)
            axisXPower.min = new Date(minTimeValue)
        }
        else {
            minTimeValue = Math.min(...timeArray)
            if(maxTimeValue === minTimeValue) {
                minTimeValue = minTimeValue - 10000
            }
            axisX.min = new Date(minTimeValue)
            axisXPower.min = new Date(minTimeValue)
        }
    }

    function appendLastElemt(actVal, compoName, jsonData, axisY, axisX, axisXPower, timerHasTriggered) {
        var lastEltTime = jsonHelper.findLastElementOfCompo(actVal, compoName)
        if(lastEltTime !== "0") {
            for(var k = 0; k < lineSeriesList.length; k++) {
                if(lineSeriesList[k].name === compoName) {
                    let value = jsonHelper.getValue(jsonData, lastEltTime, compoName)
                    lineSeriesList[k].append(lastEltTime, value)
                    setMinMax(lineSeriesList[k], axisY, axisX, axisXPower, timerHasTriggered)
                }
            }
        }
    }

    JsonHelper {
        id : jsonHelper
    }
}