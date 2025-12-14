import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import AdjustmentState 1.0
import FontAwesomeQml 1.0
import ZeraThemeConfig 1.0
import ZeraComponents 1.0
import "../../pages"

BaseTabPage {
    id: root
    anchors.fill: parent
    anchors { leftMargin: 8; rightMargin: 8 }
    // Overrides
    function getLastTabSelected() {
        return GC.lastInfoTabSelected
    }
    function setLastTabSelected(tabNo) {
        GC.setLastInfoTabSelected(tabNo)
    }

    // TabButtons
    Component {
        id: tabStatus
        ZTabButton {
            id: statusTabButton
            font.pointSize: tabPointSize
            height: tabHeight
            text: FAQ.fa_info_circle + " " +Z.tr("Device info")
            Material.foreground: AdjState.adjusted ? ZTC.primaryTextColor : Material.Red
            Timer {
                interval: 300
                repeat: true
                running: !AdjState.adjusted && !statusTabButton.checked
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
        id: tabServiceSupport
        ZTabButton {
            font.pointSize: tabPointSize
            height: tabHeight
            text: FAQ.fa_wrench + " " + Z.tr("Service Support")
        }
    }
    Component {
        id: tabLicense
        ZTabButton {
            font.pointSize: tabPointSize
            height: tabHeight
            text: "§"+Z.tr("License information")
        }
    }

    // Pages
    Component {
        id: pageStatus
        DeviceInformation { }
    }
    Component {
        id: pageServiceSupport
        ServiceSupport { }
    }
    Component {
        id: pageLicense
        LicenseInformation { }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        tabBar.addItem(tabStatus.createObject(tabBar))
        swipeView.addItem(pageStatus.createObject(swipeView))

        tabBar.addItem(tabServiceSupport.createObject(tabBar))
        swipeView.addItem(pageServiceSupport.createObject(swipeView))

        tabBar.addItem(tabLicense.createObject(tabBar))
        swipeView.addItem(pageLicense.createObject(swipeView))

        swipeView.anchors.topMargin = 8
        swipeView.anchors.bottomMargin = 8

        finishInit()
    }
}
