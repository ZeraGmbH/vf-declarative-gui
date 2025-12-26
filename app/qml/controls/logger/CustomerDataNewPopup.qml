import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0

Popup {
    // dirty but parent must have the following root-item properties:
    //
    // availableCustomerDataFiles
    // menuStackLayout
    // pointSize
    // pointSizeHeader
    // rowHeight

    parent: Overlay.overlay
    width: parent.width
    height: parent.height - GC.vkeyboardHeight
    modal: !Qt.inputMethod.visible
    closePolicy: Popup.NoAutoClose

    readonly property bool fileNameAlreadyExists: filenameField.text.length>0 &&
                                                  availableCustomerDataFiles.indexOf(filenameField.text.toLowerCase()+".json") >= 0

    property QtObject customerData: VeinEntity.getEntity("CustomerData")
    function startAddCustomerData() {
        customerData.invokeRPC("customerDataAdd(QString fileName)", { "fileName": filenameField.text+".json" })
        customerData.FileSelected = filenameField.text+".json"
        close()
        menuStackLayout.showCustomerDataEditor()
    }
    onOpened: filenameField.forceActiveFocus()
    onClosed: filenameField.clear()

    Label { // Header
        id: captionLabelNewPopup
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Create Customer data file")
        font.pointSize: pointSizeHeader
    }
    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: captionLabelNewPopup.bottom
        anchors.bottom: buttonRowNew.top
        Label {
            text: Z.tr("File name:")
            font.pointSize: pointSize
            height: rowHeight
        }
        // No ZLineEdit due to different RETURN/ESC/redBackground handling
        TextField {
            id: filenameField
            validator: RegularExpressionValidator { regularExpression: /\b[_a-z0-9][_\-a-z0-9]*\b/ }
            font.pointSize: pointSize
            height: rowHeight
            bottomPadding: GC.standardTextBottomMargin
            selectByMouse: true
            inputMethodHints: Qt.ImhLowercaseOnly | Qt.ImhEmailCharactersOnly
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            Rectangle {
                anchors.fill: parent
                color: "red"
                opacity: 0.3
                visible: fileNameAlreadyExists || !filenameField.acceptableInput
            }
            onAccepted: {
                startAddCustomerData()
            }
            Keys.onEscapePressed: {
                close()
            }
        }
        Label {
            text: ".json"
            font.pointSize: pointSize
            height: rowHeight
        }
    }
    RowLayout {
        id: buttonRowNew
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        Item {
            Layout.fillWidth: true
        }
        ZButton {
            id: newFileCancel
            text: Z.tr("Cancel")
            font.pointSize: pointSize
            onClicked: {
                close()
            }
        }
        ZButton {
            text: Z.tr("OK")
            font.pointSize: pointSize
            Layout.preferredWidth: newFileCancel.width
            enabled: filenameField.acceptableInput && fileNameAlreadyExists === false
            onClicked: {
                startAddCustomerData()
            }
        }
    }
}
