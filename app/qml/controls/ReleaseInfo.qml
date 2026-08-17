import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import VeinEntity 1.0
import ZeraComponents 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0

Popup {
    signal sigUpdateRequest()
    signal sigUpdateCanceled()
    property string releaseVersion
    property string releaseText

    id: confirmationPopup
    parent: Overlay.overlay
    width: parent.width
    height: parent.height
    readonly property real rowHeight: Math.max(height * 0.06, 10)
    readonly property real pointSize: rowHeight * 0.5
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property string currentReleaseVersion : statusEntity["INF_ReleaseNr"]

    ColumnLayout {
        anchors.fill: parent
        Label {
            Layout.fillWidth: true
            Layout.bottomMargin: confirmationPopup.height * 0.015
            text: Z.tr("Update ") + currentReleaseVersion + " -> " + releaseVersion
            font.pointSize: confirmationPopup.pointSize * 1.1
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Flickable {
            id: licenseFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            readonly property bool scrollVisible: contentHeight > height
            readonly property int scrollWidth: 8
            contentHeight: updateText.implicitHeight
            contentWidth: parent.width
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            ScrollBar.vertical: ScrollBar {
                width: licenseFlickable.scrollWidth
                policy: licenseFlickable.scrollVisible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }
            Label {
                id: updateText
                width: licenseFlickable.width - licenseFlickable.scrollWidth
                wrapMode: Text.WordWrap
                font.pointSize: confirmationPopup.pointSize
                text: releaseText
                horizontalAlignment: Text.AlignLeft
                textFormat: Label.MarkdownText
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
                onClicked: {
                    GC.releaseVersionCanceledByUser = releaseVersion
                    confirmationPopup.close()
                }
            }
            ZButton {
                id: okButton
                text: Z.tr("Install")
                font.pointSize: confirmationPopup.pointSize
                Layout.preferredWidth: okCancelButtonRow.buttonWidth
                onClicked: sigUpdateRequest()
            }
            Item { Layout.fillWidth: true }
        }
    }
}
