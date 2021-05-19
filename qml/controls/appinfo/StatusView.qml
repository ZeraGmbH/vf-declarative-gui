import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraFa 1.0
import "../../pages"

BaseTabPage {
    id: root
    readonly property bool hasStatus: VeinEntity.hasEntity("StatusModule1")

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
    Component.onCompleted: {
        if(hasStatus) {
            tabBar.addItem(tabStatus.createObject(tabBar))
            swipeView.addItem(pageStatus.createObject(swipeView))
        }
        tabBar.addItem(tabLicense.createObject(tabBar))
        swipeView.addItem(pageLicense.createObject(swipeView))

        swipeView.anchors.topMargin = Qt.binding(() => tabBar.height + 8)

        finishInit()
    }
}
