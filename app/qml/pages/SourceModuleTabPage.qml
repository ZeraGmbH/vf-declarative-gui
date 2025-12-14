import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import DeclarativeJson 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import ZeraThemeConfig 1.0
import "../controls"
import "../controls/settings"

BaseTabPage {
    id: root

    readonly property QtObject sourceEntity: VeinEntity.getEntity("SourceModule1")

    // kindof onCreate - maxCountSources will never change
    readonly property int maxCountSources: sourceEntity.ACT_MaxSources
    onMaxCountSourcesChanged: { // init all slot related data
        for(let slotNo=0; slotNo<maxCountSources; slotNo++) {
            jsonSlotWatcherComponent.createObject(tabBar, {"slotNo" : slotNo})
        }
    }

    // Per slot JSON watcher items:
    // * scan all JSON components to create & destroy active slot items
    // * live as long as BaseTabPage does
    Component {
        id: jsonSlotWatcherComponent
        Item {
            id: jsonSlotWatcher
            property int slotNo // param for createObject

            // Each source device has 3 JSON components we watch:
            // 1. JSON component: Param / device info
            property var jsonParamInfo: sourceEntity[String("ACT_DeviceInfo%1").arg(slotNo)]
            onJsonParamInfoChanged: { // data static => once only
                checkCreateSlotItem()
            }
            // 2. JSON component: Param data
            property var jsonParams: sourceEntity[String("PAR_SourceState%1").arg(slotNo)]
            onJsonParamsChanged: {
                checkCreateSlotItem()
            }
            // 3. JSON component: Source state
            property var jsonState: sourceEntity[String("ACT_DeviceState%1").arg(slotNo)]
            onJsonStateChanged: {
                checkCreateSlotItem()
            }
            property bool itemCreated: false
            function checkCreateSlotItem() {
                let allJsonValid =
                    Object.keys(jsonParamInfo).length != 0 &&
                    Object.keys(jsonParams).length != 0 &&
                    Object.keys(jsonState).length != 0
                if(!itemCreated && allJsonValid) {
                    createOrDestroyActiveSlotItem(true)
                    itemCreated = true
                }
                if(itemCreated && !allJsonValid) {
                    createOrDestroyActiveSlotItem(false)
                    itemCreated = false
                }
            }
            property var activeSlotItem
            function createOrDestroyActiveSlotItem(create) {
                if(create) {
                    activeSlotItem = activeSlotComponent.createObject(
                                    null, {
                                    "slotNo": slotNo})
                    activeSlotItem.createItems()
                }
                else {
                    activeSlotItem.destroyItems()
                    activeSlotItem = undefined
                }
            }
        }
    }

    // Items for active slots / alive as long as source (JSONS) is available
    Component {
        id: activeSlotComponent
        Item {
            id: activeSlotItem
            // params for createObject
            property int slotNo
            property var jsonParamInfo: extendJsonParamInfo(sourceEntity[String("ACT_DeviceInfo%1").arg(slotNo)])
            property var jsonParams: sourceEntity[String("PAR_SourceState%1").arg(slotNo)]
            property var jsonState: sourceEntity[String("ACT_DeviceState%1").arg(slotNo)]
            onJsonStateChanged: {
                if(itemsCreated && Object.keys(jsonState).length) {
                    // json values passed in createObject seem to be passed passed by value
                    viewItem.item.jsonState = jsonState
                }
            }

            function createItems() {
                if(!itemsCreated) {
                    tabItem = tabComponent.createObject(
                                null,
                                {
                                    "jsonParamInfo" : jsonParamInfo,
                                    "jsonState" : jsonState,
                                    "declarativeJsonItem" : jsonDeclParams,
                                })
                    tabItem.parent = tabBar
                    tabBar.addItem(tabItem)


                    viewItem = pageComponent.createObject()
                    viewItem.setSource("SourceModulePage.qml",
                                       {
                                           "jsonParamInfo" : jsonParamInfo,
                                           "jsonState" : jsonState,
                                           "declarativeJsonItem" : jsonDeclParams,
                                           "sendParamsToServer" : sendParamsToServer
                                       })
                    viewItem.parent = swipeView
                    swipeView.addItem(viewItem)

                    itemsCreated = true
                }
            }
            function destroyItems() {
                if(itemsCreated) {
                    tabBar.removeItem(tabItem)
                    tabItem = undefined

                    swipeView.removeItem(viewItem)
                    viewItem = undefined

                    itemsCreated = false
                    destroy()
                }
            }

            // local parameter -> vein
            property bool ignoreStatusChange: false
            function sendParamsToServer() { // SourceModulePage' send vein method
                // Avoid double full painting in SourceModulePage by our property changes
                ignoreStatusChange = true
                VeinEntity.getEntity("SourceModule1")[String("PAR_SourceState%1").arg(slotNo)] = jsonDeclParams.toJson()
                ignoreStatusChange = false
            }
            // vein -> local parameter
            onJsonParamsChanged: {
                if(Object.keys(jsonParams).length) {
                    jsonDeclParams.fromJson(jsonParams)
                }
            }
            property bool itemsCreated: false
            property var tabItem
            property var viewItem

            // Our famous Json -> Qml property wrapper
            DeclarativeJsonItem {
                id: jsonDeclParams
                /*Component.onDestruction: {
                    console.info("Destruct jsonDeclParams")
                }*/
            }
            // Tab button factory
            Component {
                id: tabComponent
                TabButton {
                    font.pointSize: tabPointSize
                    height: tabHeight

                    property var jsonParamInfo
                    property var jsonState
                    property var declarativeJsonItem
                    contentItem: Label {
                        text: jsonParamInfo.Name
                        font.capitalization: Font.AllUppercase
                        font.pointSize: tabPointSize
                        elide: Label.ElideNone
                        height: tabHeight
                        color: activeSlotItem.jsonState.errors.length === 0 ?
                                   ZTC.primaryTextColor : Material.color(Material.Red)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }


                    /*Component.onDestruction: {
                        console.info("Destruct tabItem")
                    }*/
                }
            }
            // Source view factory
            Component {
                id: pageComponent
                Loader {
                    active: false
                    property var currSwipeItem: swipeView.currentItem
                    onCurrSwipeItemChanged: {
                        if(SwipeView.isCurrentItem) {
                            active = true
                        }
                    }
                }
            }
        }
    }

    // Convenience extension of source param info
    function extendJsonParamInfo(paramInfoJsonObj) {
        // default(s) for mandatory value(s)
        paramInfoJsonObj['extraLinesRequired'] = false

        // * U/I/global harmonic support -> extraLinesRequired
        // Note: using array's forEach and arrow function causes qt-creator
        // freaking out on indentation. So loop the old-school way
        let arrUI = ['U', 'I']
        for(let numUI=0; numUI<arrUI.length; ++numUI) {
            let strUI = arrUI[numUI]
            let maxPhaseNum = paramInfoJsonObj[strUI + 'PhaseMax']
            for(var phase=1; phase<=maxPhaseNum; ++phase) {
                let phaseName = strUI + String(phase)
                if(paramInfoJsonObj[phaseName]) {
                    if(paramInfoJsonObj[phaseName].supportsHarmonics) {
                        paramInfoJsonObj['extraLinesRequired'] = true
                        paramInfoJsonObj['supportsHarmonics'+strUI] = true
                    }
                }
            }
        }
        // * generate columInfo as an ordered array of
        // { 'phasenum': .. 'phaseNameDisplay': .., 'colorIndexU': .., 'colorIndexI': .. }
        let columInfo = []
        let maxPhaseAll = Math.max(paramInfoJsonObj['UPhaseMax'],
                                   paramInfoJsonObj['IPhaseMax'])
        paramInfoJsonObj['maxPhaseAll'] = maxPhaseAll
        for(phase=1; phase<=maxPhaseAll; ++phase) {
            let phaseRequired = paramInfoJsonObj['U'+String(phase)] !== undefined || paramInfoJsonObj['I'+String(phase)] !== undefined
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
                phaseNameDisplay = Z.tr(phaseNameDisplay)
                columInfo.push({'phaseNum': phase,
                                   'phaseNameDisplay': phaseNameDisplay,
                                   'colorIndexU': colorIndexU,
                                   'colorIndexI': colorIndexI})
            }
        }
        paramInfoJsonObj['columnInfo'] = columInfo
        return paramInfoJsonObj
    }

    Component.onCompleted: {
        initialized = true
        GC.currentGuiContext = GC.guiContextEnum.GUI_SOURCE_CONTROL
    }
}

