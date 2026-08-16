import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import ZeraComponents 1.0
import ZeraTranslation  1.0

Item {
    id: root
    property QtObject updateWrapper
    property string releaseVersion
    property string releaseText
    property string currentReleaseVersion

    function releaseInfoWindowOnOff(onOff) {
        if(onOff)
            confirmationPopup.open()
        else
            confirmationPopup.close()
    }

    Popup {
        id: confirmationPopup
        parent: Overlay.overlay
        width: parent.width
        height: parent.height
        visible: false
        readonly property real rowHeight: Math.max(height * 0.06, 10)
        readonly property real pointSize: rowHeight * 0.5

        ColumnLayout {
            anchors.fill: parent
            Label {
                Layout.fillWidth: true
                Layout.bottomMargin: confirmationPopup.height * 0.015
                text: Z.tr("Update ") + root.currentReleaseVersion + " -> " + releaseVersion
                font.pointSize: confirmationPopup.pointSize * 1.1
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
                    font.pointSize: confirmationPopup.pointSize
                    text: releaseText
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
                    font.pointSize: confirmationPopup.pointSize
                    Layout.preferredWidth: okCancelButtonRow.buttonWidth
                    onClicked: confirmationPopup.close()
                }
                ZButton {
                    id: okButton
                    text: Z.tr("Install")
                    font.pointSize: confirmationPopup.pointSize
                    Layout.preferredWidth: okCancelButtonRow.buttonWidth
                    onClicked: updateWrapper.updateDevice()
                }
                Item { Layout.fillWidth: true }
            }
        }
    }

}

