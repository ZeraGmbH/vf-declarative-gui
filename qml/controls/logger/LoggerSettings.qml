import QtQuick 2.5
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraTranslationBackend  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/controls/settings" as SettingsControls

SettingsControls.SettingsView {
    id: root
    // we need a reference to menu stack layout to move around
    property var menuStackLayout

    horizMargin: GC.standardTextHorizMargin
    rowHeight: parent.height/10

    readonly property real fontScale: 0.3
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10
    readonly property real pointSizeHeader: pointSize * 1.25

    readonly property bool fileNameAlreadyExists: filenameField.text.length>0 &&
                                                  foundFiles.indexOf(fullNewDbName()) >= 0
    property var searchRpcId;
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property string currentDbFile: loggerEntity.DatabaseFile
    onCurrentDbFileChanged: {
        GC.setCurrDatabaseFileName(currentDbFile)
        GC.setCurrDatabaseSessionName("")
        startRpcSearch()
    }
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")

    // RPC_FindFileSpecial handling
    property var foundFiles: []
    function startRpcSearch() {
        if(dbLocationSelector.currentPath != "") { // startup: location selector might still be loading
            if(!searchRpcId) {
                searchRpcId = filesEntity.invokeRPC("RPC_FindFileSpecial(QString p_baseDir,QStringList p_nameFilterList,bool p_returnMatchingDirsOnly)", {
                                                    "p_baseDir": dbLocationSelector.currentPath,
                                                    "p_nameFilterList": [ "*.db" ],
                                                    "p_returnMatchingDirsOnly": false})
            }
            else {
                console.warn("RPC_FindFileSpecial already running")
            }
        }
    }
    // RPC_FindFileSpecial handling
    property var deleteRpcId
    function startDbDeleteRpc(removeDbName) {
        if(!deleteRpcId) {
            // TODO: deleting current db causes db-status error
            // To workaround reset db if it's the current we want to delete
            if(removeDbName === currentDbFile) {
                loggerEntity.DatabaseFile = ""
            }
            deleteRpcId = filesEntity.invokeRPC("RPC_DeleteFile(QString p_fullPathFile)", {
                                                "p_fullPathFile": removeDbName })
        }
        else {
            console.warn("RPC_DeleteFile already running")
        }
    }
    function fullNewDbName() {
        return dbLocationSelector.currentPath +'/'+ filenameField.text.toLowerCase()+".db"
    }

    function startAddDb() {
        loggerEntity.DatabaseFile = fullNewDbName()
        newDbPopup.close()
    }

    Connections {
        target: filesEntity
        onSigRPCFinished: {
            // TODO error handling
            if(t_identifier === deleteRpcId) {
                deleteRpcId = undefined
                if(t_resultData["RemoteProcedureData::resultCode"] === 0 &&
                        t_resultData["RemoteProcedureData::Return"] === true) { // ok
                    // Update model without researching - we trust RPC
                    var tmpfoundFiles = foundFiles // splice on foundFiles does not cause redraw
                    var delIdx = tmpfoundFiles.indexOf(removeDbPopup.removeDbName)
                    if(delIdx >= 0) {
                        tmpfoundFiles.splice(delIdx, 1);
                        foundFiles = tmpfoundFiles
                    }
                    removeDbPopup.close();
                }
            }
            if(t_identifier === searchRpcId) {
                searchRpcId = undefined
                if(t_resultData["RemoteProcedureData::resultCode"] === 0) {
                    foundFiles = t_resultData["RemoteProcedureData::Return"]
                    lvFileBrowser.currentIndex = foundFiles.indexOf(currentDbFile)
                }
            }
        }
    }

    Popup {
        id: newDbPopup
        parent: Overlay.overlay
        width: parent.width
        height: parent.height - GC.vkeyboardHeight
        modal: !Qt.inputMethod.visible
        closePolicy: Popup.NoAutoClose
        onOpened: filenameField.forceActiveFocus()
        onClosed: filenameField.clear()
        Label { // Header
            id: captionLabelNewPopup
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            text: Z.tr("Create database")
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
                    visible: fileNameAlreadyExists
                }
                onAccepted: {
                    startAddDb()
                }
                Keys.onEscapePressed: {
                    newDbPopup.close()
                }
            }
            Label {
                text: ".db"
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
                    newDbPopup.close()
                }
            }
            Button {
                text: Z.tr("OK")
                font.pointSize: pointSize
                Layout.preferredWidth: newFileCancel.width
                enabled: filenameField.text.length>0 && fileNameAlreadyExists === false
                onClicked: {
                    startAddDb()
                }
            }
        }
    }

    Popup {
        id: removeDbPopup
        anchors.centerIn: parent
        modal: true
        property string removeDbName;

        ColumnLayout {
            Label { // header
                text: Z.tr("Confirmation")
                font.pointSize: pointSizeHeader
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            Label {
                text: {
                    var dbFileName = removeDbPopup.removeDbName.replace(dbLocationSelector.currentPath, "")
                    if(dbFileName.startsWith('/')) {
                        dbFileName = dbFileName.substring(1)
                    }
                    return Z.tr("Delete database <b>'%1'</b>?").arg(dbFileName)
                }
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
                        removeDbPopup.close()
                    }
                }
                Button {
                    text: "<font color='red'>" + Z.tr("Delete") + "</font>"
                    font.pointSize: pointSize
                    Layout.preferredWidth: removeCancel.width
                    onClicked: {
                        startDbDeleteRpc(removeDbPopup.removeDbName)
                    }
                }
            }
        }
    }

    model: ObjectModel {
        Column {
            spacing: root.rowHeight / 20
            Label {
                text: Z.tr("Database Logging")
                width: root.rowWidth;
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: root.pointSizeHeader
            }
            RowLayout {
                height: root.rowHeight;
                width: root.rowWidth;
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Logger status:")
                    font.pointSize: root.pointSize
                    Layout.fillWidth: true
                }
                Label { // exclamation mark if no database selected
                    font.family: FA.old
                    font.pointSize: root.pointSize
                    text: FA.fa_exclamation_triangle
                    color: Material.color(Material.Yellow)
                    visible: loggerEntity.DatabaseReady === false
                }
                Label {
                    text: Z.tr(loggerEntity.LoggingStatus)
                    font.pointSize: root.pointSize
                }
                BusyIndicator {
                    id: busyIndicator
                    implicitHeight: root.rowHeight
                    implicitWidth: height
                    visible: loggerEntity.LoggingEnabled
                }
            }
            LoggerDbLocationSelector {
                id: dbLocationSelector
                height: root.rowHeight;
                width: root.rowWidth;
                pointSize: root.pointSize
                onCurrentPathChanged: {
                    startRpcSearch()
                    if(currentDbFile !== "" && !currentDbFile.includes(currentPath)) {
                        // reset db on drive change
                        loggerEntity.DatabaseFile = ""
                    }

                }
            }
            Rectangle {
                height: root.rowHeight * 4
                width: root.rowWidth
                color: Material.dialogColor
                ListView {
                    id: lvFileBrowser
                    anchors.fill: parent
                    model: foundFiles
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
                        id: dbListDelegate
                        width: parent.width - (lvFileBrowser.contentHeight > lvFileBrowser.height ? 8 : 0) // don't overlap with the ScrollIndicator
                        property bool isCurrentDb: modelData === currentDbFile

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4

                            Label { // active indicator
                                id: activeIndicator
                                font.family: FA.old
                                font.pointSize: root.pointSize
                                horizontalAlignment: Text.AlignLeft
                                text: FA.fa_check
                                opacity: dbListDelegate.isCurrentDb ? 1.0 : 0.0
                                Layout.preferredWidth: root.pointSize * 1.5
                            }
                            Label { // db filename
                                text: {
                                    // basename
                                    var newText = String(modelData).replace(dbLocationSelector.currentPath, "")
                                    if(newText.startsWith('/')) {
                                        newText = newText.substring(1)
                                    }
                                    return newText
                                }
                                font.pointSize: pointSize
                                Layout.fillWidth: true
                            }
                            Button { // Eject / make current
                                font.family: FA.old
                                font.pointSize: pointSize * 1.25
                                text: dbListDelegate.isCurrentDb ? FA.fa_eject : FA.fa_check_circle
                                background: Rectangle {
                                    color: "transparent"
                                }
                                onClicked: {
                                    var nextDb = dbListDelegate.isCurrentDb ? "" : modelData
                                    loggerEntity.DatabaseFile = nextDb
                                }
                            }
                            Button { // delete
                                Layout.preferredWidth: rowHeight * 2
                                Layout.fillHeight: true
                                font.family: FA.old
                                font.pointSize: pointSize * 1.25
                                text: FA.fa_trash
                                background: Rectangle {
                                    color: "transparent"
                                }
                                onClicked: {
                                    removeDbPopup.removeDbName = modelData
                                    removeDbPopup.open()
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                height: root.rowHeight;
                width: root.rowWidth;
                Button {
                    text: "+"
                    onClicked: {
                        newDbPopup.open()
                    }
                }
            }
            RowLayout {
                height: root.rowHeight
                width: root.rowWidth;
                visible: VeinEntity.hasEntity("CustomerData")
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Manage customer data:")
                    font.pointSize: root.pointSize
                    Layout.fillWidth: true
                }
                Button {
                    text: FA.fa_cogs
                    font.family: FA.old
                    font.pointSize: root.pointSize
                    implicitHeight: root.rowHeight
                    enabled: loggerEntity.LoggingEnabled === false
                    onClicked: menuStackLayout.showCustomerDataBrowser()
                }
            }
            RowLayout {
                opacity: enabled ? 1.0 : 0.7
                height: root.rowHeight;
                width: root.rowWidth;
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Logging Duration [hh:mm:ss]:")
                    font.pointSize: root.pointSize
                    Layout.fillWidth: true
                    enabled: loggerEntity.ScheduledLoggingEnabled === true
                }
                VFLineEdit {
                    id: durationField

                    // overrides
                    function doApplyInput(newText) {
                        entity[controlPropertyName] = GC.timeToMs(newText)
                        // wait to be applied
                        return false
                    }
                    function transformIncoming(t_incoming) {
                        return GC.msToTime(t_incoming);
                    }
                    function hasValidInput() {
                        var regex = /(?!^00:00:00$)[0-9][0-9]:[0-5][0-9]:[0-5][0-9]/
                        return regex.test(textField.text)
                    }

                    entity: root.loggerEntity
                    controlPropertyName: "ScheduledLoggingDuration"
                    inputMethodHints: Qt.ImhPreferNumbers
                    height: root.rowHeight
                    pointSize: root.pointSize
                    width: 280
                    enabled: loggerEntity.ScheduledLoggingEnabled === true && loggerEntity.LoggingEnabled === false
                }
                VFSwitch {
                    id: scheduledLogging
                    height: parent.height
                    entity: root.loggerEntity
                    enabled: loggerEntity.LoggingEnabled === false
                    controlPropertyName: "ScheduledLoggingEnabled"
                }
                Label {
                    visible: loggerEntity.LoggingEnabled === true && loggerEntity.ScheduledLoggingEnabled === true
                    font.pointSize: root.pointSize
                    property string countDown: GC.msToTime(loggerEntity.ScheduledLoggingCountdown);
                    height: root.rowHeight
                    text: countDown;
                }
            }
        }
    }
}
