import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import DeclarativeJson 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import "../controls"
import "../controls/settings"

BaseTabPage {
    id: root

    // TabButton - multi instance
    Component {
        id: tabSource
        TabButton {
            property var jsonSourceParamInfo
            text: jsonSourceParamInfo.Name
        }
    }
    // Page - multi instance
    Component {
        id: pageSource
        SourceModulePage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_SOURCE_CONTROL
                }
            }
        }
    }

    readonly property QtObject sourceModule: VeinEntity.getEntity("SourceModule1")
    // Per slot JSON watcher
    Component {
        id: jsonSlotWatcherComponent
        Item {
            id: jsonSlotWatcher
            property int slotNo // param for createObject

            // Each source device has 3 JSON components we watch:
            // 1. JSON component: Param / device info
            property var jsonParamInfo: sourceModule[String("ACT_DeviceInfo%1").arg(slotNo)]
            property bool jsonParamInfoLoaded: false
            onJsonParamInfoChanged: {
                if(Object.keys(jsonParamInfo).length) {
                    extendJsonParamInfo()
                    jsonParamInfoLoaded = true
                } else {
                    jsonParamInfoLoaded = false
                }
                checkCreateDestroy()
            }
            function extendJsonParamInfo() {
                // default(s) for mandatory value(s)
                jsonParamInfo['extraLinesRequired'] = false

                // * U/I/global harmonic support -> extraLinesRequired
                // Note: using array's forEach and arrow function causes qt-creator
                // freaking out on indentation. So loop the old-school way
                let arrUI = ['U', 'I']
                for(let numUI=0; numUI<arrUI.length; ++numUI) {
                    let strUI = arrUI[numUI]
                    let maxPhaseNum = jsonParamInfo[strUI + 'PhaseMax']
                    for(var phase=1; phase<=maxPhaseNum; ++phase) {
                        let phaseName = strUI + String(phase)
                        if(jsonParamInfo[phaseName]) {
                            if(jsonParamInfo[phaseName].supportsHarmonics) {
                                jsonParamInfo['extraLinesRequired'] = true
                                jsonParamInfo['supportsHarmonics'+strUI] = true
                            }
                        }
                    }
                }
                // * generate columInfo as an ordered array of
                // { 'phasenum': .. 'phaseNameDisplay': .., 'colorIndexU': .., 'colorIndexI': .. }
                let columInfo = []
                let maxPhaseAll = Math.max(jsonParamInfo['UPhaseMax'],
                                           jsonParamInfo['IPhaseMax'])
                jsonParamInfo['maxPhaseAll'] = maxPhaseAll
                for(phase=1; phase<=maxPhaseAll; ++phase) {
                    let phaseRequired = jsonParamInfo['U'+String(phase)] !== undefined || jsonParamInfo['I'+String(phase)] !== undefined
                    if(phaseRequired) {
                        let phaseNameDisplay = 'L' + String(phase)
                        let colorIndexU = phase-1
                        let colorIndexI = phase-1 + 3
                        if(phase > 3) {
                            colorIndexU = 6 // zero based
                            colorIndexI = 7
                            if(maxPhaseAll > 4) {
                                phaseNameDisplay = 'AUX' + String(phase-maxPhaseAll)
                            } else {
                                phaseNameDisplay = 'AUX'
                            }
                        }
                        columInfo.push({'phaseNum': phase,
                                           'phaseNameDisplay': phaseNameDisplay,
                                           'colorIndexU': colorIndexU,
                                           'colorIndexI': colorIndexI})
                    }
                }
                jsonParamInfo['columnInfo'] = columInfo
            }
            // 2. JSON component: Param data
            Component {
                id: declarativeJsonItemComponent
                DeclarativeJsonItem {
                    // this is magic: Feels like JSON but declarative (property binding possible)
                    id: declarativeJsonItem
                }
            }
            property QtObject declarativeJsonItem: null
            property var jsonParams: sourceModule[String("PAR_SourceState%1").arg(slotNo)]
            property bool jsonParamsLoaded: false
            onJsonParamsChanged: {
                if(Object.keys(jsonParams).length) {
                    // DeclarativeJsonItem cannot delete JSON objects once
                    // created (e.g slot had U/I source and now gets an I-only
                    // source)
                    // => we must create/delete DeclarativeJsonItem explicitly
                    if(!declarativeJsonItem) {
                        declarativeJsonItem = declarativeJsonItemComponent.createObject(tabBar, {})
                    }
                    declarativeJsonItem.fromJson(jsonParams)
                    jsonParamsLoaded = true
                    checkCreateDestroy()
                }
                else {
                    jsonParamsLoaded = false
                    checkCreateDestroy()
                    declarativeJsonItem = null // = delete
                }
            }
            // 3. JSON component: Source state
            property var jsonState: sourceModule[String("ACT_DeviceState%1").arg(slotNo)]
            property bool jsonStateLoaded: false
            onJsonStateChanged: {
                jsonStateLoaded = Object.keys(jsonState).length
                checkCreateDestroy()
            }
            function checkCreateDestroy() {
                jsonSlotWatcherComponents[slotNo] = jsonSlotWatcher // allow external access into component
                createOrDestroyTab(slotNo, jsonParamInfoLoaded && jsonParamsLoaded && jsonStateLoaded)
            }
        }
    }
    property var jsonSlotWatcherComponents: []
    readonly property int maxCountSources: sourceModule.ACT_MaxSources
    onMaxCountSourcesChanged: { // create slot watcher array
        for(let slotNo=0; slotNo<maxCountSources; slotNo++) {
            jsonSlotWatcherComponent.createObject(tabBar, {"slotNo" : slotNo})
        }
    }

    function createOrDestroyTab(slotNo, create) {
        console.info("createOrDestroyTab:", slotNo, create)
        if(create) {
            console.info(jsonSlotWatcherComponents[slotNo].jsonParamInfo.Name)
        }
    }


    // create tabs/pages dynamic
    readonly property int countAvtiveSources: sourceModule.ACT_CountSources
    property var lastSlotItemsTab: []
    property var lastSlotItemsPage: []
    onCountAvtiveSourcesChanged: {
        for(let sourceNum=0; sourceNum<maxCountSources; ++sourceNum) {
            // prefill object keeper on 1st call
            while(lastSlotItemsTab.length <= sourceNum) {
                lastSlotItemsTab.push(undefined)
                lastSlotItemsPage.push(undefined)
            }
            let infoComponentName = String("ACT_DeviceInfo%1").arg(sourceNum)
            let jsonDeviceInfo = sourceModule[infoComponentName]
            let slotIsOn = jsonDeviceInfo.UPhaseMax !== undefined && jsonDeviceInfo.IPhaseMax !== undefined
            let paramComponentName = String("PAR_SourceState%1").arg(sourceNum)
            let stateComponentName = String("ACT_DeviceState%1").arg(sourceNum)
            // create?
            if(slotIsOn && lastSlotItemsTab[sourceNum] === undefined) {
                lastSlotItemsTab[sourceNum] = tabSource.createObject(tabBar, {"jsonSourceParamInfo" : jsonDeviceInfo})
                tabBar.addItem(lastSlotItemsTab[sourceNum])

                lastSlotItemsPage[sourceNum] = pageSource.createObject(swipeView, {
                                                                           "paramComponentName" : paramComponentName,
                                                                           "stateComponentName" : stateComponentName,
                                                                           "jsonSourceParamInfoRaw" : jsonDeviceInfo})
                swipeView.addItem(lastSlotItemsPage[sourceNum])
            }
            // destroy?
            else if(!slotIsOn && lastSlotItemsTab[sourceNum] !== undefined) {
                tabBar.removeItem(lastSlotItemsTab[sourceNum])
                lastSlotItemsTab[sourceNum] = undefined

                swipeView.removeItem(lastSlotItemsPage[sourceNum])
                lastSlotItemsPage[sourceNum] = undefined
            }
        }
    }
    Component.onCompleted: {
        finishInit()
    }
}

