import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraFa 1.0

Item {
    id: root
    readonly property bool hasStatus: VeinEntity.hasEntity("StatusModule1")

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
        anchors.topMargin: informationTabBar.height + 8
        currentIndex: informationTabBar.currentIndex
        spacing: 20
    }
    TabBar {
        id: informationTabBar
        width: parent.width
        contentHeight: 32
        currentIndex: swipeView.currentIndex
        onCurrentIndexChanged: {
            if(initialized) {
                GC.setLastInfoTabSelected(currentIndex)
            }
        }
    }

    // TabButtons
    Component {
        id: tabStatus
        TabButton {
            id: statusTabButton
            font.family: FA.old
            text: FA.icon(FA.fa_info_circle)+Z.tr("Device info")
            Material.foreground: GC.adjustmentStatusOk ? Material.White : Material.Red
            Timer {
                interval: 300
                repeat: true
                running: !GC.adjustmentStatusOk && !statusTabButton.checked
                onRunningChanged: {
                    if(!running) {
                        statusTabButton.opacity = 1
                    }
                }
                property bool show: true
                onTriggered: {
                    show = !show
                    statusTabButton.opacity = show ? 1 : 0
                }
            }
        }
    }
    Component {
        id: tabLicense
        TabButton {
            text: "§"+Z.tr("License information")
        }
    }

    // Pages
    Component {
        id: pageStatus
        DeviceInformation { }
    }
    Component {
        id: pageLicense
        LicenseInformation { }
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
        if(hasStatus) {
            informationTabBar.addItem(tabStatus.createObject(informationTabBar))
            swipeView.addItem(pageStatus.createObject(swipeView))
        }
        informationTabBar.addItem(tabLicense.createObject(informationTabBar))
        swipeView.addItem(pageLicense.createObject(swipeView))

        let lastTabSelected = GC.lastInfoTabSelected
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
