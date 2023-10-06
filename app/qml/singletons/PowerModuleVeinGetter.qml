pragma Singleton
import QtQuick 2.14
import VeinEntity 1.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0

// Note: in here we are zero based
Item {
    readonly property var powerModulesHandledInGUI: [
        "POWER1Module1",
        "POWER1Module2",
        "POWER1Module3",
        "POWER1Module4"
    ]
    readonly property var powerModuleEntitiesAvailable: {
        let avail = []
        if(GC.entityInitializationDone) {
            for(let i=0; i<powerModulesHandledInGUI.length; i++) {
                let moduleName = powerModulesHandledInGUI[i]
                if(VeinEntity.hasEntity(moduleName))
                    avail.push(moduleName)
            }
        }
        return avail
    }
    // INF_ModuleInterface
    readonly property var powerModuleIntrospectionInGUI: [
        ModuleIntrospection.p1m1Introspection,
        ModuleIntrospection.p1m2Introspection,
        ModuleIntrospection.p1m3Introspection,
        ModuleIntrospection.p1m4Introspection
    ]

    function getPowerModuleEntity(powerModuleNo) {
        let retVal
        let entityName = powerModulesHandledInGUI[powerModuleNo]
        if(powerModuleNo < powerModulesHandledInGUI.length && VeinEntity.hasEntity(entityName))
            retVal = VeinEntity.getEntity(entityName)
        return retVal
    }
    function getEntityJsonInfo(powerModuleNo) {
        let retVal
        if(powerModuleNo < powerModuleIntrospectionInGUI.length)
            retVal = powerModuleIntrospectionInGUI[powerModuleNo]
        return retVal
    }

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
}
