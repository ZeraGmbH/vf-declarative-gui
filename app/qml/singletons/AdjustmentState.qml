pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraTranslation 1.0

Item {
    readonly property bool adjusted: privProps.adjustmentValue === 0
    readonly property string adjustmentStatusDescription : {
        var strStatus = "OK"
        if(!adjusted) {
            strStatus = ""
            // see mt310s2d/com5003d / adjustment.h for flags definition
            if(privProps.adjustmentValue & (1<<0))
                strStatus += Z.tr("Not adjusted")
            if(privProps.adjustmentValue & (1<<1)) {
                if(strStatus !== "")
                    strStatus += " / "
                strStatus += Z.tr("Wrong version")
            }
            if(privProps.adjustmentValue & (1<<2)) {
                if(strStatus !== "")
                    strStatus += " / "
                strStatus += Z.tr("Wrong serial number")
            }
        }
        return strStatus;
    }
    QtObject {
        id: privProps
        // INF_Adjusted is a bitmask - see adjustmentStatusDescription / 0 is OK
        readonly property int adjustmentValue: parseInt(GC.entityInitializationDone ? VeinEntity.getEntity("StatusModule1").INF_Adjusted : "1")
    }
}
