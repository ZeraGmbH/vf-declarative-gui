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
import "../../helpers"
import ".."

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
    readonly property string stickImportExportPath: mountedDrivesCombo.currentPath + '/' + GC.deviceName + '/customerdata'

    property real rowHeight: height/8
    readonly property real fontScale: 0.30
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10
    readonly property real pointSizeHeader: pointSize * 1.25

    // make current output path commonly accessible / set by combo target drive
    readonly property alias selectedMountPath: mountedDrivesCombo.currentPath
    onSelectedMountPathChanged: {
        tasksSearchCustomerImportPaths.startRun()
    }

    // Import/export RPC business
    property var customerImportDirList: []

    TaskList {
        id: tasksSearchCustomerImportPaths
        taskArray: [
            { 'type': 'rpc',  // search paths
              'callFunction': () => filesEntity.invokeRPC("RPC_FindFileSpecial(QString p_baseDir,QStringList p_nameFilterList,bool p_returnMatchingDirsOnly)", {
                                                              "p_baseDir": selectedMountPath,
                                                              "p_nameFilterList": [ "zera-*-?????????", "customerdata", "*.json" ],
                                                              "p_returnMatchingDirsOnly": true}),
              'notifyCallback': (t_resultData) => {
                    let ok = t_resultData["RemoteProcedureData::resultCode"] === 0
                    if(ok) {
                        customerImportDirList = t_resultData["RemoteProcedureData::Return"]
                    }
                    return true
              },
              'rpcTarget': filesEntity
            }
        ]
    }
    WaitTransaction {
        id: waitPopup
        animationComponent: AnimationSlowBits { }
    }
    TaskList {
        id: tasksExport
        taskArray: [
            { 'type': 'rpc',  // copy
              'callFunction': () => filesEntity.invokeRPC("RPC_CopyDirFiles(bool p_cleanDestFirst,QString p_destDir,QStringList p_nameFilters,bool p_overwrite,QString p_sourceDir)", {
                                                              "p_sourceDir": filesEntity.CustomerDataLocalPath,
                                                              "p_destDir": stickImportExportPath,
                                                              "p_nameFilters": [ "*.json" ],
                                                              "p_cleanDestFirst": true,
                                                              "p_overwrite": false}),
              'rpcTarget': filesEntity
            },
            { 'type': 'rpc',  // fsync
              'callFunction': () => filesEntity.invokeRPC("RPC_FSyncPath(QString p_fullPath)", {
                                                              "p_fullPath": stickImportExportPath}),
              'rpcTarget': filesEntity
            }
        ]
        Connections {
            onDone: {
                importCustomerDataPopup.close()
                let errorDescriptionArr = []
                if(error) {
                    errorDescriptionArr.push(Z.tr("Copy failed - drive full or removed?"))
                }
                waitPopup.stopWait([], errorDescriptionArr, null)
            }
        }
    }
    TaskList {
        id: tasksImport
        taskArray: [
            { 'type': 'rpc',  // copy
              'callFunction': () => filesEntity.invokeRPC("RPC_CopyDirFiles(bool p_cleanDestFirst,QString p_destDir,QStringList p_nameFilters,bool p_overwrite,QString p_sourceDir)", {
                                                              "p_sourceDir": customerImportDirList[deviceImportCombo.currentIndex],
                                                              "p_destDir": filesEntity.CustomerDataLocalPath,
                                                              "p_nameFilters": [ "*.json" ],
                                                              "p_cleanDestFirst": importDeleteCheckbox.checked,
                                                              "p_overwrite": importOverwriteCheckbox.checked}),
              'rpcTarget': filesEntity
            }
        ]
        Connections {
            onDone: {
                importCustomerDataPopup.close()
                let errorDescriptionArr = []
                if(error) {
                    errorDescriptionArr.push(Z.tr("Import failed - drive removed?"))
                }
                waitPopup.stopWait([], errorDescriptionArr, null)
            }
        }
    }

    CustomerDataNewPopup {
        id: customerDataNewPopup
    }

    Popup {
        id: importCustomerDataPopup
        anchors.centerIn: parent
        width: parent.width
        modal: true
        ColumnLayout {
            anchors.fill: parent
            Label { // header
                text: Z.tr("Import customer data")
                font.pointSize: pointSizeHeader
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            RowLayout { // device selection
                Label {
                    text: Z.tr("Files found from device:")
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
                Layout.fillWidth: true
            }
            CheckBox {
                id: importOverwriteCheckbox
                text: Z.tr("Overwrite current files with imported ones")
                font.pointSize: pointSize * 2/3
                Layout.fillWidth: true
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
                        if(customerImportDirList[deviceImportCombo.currentIndex] !== "") {
                            waitPopup.startWait(Z.tr("Importing customer data..."))
                            tasksImport.startRun()
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
                text: Z.tr("Confirmation")
                font.pointSize: pointSizeHeader
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            Label {
                text: Z.tr("Delete <b>'%1'</b>?").arg(removeFilePopup.fileName)
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
                    text: "<font color='red'>" + Z.tr("Delete") + "</font>"
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
        text: Z.tr("Customer data")
        font.pointSize: pointSizeHeader
    }
    Rectangle {
        color: Material.dialogColor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.top: captionLabel.bottom
        anchors.topMargin: rowHeight / 2
        anchors.bottom: buttonRow.top
        ListView {
            id: lvFileBrowser
            anchors.fill: parent
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
                width: parent.width - (lvFileBrowser.contentHeight > lvFileBrowser.height ? 8 : 0) // don't overlap with the ScrollIndicator
                height: rowHeight
                RowLayout {
                    id: fileRow
                    anchors.fill: parent
                    anchors.leftMargin: GC.standardTextHorizMargin
                    Label {
                        text: modelData
                        Layout.fillWidth: true
                        font.pointSize: pointSize
                    }
                    Button {
                        Layout.preferredWidth: rowHeight * 2
                        Layout.fillHeight: true
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
            enabled: mountedPaths.length > 0 && !tasksImport.running && customerImportDirList.length > 0
            onClicked: {
                importCustomerDataPopup.open()
            }
        }
        Button {
            text: Z.tr("Export")
            font.pointSize: pointSize
            enabled: mountedPaths.length > 0 && !tasksExport.running && availableCustomerDataFiles.length > 0
            onClicked: {
                waitPopup.startWait(Z.tr("Exporting customer data..."))
                tasksExport.startRun()
            }
        }
    }

}
