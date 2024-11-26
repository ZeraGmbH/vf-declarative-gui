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
    readonly property int xAxisTimeSpanSecs: 8

    function getChannelColor(componentName) {
        let color = "white"
        switch(componentName) {
        case "ACT_RMSPN1":
            color = GC.colorUL1;
            break;
        case "ACT_RMSPN2":
            color = GC.colorUL2;
            break;
        case "ACT_RMSPN3":
            color = GC.colorUL3;
            break;
        case "ACT_RMSPN4":
            color = GC.colorIL1;
            break;
        case "ACT_RMSPN5":
            color = GC.colorIL2;
            break;
        case "ACT_RMSPN6":
            color = GC.colorIL3;
            break;
        case "ACT_DC7":
            color = GC.colorUAux1;
            break;
        case "ACT_DC8":
            color = GC.colorIAux1;
            break;
        case "ACT_PQS1":
            if(SessionState.emobSession && SessionState.dcSession)
                color = GC.colorUAux1;
            else
                color = GC.colorUL1;
            break;
        case "ACT_PQS2":
            color = GC.colorUL2;
            break;
        case "ACT_PQS3":
            color = GC.colorUL3;
            break;
        case "ACT_PQS4":
            color = "white";
            break;
        }
        return color
    }

    function setXaxisMinMax(axisX, timeDiffSecs) {
        axisX.max = timeDiffSecs
        if(timeDiffSecs > xAxisTimeSpanSecs)
            axisX.min = timeDiffSecs - xAxisTimeSpanSecs
        else
            axisX.min = 0
    }

    function setYaxisMinMax(axisY, minValue, maxValue) {
        if(axisY.min === 0 || axisY.min > minValue) //0 is the default min value
            axisY.min = minValue
        if(axisY.max < maxValue)
            axisY.max = maxValue
    }

    function appendPointToSerie(serie, timeDiffSecs, value, axisX, axisY, axisYScaler) {
        if(serie !== null) {
            serie.append(timeDiffSecs, value)
            if(timeDiffSecs === 0)//first sample
                axisYScaler.reset(value, 0.0)
            axisYScaler.scaleToNewActualValue(value)
            setXaxisMinMax(axisX, timeDiffSecs)
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
