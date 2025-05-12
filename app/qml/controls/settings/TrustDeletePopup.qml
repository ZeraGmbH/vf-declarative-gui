import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ZeraTranslation  1.0
import AuthorizationRequestHandler 1.0
import VeinEntity 1.0

Popup {
    id: trustDeletePopup

    property var trust : { return { name: "" }; }

    function confirm(t) {
        trust = t;

        open();
    }

    AuthorizationRequestHandler {
        id: authHandlerExecuter
    }

    anchors.centerIn: parent
    width: parent.width * 0.85
    height: parent.height * 0.65
    modal: true
    readonly property real pointSize: displayWindow.pointSize * 0.9

    ColumnLayout {
        id: apiInfoPopupContent
        width: parent.width
        height: parent.height * 0.75

        Label {
            font.pointSize: pointSize
            text: trust.name
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            width: parent.width
            wrapMode: Text.Wrap
        }
    }
    Button {
        text: Z.tr("Cancel")
        font.pointSize: pointSize
        anchors {top: apiInfoPopupContent.bottom; right: apiInfoPopupContent.right }
        highlighted: true
        onClicked: close()
    }

    Button {
        text: Z.tr("Delete this Trust")
        font.pointSize: pointSize
        anchors {top: apiInfoPopupContent.bottom; left: apiInfoPopupContent.left }
        onClicked: {
            authHandlerExecuter.deleteTrust(trust);
            VeinEntity.getEntity("ApiModule").PAR_ReloadTrustList = true;
            close();
        }
    }
}
