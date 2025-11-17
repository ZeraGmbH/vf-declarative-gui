import QtQuick 2.5
import QtQuick.Controls 2.0
import GlobalConfig 1.0
import AppStarterForWebGLSingleton 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import anmsettings 1.0
import "../../pages"

BaseTabPage {
    id: root
    anchors.fill: parent
    anchors { leftMargin: 8; rightMargin: 8 }
    // Overrides
    function getLastTabSelected() {
        return GC.lastSettingsTabSelected
    }
    function setLastTabSelected(tabNo) {
        GC.setLastSettingsTabSelected(tabNo)
    }

    // Tabs
    Component {
        id: appTab
        TabButton {
            text: Z.tr("Application")
            font.pointSize: root.tabPointSize
            height: root.tabHeight
        }
    }
    Component{
        id: devTab
        TabButton {
            text: Z.tr("Device")
            font.pointSize: root.tabPointSize
            height: root.tabHeight
        }
    }
    Component{
        id: netTab
        TabButton {
            text: Z.tr("Network")
            font.pointSize: root.tabPointSize
            height: root.tabHeight
        }
    }
    Component{
        id: sensorTab
        TabButton {
            text: Z.tr("BLE sensor")
            font.pointSize: root.tabPointSize
            height: root.tabHeight
        }
    }

    // Views
    Component{
        id: appPage
        ApplicationSettings { }
    }

    Component{
        id: devPage
        DeviceSettings{ }
    }

    Component{
        id: netPage
        NetworkManager { }
    }

    Component{
        id: sensorPage
        SensorSettings { }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        if (GC.entityInitializationDone) {
            tabBar.addItem(appTab.createObject(tabBar))
            swipeView.addItem(appPage.createObject(swipeView))
        }

        if (GC.entityInitializationDone) {
            tabBar.addItem(devTab.createObject(tabBar))
            swipeView.addItem(devPage.createObject(swipeView))
        }

        if(!ASWGL.isServer) {
            tabBar.addItem(netTab.createObject(tabBar))
            swipeView.addItem(netPage.createObject(swipeView))
        }

        if(VeinEntity.hasEntity("BleModule1")) {
            tabBar.addItem(sensorTab.createObject(tabBar))
            swipeView.addItem(sensorPage.createObject(swipeView))
        }

        finishInit()
    }
}
