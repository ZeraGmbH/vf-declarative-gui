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
    property real rowHeight: height/11 // 11 lines total
    // Same as CustomerDataEntry 'Save' / 'Close'
    property real buttonWidth: width/4;
    // Used by file-list and filter-combobox
    property real indicatorWidth: 24

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
    Item {
        anchors.fill: parent
        Label {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: GC.standardTextHorizMargin
            anchors.top: parent.top
            height: root.rowHeight
            text: Z.tr("Customer data files:")
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: root.rowHeight/2
        }
        ListView {
            id: lvFileBrowser
            anchors.fill: parent
            anchors.topMargin: root.rowHeight
            anchors.rightMargin: root.buttonWidth+GC.standardTextHorizMargin
            model: availableCustomerDataFiles
            highlightFollowsCurrentItem: true
            currentIndex: availableCustomerDataFiles.indexOf(customerData.FileSelected)
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
                highlighted: ListView.isCurrentItem
                onClicked: {
                    if(customerData.FileSelected !== modelData) {
                        customerData.FileSelected = modelData
                    }
                }
                onDoubleClicked: {
                    root.switchToEditMode()
                }
                Row {
                    id: fileRow
                    anchors.fill: parent
                    anchors.leftMargin: GC.standardTextHorizMargin
                    Label {
                        id: activeIndicator
                        width: indicatorWidth
                        font.family: FA.old
                        text: FA.fa_check
                        opacity: (modelData === customerData.FileSelected)? 1.0 : 0.0
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        x: indicatorWidth+GC.standardTextHorizMargin
                        width: parent.width - root.buttonWidth - 2*GC.standardTextHorizMargin
                        text: modelData
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
        ZButton {
            text: FA.icon(FA.fa_file)+Z.tr("New")
            font.family: FA.old
            anchors.right: parent.right
            width: root.buttonWidth
            anchors.top: parent.top
            anchors.topMargin: 1.5*rowHeight
            height: rowHeight

            onClicked: {
                addFilePopup.open()
            }
        }
        ZButton {
            text: FA.icon(FA.fa_edit)+Z.tr("Edit")
            font.family: FA.old
            anchors.right: parent.right
            width: root.buttonWidth
            anchors.top: parent.top
            anchors.topMargin: 4*rowHeight
            height: rowHeight

            enabled: customerData.FileSelected !== ""

            onClicked: {
                switchToEditMode()
            }
        }
        ZButton {
            text: FA.icon(FA.fa_trash)+Z.tr("Delete")
            font.family: FA.old

            anchors.right: parent.right
            width: root.buttonWidth
            anchors.top: parent.top
            anchors.topMargin: 6.5*rowHeight
            height: rowHeight

            enabled: customerData.FileSelected !== ""

            onClicked: {
                removeFilePopup.fileName = lvFileBrowser.model[lvFileBrowser.currentIndex].toString();
                removeFilePopup.open()
            }
        }

    }
}
