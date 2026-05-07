pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraTranslation 1.0

Item {
    readonly property bool adjusted: adjustmentValue === 0
    readonly property string adjustmentStatusBare : {
        if(adjusted)
            return "OK"
        let errors = bareErrors()
        return errors.join(" / ")
    }
    readonly property string adjustmentStatusDisplay : {
        if(adjusted)
            return "OK"
        let trErrors = []
        for(let error of bareErrors())
            trErrors.push("<font color='red'>" + Z.tr(error) + "</font>")
        return trErrors.join(" / ")
    }
    // INF_Adjusted is a bitmask - see adjustmentStatusBare / 0 is OK
    readonly property int adjustmentValue: parseInt(GC.entityInitializationDone ? VeinEntity.getEntity("StatusModule1").INF_Adjusted : "1")
    function bareErrors() {
        let errors = []
        // see mt310s2d/com5003d / adjustment.h for flags definition
        if(adjustmentValue & (1<<0))
            errors.push("Not adjusted")
        if(adjustmentValue & (1<<1))
            errors.push("Wrong version")
        if(adjustmentValue & (1<<2))
            errors.push("Wrong serial number")
        return errors
    }
}
