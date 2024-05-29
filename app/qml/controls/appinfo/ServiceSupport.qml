import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import AdjustmentState 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import QmlFileIO 1.0

Item {
    id: root
    readonly property real rowHeight: height > 0 ? height/20 : 10
    readonly property real pointSize: rowHeight * 0.7

    VisualItemModel {
        id: supportModel

        RowLayout {
            width: parent.width
            height: root.rowHeight * 4
            Button {
                id: buttonStoreLog
                property bool buttonEnabled: true
                font.pointSize: root.pointSize
                text: Z.tr("Save logfile to USB")
                width: implicitContentWidth
                Layout.preferredWidth: root.width * 0.4
                enabled: (QmlFileIO.mountedPaths.length > 0) && buttonEnabled
                highlighted: true
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    QmlFileIO.storeJournalctlOnUsb(root.versionMap)
                    buttonEnabled = false
                    buttonTimer.start()
                }
            }
            Timer {
                id: buttonTimer
                interval: 1000
                repeat: false
                onTriggered: {
                    buttonStoreLog.buttonEnabled = true
                }
            }
        }

        RowLayout {
            width: parent.width
            height: root.rowHeight * 2
            Button {
                id: buttonStartUpdate
                property bool buttonUpdateEnabled: true
                font.pointSize: root.pointSize
                text: Z.tr("Start Software-Update")
                width: implicitContentWidth
                Layout.preferredWidth: parent.width * 0.4
                enabled: false //conditions for sw update
                highlighted: true
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    //action sw update
                }
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: supportModel
    }
}

