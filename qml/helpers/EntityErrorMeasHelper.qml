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
}
