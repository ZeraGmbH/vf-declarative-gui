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
import "qrc:/qml/controls" as CCMP
import "qrc:/src/qml/"
import "qrc:/src/qml/tree"
import "qrc:/"

Item{
    id:tabroot
    anchors.fill: parent

    onInitializedChanged: forceActiveFocus()
    Keys.onRightPressed: {
        if(swipeView.currentIndex < swipeView.count-1) {
            swipeView.setCurrentIndex(swipeView.currentIndex+1)
        }
    }
    Keys.onLeftPressed: {
        if(swipeView.currentIndex > 0) {
            swipeView.setCurrentIndex(swipeView.currentIndex-1)
        }
    }

    SwipeView {
        id: swipeView
        visible: initialized
        anchors.fill: parent
        anchors.topMargin: settingsTabsBar.height
        currentIndex: settingsTabsBar.currentIndex
        spacing: 20
    }

    TabBar {
        id: settingsTabsBar
        width: parent.width
        currentIndex: swipeView.currentIndex
        onCurrentIndexChanged: {
            if(initialized) {
                GC.setLastSettingsTabSelected(currentIndex)
            }
        }
        contentHeight: 32
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
    property bool initialized: false
    Timer {
        id: initTimer
        interval: 250
        onTriggered: {
            initialized = true
        }
    }

    Component.onCompleted: {
        settingsTabsBar.addItem(appTab.createObject(settingsTabsBar))
        swipeView.addItem(appPage.createObject(swipeView))

        settingsTabsBar.addItem(devTab.createObject(settingsTabsBar))
        swipeView.addItem(devPage.createObject(swipeView))

        if(!ASWGL.isServer) {
            settingsTabsBar.addItem(netTab.createObject(settingsTabsBar))
            swipeView.addItem(netPage.createObject(swipeView))
        }
        let lastTabSelected = GC.lastSettingsTabSelected
        if(lastTabSelected >= swipeView.count) {
            lastTabSelected = 0
        }
        if(lastTabSelected) {
            swipeView.setCurrentIndex(lastTabSelected)
            initTimer.start()
        }
        else {
            initialized = true
        }
    }
}
