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

    TabBar {
        id: informationSelector
        width: parent.width
        contentHeight: 32
        currentIndex: GC.entityInitializationDone ? swipeView.currentIndex : 1
        TabButton {
            id: deviceStatusButton
            text: FA.icon(FA.fa_info_circle)+Z.tr("Device info")
            font.family: FA.old
            height: parent.height
            font.pixelSize: height/2
            enabled: VeinEntity.hasEntity("StatusModule1")
            Material.foreground: GC.adjustmentStatusOk ? Material.White : Material.Red
            Timer {
                interval: 300
                repeat: true
                running: !GC.adjustmentStatusOk && !deviceStatusButton.checked
                onRunningChanged: {
                    if(!running) {
                        deviceStatusButton.opacity = 1
                    }
                }
                property bool show: true
                onTriggered: {
                    show = !show
                    deviceStatusButton.opacity = show ? 1 : 0
                }
            }
        }
        TabButton {
            text: FA.icon("<b>§</b>")+Z.tr("License information")
            font.family: FA.old
            height: parent.height
            font.pixelSize: height/2
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.topMargin: informationSelector.height + GC.standardTextBottomMargin
        currentIndex: informationSelector.currentIndex

        Loader {
            active: swipeView.currentIndex === 0 && VeinEntity.hasEntity("StatusModule1")
            sourceComponent: DeviceInformation { }
        }
        Loader {
            active: swipeView.currentIndex === 1
            sourceComponent: LicenseInformation { }
        }
    }
}
