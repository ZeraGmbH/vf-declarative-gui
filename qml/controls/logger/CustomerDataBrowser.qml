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

    // 'private' properties
    property var searchableProperties: [];
    property QtObject customerData: VeinEntity.getEntity("CustomerData")
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")
    property var availableCustomerDataFiles: filesEntity === undefined ? [] : filesEntity.AvailableCustomerData
    readonly property var mountedPaths: filesEntity ? filesEntity.AutoMountedPaths : []
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1") // for paths as zera-<devicetype>-<serno>
    readonly property string devicePath: statusEntity ? "zera-" + statusEntity.INF_DeviceType + '-' + statusEntity.PAR_SerialNr : "zera-undef"
    readonly property string stickImportExportPath: mountedDrivesCombo.currentPath + '/' + devicePath  + '/customerdata'

    property real rowHeight: height/8
    readonly property real fontScale: 0.30
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10
    readonly property real pointSizeHeader: pointSize * 1.25

    // make current output path commonly accessible / set by combo target drive
    readonly property alias selectedMountPath: mountedDrivesCombo.currentPath
    onSelectedMountPathChanged: {
        callRpcSearchCustomerImportPaths()
    }

    // Import/export RPC business
    property var rpcIdCopyDirs
    property var rpcIdFindImportCustomertDataPaths
    property var customerImportDirList: []
    // RPC_CopyDirFiles handling
    function callRpcCopyDirFiles(sourcePath, destPath, cleanDestPath, overwrite) {
        // Note: modelIndexArrayToGetInfo is assumed not empty
        if(!rpcIdCopyDirs) {
            rpcIdCopyDirs = filesEntity.invokeRPC("RPC_CopyDirFiles(bool p_cleanDestFirst,QString p_destDir,QStringList p_nameFilters,bool p_overwrite,QString p_sourceDir)", {
                                                  "p_sourceDir": sourcePath,
                                                  "p_destDir": destPath,
                                                  "p_nameFilters": [ "*.json" ],
                                                  "p_cleanDestFirst": cleanDestPath,
                                                  "p_overwrite": overwrite})
        }
    }
    // RPC_FindFileSpecial handling
    function callRpcSearchCustomerImportPaths() {
        customerImportDirList = []
        if(!rpcIdFindImportCustomertDataPaths) {
            rpcIdFindImportCustomertDataPaths = filesEntity.invokeRPC("RPC_FindFileSpecial(QString p_baseDir,QStringList p_nameFilterList,bool p_returnMatchingDirsOnly)", {
                                                                      "p_baseDir": selectedMountPath,
                                                                      "p_nameFilterList": [ "zera-*-?????????", "customerdata", "*.json" ],
                                                                      "p_returnMatchingDirsOnly": true})
        }
    }

    Connections {
        target: filesEntity
        onSigRPCFinished: {
            // TODO error handling
            if(t_identifier === rpcIdCopyDirs) {
                rpcIdCopyDirs = undefined
                if(t_resultData["RemoteProcedureData::resultCode"] === 0 &&
                        t_resultData["RemoteProcedureData::Return"] === true) { // ok
                    if(importCustomerDataPopup.visible) {
                        importCustomerDataPopup.close()
                    }
                }
            }
            else if(t_identifier === rpcIdFindImportCustomertDataPaths) {
                if(t_resultData["RemoteProcedureData::resultCode"] === 0) {
                    customerImportDirList = t_resultData["RemoteProcedureData::Return"]
                }
            }
        }
    }

    CustomerDataNewPopup {
        id: customerDataNewPopup
    }

    Popup {
        id: importCustomerDataPopup
        anchors.centerIn: parent
        width: parent.width * 9/10
        modal: true
        ColumnLayout {
            anchors.fill: parent
            Label { // header
                text: Z.tr("Import customer data files")
                font.pointSize: pointSizeHeader
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            RowLayout { // device selection
                Label {
                    text: Z.tr("Device export found:")
                    font.pointSize: pointSize
                }
                Item { Layout.preferredWidth: GC.standardTextHorizMargin }
                ComboBox {
                    id: deviceImportCombo
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                    model: {
                        var myModel = []
                        for(var modelLoop=0; modelLoop<customerImportDirList.length; ++modelLoop) {
                            // * we can rely on no trailing dir separator
                            // * format is: <some-leading-path>/zera-<dev-type>-<serno>/customerdata
                            var currPath = customerImportDirList[modelLoop]
                            var pathArray = currPath.split('/')
                            if(pathArray.length>=2) {
                                myModel.push(pathArray[pathArray.length-2])
                            }
                        }
                        return myModel
                    }
                }
            }
            CheckBox {
                id: importDeleteCheckbox
                text: Z.tr("Delete current files first")
                font.pointSize: pointSize * 2/3
            }
            CheckBox {
                id: importOverwriteCheckbox
                text: Z.tr("Overwrite current files with imported ones")
                font.pointSize: pointSize * 2/3
                enabled: !importDeleteCheckbox.checked
            }
            RowLayout { // Cancel/Ok buttons
                Layout.fillWidth: true
                Item {
                    Layout.fillWidth: true
                }
                Button {
                    id: importCancel
                    text: Z.tr("Cancel")
                    font.pointSize: pointSize
                    onClicked: {
                        importCustomerDataPopup.close()
                    }
                }
                Button {
                    text: Z.tr("OK")
                    font.pointSize: pointSize
                    Layout.preferredWidth: importCancel.width
                    onClicked: {
                        var sourcePath = customerImportDirList[deviceImportCombo.currentIndex]
                        if(sourcePath !== "") {
                            callRpcCopyDirFiles(sourcePath,
                                                filesEntity.CustomerDataLocalPath,
                                                importDeleteCheckbox.checked,
                                                importOverwriteCheckbox.checked)
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: removeFilePopup
        anchors.centerIn: parent
        modal: true
        property string fileName;

        ColumnLayout {
            Label { // header
                text: Z.tr("Delete customer data file")
                font.pointSize: pointSizeHeader
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            Label {
                text: Z.tr("Please confirm that you want to delete <b>'%1'</b>").arg(removeFilePopup.fileName)
                Layout.fillWidth: true
                font.pointSize: pointSize
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                Button {
                    id: removeCancel
                    text: Z.tr("Cancel")
                    font.pointSize: pointSize
                    onClicked: {
                        removeFilePopup.close()
                    }
                }
                Button {
                    text: "<font color='red'>" + Z.tr("OK") + "</font>"
                    font.pointSize: pointSize
                    Layout.preferredWidth: removeCancel.width
                    onClicked: {
                        customerData.invokeRPC("customerDataRemove(QString fileName)", { "fileName": removeFilePopup.fileName });
                        removeFilePopup.close();
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
            width: parent.width - (lvFileBrowser.contentHeight > lvFileBrowser.height ? 8 : 0) // don't overlap with the ScrollIndicator
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
                customerDataNewPopup.open()
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
            enabled: mountedPaths.length > 0 && !rpcIdCopyDirs && customerImportDirList.length > 0
            onClicked: {
                importCustomerDataPopup.open()
            }
        }
        Button {
            text: Z.tr("Export")
            font.pointSize: pointSize
            enabled: mountedPaths.length > 0 && !rpcIdCopyDirs && availableCustomerDataFiles.length > 0
            onClicked: {
                callRpcCopyDirFiles(filesEntity.CustomerDataLocalPath, stickImportExportPath, true, false)
            }
        }
    }

}
