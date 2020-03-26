import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import QtQuick.VirtualKeyboard.Settings 2.2
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import networksettings 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/vf-controls" as VFControls
import "qrc:/data/staticdata/FontAwesome.js" as FA

Item{
    id:tabroot
    anchors.fill: parent

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.topMargin: settingsTabsBar.height
        currentIndex: settingsTabsBar.currentIndex
        spacing: 20
    }

    TabBar {
        id: settingsTabsBar
        width: parent.width
        currentIndex: swipeView.currentIndex
        contentHeight: 32
    }

    Component{
        id: appTab
        TabButton {
            text: qsTr("Application Settings")
        }
    }
    Component{
        id: devTab
        TabButton {
            text: qsTr("Device Settings")
        }
    }
    Component{
        id: ethTabs
        TabButton {
            text: qsTr("Ethernet Settings")
        }
    }
    Component{
        id: wifiTabs
        TabButton {
            text: qsTr("Wifi Settings")
        }
    }


    Component{
        id: appPage
        ApplicationSettings{

        }
    }

    Component{
        id: devPage
        DeviceSettings{

        }
    }

    Component{
        id: ethPage
        EthernetTab{
        fontPixelSize: 16
        width: swipeView.width
        height: swipeView.height
        }
    }

    Component{
        id: wifiPage
        WifiTab{
        fontPixelSize: 16
        width: swipeView.width
        height: swipeView.height
        }
    }


    Component.onCompleted: {

        settingsTabsBar.addItem(appTab.createObject(settingsTabsBar))
        swipeView.addItem(appPage.createObject(swipeView))

        settingsTabsBar.addItem(devTab.createObject(settingsTabsBar))
        swipeView.addItem(devPage.createObject(swipeView))

        settingsTabsBar.addItem(ethTabs.createObject(settingsTabsBar))
        swipeView.addItem(ethPage.createObject(swipeView))

        settingsTabsBar.addItem(wifiTabs.createObject(settingsTabsBar))
        swipeView.addItem(wifiPage.createObject(swipeView))

    }



}
