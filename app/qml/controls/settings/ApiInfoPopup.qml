import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ZeraTranslation  1.0
import AppStarterForApi 1.0

Popup {
    id: apiInfoPopup

    property var cert: ""

    onOpened: cert = ASAPI.calculateThumbnail(Z.tr("No SSL Certificate available."))

    onClosed: cert = ""

    anchors.centerIn: parent
    width: parent.width * 0.95
    height: parent.height * 0.5
    modal: true
    readonly property real pointSize: displayWindow.pointSize * 0.9

    ColumnLayout {
        id: apiInfoPopupContent
        width: parent.width
        height: parent.height
        Label {
            text: Z.tr("API SSL Certificate (SHA1)")
            font.pointSize: pointSize * 1.25
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            width: parent.width
            wrapMode: Text.Wrap
        }

        Label {
            Layout.alignment: Qt.AlignCenter
            width: parent.width
            font.pointSize: pointSize
            text: cert
        }

        Button {
            text: Z.tr("Cancel")
            font.pointSize: displayWindow.pointSize
            Layout.alignment: Qt.AlignRight;
            highlighted: true
            onClicked: close()
        }
    }
}
