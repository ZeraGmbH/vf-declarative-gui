pragma Singleton
import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import SessionState 1.0
import VfRecorderJsonHelper 1.0
import Vf_Recorder 1.0


Item {
    property bool timerHasTriggered: false
    property var maxXValue

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

    function calculateTimeDiffSecs(timestamp) {
        var firstTimestamp = jsonHelper.convertTimestampToMs(Vf_Recorder.firstTimestamp0)
        var timeMs = jsonHelper.convertTimestampToMs(timestamp)
        var timeDiffSecs = (timeMs - firstTimestamp)/1000
        return timeDiffSecs
    }

    VfRecorderJsonHelper {
        id : jsonHelper
    }
}
