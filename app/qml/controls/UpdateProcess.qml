import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import UpdateWrapper 1.0
import ZeraComponents 1.0
import VeinEntity 1.0
import anmsettings 1.0

Item {
    id: root
    property int windowHeight
    property int windowWidth
    readonly property real rowHeight: Math.max(windowHeight * 0.0725, 10)
    readonly property real pointSize: rowHeight * 0.5
    readonly property bool isNetworkConnected: networkListModel.entryCount > 0
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property string currentReleaseVersion : statusEntity["INF_ReleaseNr"]

    InfoInterface { id: networkListModel }
    UpdateWrapper {id: updateWrapper}

    function checkLatestRelease() {
        if(isNetworkConnected)
            updateWrapper.checkIfReleaseIsLatest(currentReleaseVersion)
    }

    Connections {
        target: updateWrapper
        function onSigReleaseCheckFinished(newReleaseFound) {
            if(newReleaseFound);
                newReleasePopup.visible = true
        }
    }

    Timer {
        id: checkNewReleaseTimer
        interval: 86400000  // 24 hours
        running: true
        repeat: true
        onTriggered: checkLatestRelease()
    }

    Popup {
        id: newReleasePopup
        x: (windowWidth - width) / 2
        y: (windowHeight - height) / 2
        width: contentWidth * 1.2
        height: contentHeight * 1.2
        visible: false
        ColumnLayout {
            anchors.fill: parent
            Label {
                font.pointSize: pointSize
                text: Z.tr("New Release version has been published !")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                ZButton {
                    text: Z.tr("More")
                    font.pointSize: pointSize
                    onClicked: {
                        newReleasePopup.close()
                        updateWrapper.prepareReleaseUpdate()
                        confirmationPopup.open()
                    }
                }
                ZButton {
                    text: Z.tr("Close")
                    font.pointSize: pointSize
                    onClicked: {
                        newReleasePopup.close()
                        checkNewReleaseTimer.stop()
                    }
                }
                ZButton {
                    text: Z.tr("Remind me later")
                    font.pointSize: pointSize
                    onClicked: {
                        newReleasePopup.close()
                        checkNewReleaseTimer.restart()
                    }
                }
            }
        }
    }

    Popup {
        id: confirmationPopup
        width: windowWidth
        height: windowHeight
        visible: false

        ColumnLayout {
            anchors.fill: parent
            Label {
                Layout.fillWidth: true
                Layout.bottomMargin: confirmationPopup.height * 0.015
                text: Z.tr("Update ") + root.currentReleaseVersion + " -> " + updateWrapper.releaseVersion
                font.pointSize: pointSize * 1.1
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Flickable {
                id: licenseFlickable
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: updateText.implicitHeight
                contentWidth: parent.width
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                ScrollBar.vertical: ScrollBar {
                    width: 8
                    policy:
                        licenseFlickable.contentHeight > licenseFlickable.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }
                Label {
                    id: updateText
                    width: licenseFlickable.width
                    wrapMode: Text.WordWrap
                    font.pointSize: pointSize
                    text: updateWrapper.releaseText
                    horizontalAlignment: Text.AlignLeft
                    textFormat: Label.MarkdownText   // warning
                    Layout.fillWidth: true
                }
            }
            RowLayout {
                id: okCancelButtonRow
                Layout.fillWidth: true
                Layout.bottomMargin: -5 // ??
                readonly property real buttonWidth: Math.max(cancelButton.implicitWidth, okButton.implicitWidth) * 1.1

                Item { Layout.fillWidth: true }
                ZButton {
                    id: cancelButton
                    text: Z.tr("Cancel")
                    font.pointSize: pointSize
                    Layout.preferredWidth: okCancelButtonRow.buttonWidth
                    onClicked: confirmationPopup.close()
                }
                ZButton {
                    id: okButton
                    text: Z.tr("OK")
                    font.pointSize: pointSize
                    Layout.preferredWidth: okCancelButtonRow.buttonWidth
                    onClicked: updateWrapper.updateDevice()
                }
                Item { Layout.fillWidth: true }
            }
        }
    }
}
