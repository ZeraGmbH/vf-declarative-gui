import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import AuthorizationRequestHandler 1.0

Popup {
    property var pendingRequest: GC.entityInitializationDone ? VeinEntity.getEntity("ApiModule").ACT_PendingRequest : ""
    property bool finishedDialog: GC.entityInitializationDone ? VeinEntity.getEntity("ApiModule").PAR_GuiDialogFinished : false
    property bool initialized: false

    anchors.centerIn: parent
    width: parent.width * 0.85
    height: parent.height * 0.65

    closePolicy: Popup.NoAutoClose
    modal: true

    onPendingRequestChanged: {
        if(initialized)
            if(Object.keys(authorizationPopup.pendingRequest).length == 0)
                authorizationPopup.close()
            else
                authorizationPopup.open()
        else if(GC.entityInitializationDone && !initialized)
            initialized = true
    }

    ColumnLayout {
        id: requestDialog
        width: parent.width
        height: parent.height * 0.75
        Label {
            font.pointSize: pointSize
            text: Z.tr("New Request")
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            width: parent.width
            wrapMode: Text.Wrap
        }
        Label {
            font.pointSize: pointSize
            text: Z.tr("Name: ") + authorizationPopup.pendingRequest.name
            horizontalAlignment: Text.AlignLeft
            Layout.fillWidth: true
            width: parent.width
            wrapMode: Text.Wrap
        }
        Label {
            font.pointSize: pointSize
            text: Z.tr("Type: ") + authorizationPopup.pendingRequest.tokenType
            horizontalAlignment: Text.AlignLeft
            Layout.fillWidth: true
            width: parent.width
            wrapMode: Text.Wrap
        }
        Label {
            font.pointSize: pointSize
            text: Z.tr("Fingerprint: ")
            horizontalAlignment: Text.AlignLeft
            Layout.fillWidth: true
            width: parent.width
            wrapMode: Text.Wrap
        }
        Label {
            font.pointSize: pointSize
            text: authHandlerExecuter.computeHashString(authorizationPopup.pendingRequest.tokenType, authorizationPopup.pendingRequest.token)
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            width: parent.width
            wrapMode: Text.Wrap
        }
    }

    Button {
        text: Z.tr("Deny")
        font.pointSize: pointSize
        onClicked: {
            VeinEntity.getEntity("ApiModule").PAR_GuiDialogFinished = true;
            authorizationPopup.close()
        }
        anchors {top: requestDialog.bottom; right: requestDialog.right }
    }
    Button {
        text: Z.tr("Allow")
        font.pointSize: pointSize
        onClicked: {
            authHandlerExecuter.finishRequest(true, authorizationPopup.pendingRequest);
            VeinEntity.getEntity("ApiModule").PAR_GuiDialogFinished = true;
            authorizationPopup.close()
        }
        highlighted: true
        anchors {top: requestDialog.bottom; left: requestDialog.left }
    }

    AuthorizationRequestHandler {
        id: authHandlerExecuter
    }
}


