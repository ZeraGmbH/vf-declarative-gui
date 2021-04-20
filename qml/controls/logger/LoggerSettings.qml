import QtQuick 2.5
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraTranslationBackend  1.0
import ZeraLocale 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
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
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property string currentDbFile: loggerEntity.DatabaseFile

    property bool fetchOnDbSet: false
    onCurrentDbFileChanged: {
        GC.setCurrDatabaseFileName(currentDbFile)
        GC.setCurrDatabaseSessionName("")
        if(fetchOnDbSet && currentDbFile !== "") {
            fetchOnDbSet = false
            startRpcSearch()
        }
        else {
            selectorDelayHelper.restart()
        }
    }
    Timer {
        id: selectorDelayHelper
        interval: 300; repeat: false
        onTriggered: {
            lvFileBrowser.currentIndex = foundFiles.indexOf(currentDbFile)
        }
    }
    Timer {
        id: currentDbSizePollTimer
        interval: 1000; repeat: true
        onTriggered: {
            if(currentDbFile !== "") {
                startRpcFileInfo(currentDbFile)
            }
            else {
                stop()
            }
        }
    }
    // I love it...
    property QtObject filesEntity: VeinEntity.getEntity("_Files")

    ListModel { // entries synced to foundFiles
        id: fileListModel
    }

    // RPC_FindFileSpecial caller++
    property var searchRpcId;
    property var foundFiles: [] // we full file names (and searching in ListModel is pain)
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

    // RPC_GetFileInfo caller++
    property var fileInfoRpcIds: []
    function startRpcFileInfo(fileName) {
        var fileInfoRpcID = filesEntity.invokeRPC("RPC_GetFileInfo(QString p_fileName,QString p_localeName)", {
                                                  "p_fileName": fileName,
                                                  "p_localeName": ZLocale.localeName})
        // we allow multiple calls at the same time - make things a lot easier
        fileInfoRpcIds.push(fileInfoRpcID)
    }

    // RPC_FindFileSpecial caller++
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

    // common helpers
    function fullNewDbName() {
        return dbLocationSelector.currentPath +'/'+ filenameField.text.toLowerCase()+".db"
    }
    function fileName(strFileWithPath) {
        var strFile = strFileWithPath.replace(dbLocationSelector.currentPath, "")
        if(strFile.startsWith('/')) {
            strFile = strFile.substring(1)
        }
        return strFile
    }

    // vf-files RPC responses
    Connections {
        target: filesEntity
        onSigRPCFinished: {
            // TODO error handling
            var idxFound = -1
            var fileIdx
            if(t_identifier === deleteRpcId) {
                deleteRpcId = undefined
                if(t_resultData["RemoteProcedureData::resultCode"] === 0 &&
                        t_resultData["RemoteProcedureData::Return"] === true) { // ok
                    // Update model without researching - we trust RPC
                    var delIdx = foundFiles.indexOf(removeDbPopup.removeDbName)
                    if(delIdx >= 0) {
                        foundFiles.splice(delIdx, 1)
                        fileListModel.remove(delIdx, 1)
                    }
                    // we're done
                    removeDbPopup.close();
                }
            }
            else if(t_identifier === searchRpcId) {
                searchRpcId = undefined
                if(t_resultData["RemoteProcedureData::resultCode"] === 0) {
                    foundFiles = t_resultData["RemoteProcedureData::Return"]
                    // start full search / init size-info
                    fileListModel.clear()
                    for(fileIdx=0; fileIdx<foundFiles.length; ++fileIdx ) {
                        fileListModel.set(fileIdx, {"name" : fileName(foundFiles[fileIdx]), "size" : ""})
                        // start get size (yes starting multiple RPCs makes things a lot easier)
                        startRpcFileInfo(foundFiles[fileIdx])
                    }
                    selectorDelayHelper.restart()
                }
            }
            else if((idxFound = fileInfoRpcIds.indexOf(t_identifier)) >= 0) {
                fileInfoRpcIds.splice(idxFound, 1)
                if(t_resultData["RemoteProcedureData::resultCode"] === 0) {
                    // extract p_fileName / size info returned
                    var paramFileName = ""
                    var sizeStr = ""
                    for(var loopResult=0; loopResult<t_resultData["RemoteProcedureData::Return"].length; ++loopResult) {
                        var partialInfo = t_resultData["RemoteProcedureData::Return"][loopResult]
                        if(partialInfo.startsWith("p_fileName:")) {
                            paramFileName = partialInfo.replace("p_fileName:", "").trim()
                        }
                        else if(partialInfo.startsWith("size:")) {
                            sizeStr = partialInfo.replace("size:", "").trim()
                        }
                    }
                    // append file sizes to display
                    fileIdx = foundFiles.indexOf(paramFileName)
                    if(fileIdx >= 0 && sizeStr !== "") {
                        fileListModel.set(fileIdx, {"name" : fileName(foundFiles[fileIdx]), "size" : sizeStr})
                    }
                    // on return of last size info / start size poll timer for current db
                    if(fileInfoRpcIds.length === 0) {
                        currentDbSizePollTimer.restart()
                    }
                }
            }
        }
    }

    // New DB popup
    Popup {
        id: newDbPopup
        parent: Overlay.overlay
        width: parent.width
        height: parent.height - GC.vkeyboardHeight
        modal: !Qt.inputMethod.visible
        closePolicy: Popup.NoAutoClose
        onOpened: filenameField.forceActiveFocus()
        onClosed: filenameField.clear()
        function startAddDb() {
            loggerEntity.DatabaseFile = fullNewDbName()
            fetchOnDbSet = true
            close()
        }
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
            anchors.bottom: okCancelRow.top
            Label {
                text: Z.tr("File name:")
                font.pointSize: pointSize
                height: rowHeight
            }
            // No ZLineEdit due to different RETURN/ESC/redBackground handling
            TextField {
                id: filenameField
                validator: RegExpValidator { regExp: /\b[_a-z0-9][_\-a-z0-9]*\b/ }
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
                    visible: fileNameAlreadyExists || !filenameField.acceptableInput
                }
                onAccepted: {
                    newDbPopup.startAddDb()
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
            id: okCancelRow
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
                    newDbPopup.startAddDb()
                }
            }
        }
    }

    // Delete DB confirmation popup
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
            Label { // "do you really want to delete" text
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
            RowLayout { // OK/Cancel (more or less)
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

    // The SettingsView
    model: ObjectModel {
        Column {
            spacing: root.rowHeight / 20
            Label { // Header
                text: Z.tr("Database Logging")
                width: root.rowWidth;
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: root.pointSizeHeader
            }
            RowLayout { // Statusline
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
            LoggerDbLocationSelector { // stick(s)/local selector
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
            Rectangle { // List of databases
                height: root.rowHeight * 4
                width: root.rowWidth
                color: Material.dialogColor
                ListView {
                    id: lvFileBrowser
                    anchors.fill: parent
                    clip: true
                    model: fileListModel
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
                        property bool isCurrentDb: foundFiles[index] === currentDbFile

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
                                    var strDisplay = name
                                    if(size !== "") {
                                        strDisplay += " / " + size
                                    }
                                    return strDisplay
                                }
                                font.pointSize: pointSize
                                Layout.fillWidth: true
                            }
                            Button { // Eject / make current
                                font.family: FA.old
                                font.pointSize: pointSize * 1.25
                                text: dbListDelegate.isCurrentDb ? FA.fa_eject : FA.fa_check_circle
                                enabled: loggerEntity.LoggingEnabled === false
                                background: Rectangle {
                                    color: "transparent"
                                }
                                onClicked: {
                                    var nextDb = dbListDelegate.isCurrentDb ? "" : foundFiles[index]
                                    loggerEntity.DatabaseFile = nextDb
                                }
                            }
                            Button { // delete
                                Layout.preferredWidth: rowHeight * 2
                                Layout.fillHeight: true
                                font.family: FA.old
                                font.pointSize: pointSize * 1.25
                                text: FA.fa_trash
                                enabled: foundFiles[index] !== currentDbFile || loggerEntity.LoggingEnabled === false
                                background: Rectangle {
                                    color: "transparent"
                                }
                                onClicked: {
                                    removeDbPopup.removeDbName = foundFiles[index]
                                    removeDbPopup.open()
                                }
                            }
                        }
                        onClicked: {
                            // just select current
                            if(!dbListDelegate.isCurrentDb) {
                                loggerEntity.DatabaseFile = foundFiles[index]
                            }
                        }
                    }
                }
            }

            RowLayout { // add new button (only)
                height: root.rowHeight;
                width: root.rowWidth;
                Button {
                    text: "+"
                    enabled: loggerEntity.LoggingEnabled === false
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
                    enabled: scheduledLogging.checked
                }
                ZLineEdit {
                    id: durationField

                    // overrides
                    function doApplyInput(newText) {
                        GC.setLoggingDuration(FT.timeToMs(newText))
                        // wait to be applied
                        return true
                    }
                    function transformIncoming(t_incoming) {
                        return FT.msToTime(t_incoming);
                    }
                    function hasValidInput() {
                        var regex = /(?!^00:00:00$)[0-9][0-9]:[0-5][0-9]:[0-5][0-9]/
                        return regex.test(textField.text)
                    }
                    text: FT.msToTime(GC.loggingDuration)
                    inputMethodHints: Qt.ImhPreferNumbers
                    height: root.rowHeight
                    pointSize: root.pointSize
                    width: 280
                    enabled: scheduledLogging.checked && loggerEntity.LoggingEnabled === false

                }
                CheckBox {
                    id: scheduledLogging
                    height: parent.height
                    enabled: loggerEntity.LoggingEnabled === false
                    onCheckStateChanged: {
                        GC.setScheduledLogging(checked)
                    }
                    checked: GC.scheduledLogging
                }
                Label {
                    visible: loggerEntity.LoggingEnabled === true && loggerEntity.ScheduledLoggingEnabled === true
                    font.pointSize: root.pointSize
                    property string countDown: FT.msToTime(loggerEntity.ScheduledLoggingCountdown);
                    height: root.rowHeight
                    text: countDown;
                }
            }
        }
    }
}
