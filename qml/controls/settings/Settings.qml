import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import QtQuick.VirtualKeyboard.Settings 2.2
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import AppStarterForWebGLSingleton 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraFa 1.0
import anmsettings 1.0
import "../../pages"

// Networkmanager
import "qrc:/src/qml/"
import "qrc:/src/qml/tree"

BaseTabPage {
    id:tabroot
    anchors.fill: parent
    anchors.leftMargin: 8
    anchors.rightMargin: 8
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
            text: Z.tr("Application Settings")
        }
    }
    Component{
        id: devTab
        TabButton {
            text: Z.tr("Device settings")
        }
    }
    Component{
        id: netTab
        TabButton {
            text: Z.tr("Network settings")
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
        NetworkManager{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 0
            onNotification: {
               // notificationManager.notify(title,msg);
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        tabBar.addItem(appTab.createObject(tabBar))
        swipeView.addItem(appPage.createObject(swipeView))

        tabBar.addItem(devTab.createObject(tabBar))
        swipeView.addItem(devPage.createObject(swipeView))

        if(!ASWGL.isServer) {
            tabBar.addItem(netTab.createObject(tabBar))
            swipeView.addItem(netPage.createObject(swipeView))
        }
        finishInit()
    }
}
