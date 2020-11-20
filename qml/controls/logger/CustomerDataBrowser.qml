import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import SortFilterProxyModel 0.2
import GlobalConfig 1.0
import ZeraComponents 1.0
import ZeraFa 1.0

Item {
    id: root
    // we need a reference to menu stack layout to move around
    property var menuStackLayout
    // allow my parent to open 'new' custioner data
    function openNewCustomerDataPopup() {
        addFilePopup.open()
    }

    // 'private' properties
    property var searchableProperties: [];
    property QtObject customerData: VeinEntity.getEntity("CustomerData")
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")
    property var availableCustomerDataFiles: filesEntity === undefined ? [] : filesEntity.AvailableCustomerData
    readonly property var mountedPaths: filesEntity ? filesEntity.AutoMountedPaths : []

    property real rowHeight: height/8
    readonly property real fontScale: 0.35
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10
    readonly property real pointSizeHeader: pointSize * 1.25

    // make current output path commonly accessible / set by combo target drive
    readonly property alias selectedMountPath: mountedDrivesCombo.currentPath

    function saveChanges() {
        customerData.invokeRPC("customerDataAdd(QString fileName)", { "fileName": filenameField.text+".json" })
        customerData.FileSelected = filenameField.text+".json"
        addFilePopup.close()
        menuStackLayout.showCustomerDataEditor()
    }

    Popup {
        id: addFilePopup
        parent: Overlay.overlay
        width: parent.width
        height: parent.height - GC.vkeyboardHeight
        modal: !Qt.inputMethod.visible
        closePolicy: Popup.NoAutoClose

        readonly property bool fileNameAlreadyExists: filenameField.text.length>0 &&
                                                      availableCustomerDataFiles.indexOf(filenameField.text.toLowerCase()+".json") >= 0

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
                validator: RegExpValidator { regExp: /^[^.|"/`$!/\\<>:?~{}]+$/ }
                font.pointSize: pointSize
                height: rowHeight
                bottomPadding: GC.standardTextBottomMargin
                selectByMouse: true
                inputMethodHints: Qt.ImhNoAutoUppercase
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
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
            Button {
                id: newFileCancel
                text: Z.tr("Cancel")
                font.pointSize: pointSize
                onClicked: {
                    addFilePopup.close()
                    menuStackLayout.pleaseCloseMe(false)
                }
            }
            Button {
                text: Z.tr("OK")
                font.pointSize: pointSize
                Layout.preferredWidth: newFileCancel.width
                enabled: filenameField.text.length>0 && addFilePopup.fileNameAlreadyExists === false
                onClicked: {
                    root.saveChanges()
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
        text: Z.tr("Edit customer data")
        font.pointSize: pointSizeHeader
    }
    ListView {
        id: lvFileBrowser
        model: availableCustomerDataFiles
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.top: captionLabel.bottom
        anchors.topMargin: rowHeight / 2
        anchors.bottom: buttonRow.top
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
                    Layout.preferredWidth: rowHeight * 2
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
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
                            menuStackLayout.showCustomerDataEditor()
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
                                menuStackLayout.showCustomerDataEditor()
                            }
                        }
                    }
                }
                Button {
                    Layout.preferredWidth: rowHeight * 2
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    font.family: FA.old
                    font.pointSize: pointSize * 1.25
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
    RowLayout {
        id: buttonRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.bottom: parent.bottom
        Button {
            text: "+"
            onClicked: {
                addFilePopup.open()
            }
        }
        Item { Layout.fillWidth: true }
        MountedDrivesCombo {
            id: mountedDrivesCombo
            visible: mountedPaths.length > 1
            Layout.preferredWidth: contentMaxWidth
            Layout.fillHeight: true
            font.pointSize: pointSize
        }
        Button {
            text: Z.tr("Import")
            font.pointSize: pointSize
            onClicked: {

            }
        }
        Button {
            text: Z.tr("Export")
            font.pointSize: pointSize
            onClicked: {

            }
        }
    }

}
