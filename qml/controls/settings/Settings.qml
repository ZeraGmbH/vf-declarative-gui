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
import "qrc:/qml/controls" as CCMP
import ZeraVeinComponents 1.0 as VFControls
import ZeraFa 1.0

import anmsettings 1.0

import "qrc:/src/qml/"
import "qrc:/src/qml/tree"
import "qrc:/"

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
            text: ZTR["Application Settings"]
        }
    }
    Component{
        id: devTab
        TabButton {
            text: ZTR["Device settings"]
        }
    }

    Component{
        id: netTab
        TabButton {
            text: ZTR["Network settings"]
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




    Component.onCompleted: {

        settingsTabsBar.addItem(appTab.createObject(settingsTabsBar))
        swipeView.addItem(appPage.createObject(swipeView))

        settingsTabsBar.addItem(devTab.createObject(settingsTabsBar))
        swipeView.addItem(devPage.createObject(swipeView))

        settingsTabsBar.addItem(netTab.createObject(settingsTabsBar))
        swipeView.addItem(netPage.createObject(swipeView))


    }



}
