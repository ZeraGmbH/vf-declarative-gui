import QtQuick 2.14
import GlobalConfig 1.0
import VeinEntity 1.0

Item {
    readonly property bool hasSEC1: GC.entityInitializationDone && VeinEntity.hasEntity("SEC1Module1")
    readonly property bool hasSEC1_2: GC.entityInitializationDone && VeinEntity.hasEntity("SEC1Module2")
    readonly property bool hasSEM1: GC.entityInitializationDone && VeinEntity.hasEntity("SEM1Module1")
    readonly property bool hasSPM1: GC.entityInitializationDone && VeinEntity.hasEntity("SPM1Module1")

    readonly property var sec1mod1Entity: hasSEC1 ? VeinEntity.getEntity("SEC1Module1") : null
    readonly property var sec1mod2Entity: hasSEC1_2 ? VeinEntity.getEntity("SEC1Module2") : null
    readonly property var sem1mod1Entity: hasSEM1 ? VeinEntity.getEntity("SEM1Module1") : null
    readonly property var spm1mod1Entity: hasSPM1 ? VeinEntity.getEntity("SPM1Module1") : null

    readonly property var sec1mod1Running: hasSEC1 && sec1mod1Entity.PAR_StartStop === 1
    readonly property var sec1mod2Running: hasSEC1_2 && sec1mod2Entity.PAR_StartStop === 1
    readonly property var sem1mod1Running: hasSEM1 && sem1mod1Entity.PAR_StartStop === 1
    readonly property var spm1mod1Running: hasSPM1 && spm1mod1Entity.PAR_StartStop === 1

    property bool oneOrMoreRunning: sec1mod1Running || sec1mod2Running || sem1mod1Running || spm1mod1Running

    readonly property int aborted: (1<<3)

    function comparisonProgress(entity, show) {
        let ret = ""
        if(show) {
            let progress = parseInt(entity.ACT_Progress)
            let measCount = entity.PAR_MeasCount
            let continuous = entity.PAR_Continuous === 1
            if(measCount > 1 || continuous) {
                let measNum = entity.ACT_MeasNum + 1
                if(continuous) {
                    ret = ` ${progress}% (${measNum})`
                }
                else {
                    ret = ` ${progress}% (${measNum}/${measCount})`
                }
            }
            else {
                ret = ` ${progress}%`
            }
        }
        return ret
    }
    function registerProgress(entity, show) {
        let ret = ""
        if(show) {
            let progress = parseInt(entity.ACT_Time / entity.PAR_MeasTime * 100)
            ret = ` ${progress}%`
        }
        return ret
    }
    function comparisonPass(entity) {
        let pass = false
        let evalDone = false
        if(entity.hasComponent('ACT_MulResult')) {
            let jsonResults = JSON.parse(entity.ACT_MulResult)
            if(jsonResults.values.length > 1) {
                pass = jsonResults.countPass === jsonResults.values.length
                evalDone = true
            }
        }
        if(!evalDone)
            pass = entity.ACT_Rating !== 0
        return pass
    }
    function registerPass(entity, running) {
        let pass = false
        let abortFlag = (1<<3)
        let aborted = entity.ACT_Status & root.aborted
        pass = entity.ACT_Rating !== 0 || running || aborted
        return pass
    }
}
