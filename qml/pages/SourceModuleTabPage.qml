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
            property var jsonSourceInfo
            text: jsonSourceInfo.Name
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
            let componentName = String("ACT_DeviceInfo%1").arg(sourceNum)
            let slotIsOn = (sourceModule[componentName] !== "")
            // create?
            if(slotIsOn && lastSlotItemsTab[sourceNum] === undefined) {
                let bindingJsonDeviceInfo = Qt.binding(() => JSON.parse(sourceModule[componentName]))

                lastSlotItemsTab[sourceNum] = tabSource.createObject(tabBar, {"jsonSourceInfo" : bindingJsonDeviceInfo})
                tabBar.addItem(lastSlotItemsTab[sourceNum])

                lastSlotItemsPage[sourceNum] = pageSource.createObject(swipeView, {"jsonSourceInfo" : bindingJsonDeviceInfo})
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

