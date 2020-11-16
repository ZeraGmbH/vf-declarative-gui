import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import SortFilterProxyModel 0.2
import GlobalConfig 1.0
import ZeraComponents 1.0
import ZeraFa 1.0

Item {
    id: root

    // 'private' properties
    property var searchableProperties: [];
    property QtObject customerData: VeinEntity.getEntity("CustomerData")
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")
    property var availableCustomerDataFiles: filesEntity === undefined ? [] : filesEntity.AvailableCustomerData
    property var searchProgressId;

    property real rowHeight: height/11
    readonly property real fontScale: 0.35
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10

    function saveChanges() {
        customerData.invokeRPC("customerDataAdd(QString fileName)", { "fileName": filenameField.text+".json" })
        customerData.FileSelected = filenameField.text+".json"
        addFilePopup.close()
        switchToEditMode();
    }

    signal switchToEditMode();
    signal ok();
    signal cancel();

    Popup {
        id: addFilePopup
        closePolicy: Popup.NoAutoClose

        readonly property bool fileNameAlreadyExists: filenameField.text.length>0 &&
                                                      availableCustomerDataFiles.indexOf(filenameField.text.toLowerCase()+".json") >= 0

        onOpened: filenameField.forceActiveFocus()
        onClosed: filenameField.clear()
        RowLayout {
            anchors.fill: parent
            Label {
                text: Z.tr("File name:")
            }
            Item {
                width: rowWidth/25
            }
            // No ZLineEdit due to different RETURN/ESC/redBackground handling
            TextField {
                id: filenameField
                validator: RegExpValidator { regExp: /^[^.|"/`$!/\\<>:?~{}]+$/ }
                implicitWidth: Math.min(Math.max(rowWidth/5, contentWidth), rowWidth/2)
                bottomPadding: GC.standardTextBottomMargin
                selectByMouse: true
                inputMethodHints: Qt.ImhNoAutoUppercase
                Rectangle {
                    anchors.fill: parent
                    color: "red"
                    opacity: 0.3
                    visible: addFilePopup.fileNameAlreadyExists
                }
                onAccepted: {
                    root.saveChanges()
                }
                Keys.onEscapePressed: {
                    addFilePopup.close()
                }
            }
            Label {
                text: ".json"
            }
            Item {
                Layout.fillWidth: true
                width: rowWidth/20
            }
            ZButton {
                text: Z.tr("OK")
                width: newFileCancel.width
                enabled: filenameField.text.length>0 && addFilePopup.fileNameAlreadyExists === false
                //highlighted: true
                onClicked: {
                    root.saveChanges()
                }
            }
            ZButton {
                id: newFileCancel
                text: Z.tr("Cancel")
                onClicked: {
                    addFilePopup.close()
                }
            }
        }
    }

    Popup {
        id: removeFilePopup

        property string fileName;

        x: parent.width/2 - width/2
        modal: true
        dim: true
        onClosed: fileName="";
        Column {
            Label {
                text: Z.tr("Really delete file <b>'%1'</b>?").arg(removeFilePopup.fileName)
            }
            RowLayout {
                width: parent.width
                Button { ///todo: Qt 5.9 use DelayButton
                    text: Z.tr("Accept")
                    Material.accent: Material.color(Material.Red, Material.Shade500);
                    highlighted: true
                    onClicked: {
                        customerData.invokeRPC("customerDataRemove(QString fileName)", { "fileName": removeFilePopup.fileName });
                        removeFilePopup.close();
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                Button {
                    text: Z.tr("Close")
                    onClicked: {
                        removeFilePopup.close()
                    }
                }
            }
        }
    }

    // For rookies like me: here starts view we see by default
    Label { // Header
        id: captionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Customer data files:")
        font.pointSize: root.pointSize * 1.5
    }
    ListView {
        id: lvFileBrowser
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.top: captionLabel.bottom
        anchors.topMargin: rowHeight / 2
        anchors.bottom: buttonAdd.top
        model: availableCustomerDataFiles
        clip: true
        ScrollIndicator.vertical: ScrollIndicator {
            width: 8
            active: true
            onActiveChanged: {
                if(active !== true) {
                    active = true;
                }
            }
        }
        delegate: ItemDelegate {
            id: fileListDelegate
            width: parent.width-8 //don't overlap with the ScrollIndicator
            height: rowHeight
            RowLayout {
                id: fileRow
                anchors.fill: parent
                Label {
                    anchors.leftMargin: GC.standardTextHorizMargin
                    text: modelData
                    Layout.fillWidth: true
                    font.pointSize: pointSize
                }
                Button {
                    font.family: FA.old
                    font.pointSize: pointSize * 1.25
                    text: FA.fa_edit
                    background: Rectangle {
                        color: "transparent"
                    }
                    // Wait for customer data selected to be applied
                    property string custDataSelected: customerData.FileSelected
                    onCustDataSelectedChanged: {
                        if(--changesExpected === 0) {
                            switchToEditMode()
                        }
                    }
                    property int changesExpected: 0
                    onClicked: {
                        // avoid muliple change
                        if(changesExpected <= 0) {
                            if(customerData.FileSelected !== modelData) {
                                customerData.FileSelected = modelData
                                changesExpected = 1
                            }
                            else {
                                switchToEditMode()
                            }
                        }
                    }
                }
                Button {
                    font.family: FA.old
                    font.pointSize: pointSize  * 1.25
                    text: FA.fa_trash
                    background: Rectangle {
                        color: "transparent"
                    }
                    onClicked: {
                        removeFilePopup.fileName = modelData
                        removeFilePopup.open()
                    }
                }
            }
        }
    }
    Button {
        id: buttonAdd
        text: "+"
        anchors.bottom: parent.bottom
        onClicked: {
            addFilePopup.open()
        }
    }
}
