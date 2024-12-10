pragma Singleton
import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import SessionState 1.0
import VfRecorderJsonHelper 1.0
import Vf_Recorder 1.0


Item {
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
