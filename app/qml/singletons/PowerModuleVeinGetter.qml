pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import ModuleIntrospection 1.0

// Note: in here we are zero based
Item {
    // This is a hack: We put deep knowledge of how power/sec modules are
    // configured!!! There must be better ways of doing this...
    function getPowerModuleNoFromDisplayedName(name) {
        switch(name) {
        case "P":
        case "P AC":
        case "P 1":
            return 0
        case "Q":
        case "P 2":
            return 1
        case "S":
        case "P 3":
            return 2
        case "P DC":
        case "P AUX":
            return 3
        }
        // fallback
        return 0
    }
    function getPowerModuleEntity(powerModuleNo) {
        let retVal;
        switch(powerModuleNo) {
        case 0:
            retVal = VeinEntity.getEntity("POWER1Module1")
            break;
        case 1:
            retVal = VeinEntity.getEntity("POWER1Module2")
            break;
        case 2:
            retVal = VeinEntity.getEntity("POWER1Module3")
            break;
        case 3:
            retVal = VeinEntity.getEntity("POWER1Module4")
            break;
        }
        return retVal;
    }

    // INF_ModuleInterface
    function getEntityJsonInfo(powerModuleNo) {
        let retVal;
        switch(powerModuleNo) {
        case 0:
            retVal = ModuleIntrospection.p1m1Introspection;
            break;
        case 1:
            retVal = ModuleIntrospection.p1m2Introspection;
            break;
        case 2:
            retVal = ModuleIntrospection.p1m3Introspection;
            break;
        case 3:
            retVal = ModuleIntrospection.p1m4Introspection;
            break;
        }
        return retVal
    }

}
