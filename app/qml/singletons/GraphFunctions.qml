pragma Singleton
import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import SessionState 1.0
import JsonHelper 1.0
import Vf_Recorder 1.0


Item {
    property var lineSeriesList: []
    property bool timerHasTriggered: false
    property var maxXValue

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

    function setXaxisMinMax(axisX, axisXPower, timeDiffSecs) {
        axisX.max = timeDiffSecs
        if(timeDiffSecs > 10)
            axisX.min = timeDiffSecs - 10
        else
            axisX.min = 0
        axisXPower.max = axisX.max
        axisXPower.min = axisX.min
        maxXValue = axisX.max
    }

    function setYaxisMinMax(axisY, minValue, maxValue) {
        if(axisY.min === 0 || axisY.min > minValue) //0 is the default min value
            axisY.min = minValue
        if(axisY.max < maxValue)
            axisY.max = maxValue
    }

    function appendPointToSerie(serie, timeDiffSecs, value, axisY, axisYScaler) {
        if(serie !== null) {
            serie.append(timeDiffSecs, value)
            if(timeDiffSecs === 0)//first sample
                axisYScaler.reset(value, 0.0)
            axisYScaler.scaleToNewActualValue(value)
            setYaxisMinMax(axisY, axisYScaler.getRoundedMinValue(), axisYScaler.getRoundedMaxValue())
        }
    }

    function calculateTimeDiffSecs(timestamp) {
        var firstTimestamp = jsonHelper.convertTimestampToMs(Vf_Recorder.firstTimestamp0)
        var timeMs = jsonHelper.convertTimestampToMs(timestamp)
        var timeDiffSecs = (timeMs - firstTimestamp)/1000
        return timeDiffSecs
    }

    function prepareCharts() {
        for(let i = 0; i < lineSeriesList.length; i++ )
            lineSeriesList[i].clear()
    }

    JsonHelper {
        id : jsonHelper
    }
}
