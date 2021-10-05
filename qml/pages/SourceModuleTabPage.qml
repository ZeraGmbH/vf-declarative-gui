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
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import "../controls"
import "../controls/settings"

BaseTabPage {
    id: root

    readonly property QtObject sourceModule: VeinEntity.getEntity("SourceModule1")

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

    // create tabs/pages dynamic
    readonly property int maxCountSources: sourceModule.ACT_MaxSources
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
            let jsonInfoTmp = sourceModule[infoComponentName]
            let slotIsOn = jsonInfoTmp.UPhaseMax !== undefined && jsonInfoTmp.IPhaseMax !== undefined
            let paramComponentName = String("PAR_SourceState%1").arg(sourceNum)
            // create?
            if(slotIsOn && lastSlotItemsTab[sourceNum] === undefined) {
                let jsonDeviceInfo = sourceModule[infoComponentName] // won't change contents

                lastSlotItemsTab[sourceNum] = tabSource.createObject(tabBar, {"jsonSourceParamInfo" : jsonDeviceInfo})
                tabBar.addItem(lastSlotItemsTab[sourceNum])

                lastSlotItemsPage[sourceNum] = pageSource.createObject(swipeView, {
                                                                           "paramComponentName" : paramComponentName,
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

