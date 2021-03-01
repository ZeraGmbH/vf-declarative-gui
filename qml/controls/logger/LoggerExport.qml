import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import VeinEntity 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0
import ZeraLocale 1.0
import "qrc:/qml/helpers" as HELPERS
import "qrc:/qml/controls" as CCMP

Item {
    id: root

    // we need a reference to menu stack layout to move around
    property var menuStackLayout

    // layout calculations
    readonly property real rowHeight: parent.height > 0 ? parent.height/8 : 10
    readonly property real fontScale: 0.3
    readonly property real pointSize: rowHeight*fontScale
    readonly property real pointSizeHeader: pointSize * 1.25

    readonly property real visibleWidth: parent.width - 2*GC.standardTextHorizMargin
    readonly property real labelWidth: visibleWidth / 4
    readonly property real contentWidth: visibleWidth * 3 / 4

    // vein entities
    /* Note: we discussed a while on this:
       Component _LoggingSystem.CustomerData contains the json filename the
       session was created with. The component was created during exporter
       implementation phase but it turned out later that it is useless here:
       exporter takes customer data from static data stored. There is no reason
       to touch CutomerData entity here. */
    property QtObject exportEntity: VeinEntity.getEntity("ExportModule") // our export worker
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem") // for databse/session...
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files") // mounted sticks
    // vein components for convenience
    readonly property string databaseName: loggerEntity ? loggerEntity.DatabaseFile : ""
    readonly property string sessionName: loggerEntity ? loggerEntity.sessionName : ""
    readonly property alias mountedPaths: mountedDrivesCombo.mountedPaths

    // make current export type commonly accessible / set by combo export type
    property string exportType
    // make current output path commonly accessible / set by combo target drive
    readonly property alias selectedMountPath: mountedDrivesCombo.currentPath
    // keep storage file path on demand on user activities
    property string targetFilePath : {
        var storagePath = selectedMountPath + '/' + GC.deviceName
        var fullPath = ""
        switch(exportType) {
        case "EXPORT_TYPE_MTVIS":
            fullPath = storagePath + "/exported-mtvis/" + editExportName.text
            break
        case "EXPORT_TYPE_SQLITE":
            fullPath = storagePath + "/exported-database/" + editExportName.text
            break
        }
        return fullPath
    }


    // 'enumerate' our export types
    readonly property var exportTypeEnum: {
        "EXPORT_TYPE_MTVIS": 0,
        "EXPORT_TYPE_SQLITE": 1,
    }

    // common helpers for MTVis / db export
    function dbAndDriveStillThere() {
        return databaseName !== "" && mountedPaths.includes(selectedMountPath) // db & drive still there
    }

    CCMP.WaitTransaction {
        id: waitPopup
        animationComponent: CCMP.AnimationSlowBits { }
    }

    // Tasklists
    HELPERS.TaskList {
        id: tasksExportMtVis
        readonly property string extraParams: "{'digits' : '%1', 'decimalPlaces' : '%2', 'local' : '%3'}".arg(GC.digitsTotal).arg(GC.decimalPlaces).arg(ZLocale.localeName)
        taskArray: [
            { 'type': 'block', // check
              'callFunction': () => dbAndDriveStillThere()
            },
            { 'type': 'rpc', // main.xml
              'callFunction': () => exportEntity.invokeRPC("RPC_Convert(QString p_engine,QString p_filter,QString p_inputPath,QString p_outputPath,QString p_parameters,QString p_session)", {
                                                               "p_session": sessionName,
                                                               "p_inputPath": databaseName,
                                                               "p_outputPath": targetFilePath + '/main.xml',
                                                               "p_engine": 'zeraconverterengines.MTVisMain',
                                                               /* This is a hack. We hope there is no transaction like: */
                                                               "p_filter" : "NoTransactionsNecessaryForMainXml",
                                                               "p_parameters": extraParams}),
              'rpcTarget': exportEntity
            },
            { 'type': 'block', // check
              'callFunction': () => dbAndDriveStillThere()
            },
            { 'type': 'rpc',  // result.xml
              'callFunction': () => exportEntity.invokeRPC("RPC_Convert(QString p_engine,QString p_filter,QString p_inputPath,QString p_outputPath,QString p_parameters,QString p_session)", {
                                                               "p_session": sessionName,
                                                               "p_inputPath": databaseName,
                                                               "p_outputPath": targetFilePath + '/result.xml',
                                                               "p_engine": 'zeraconverterengines.MTVisRes',
                                                               "p_filter" : "Snapshot",
                                                               "p_parameters": extraParams}),
              'rpcTarget': exportEntity
            },
            { 'type': 'rpc',  // fsync
              'callFunction': () => filesEntity.invokeRPC("RPC_FSyncPath(QString p_fullPath)", {
                                                              "p_fullPath": targetFilePath}),
              'rpcTarget': filesEntity
            }
        ]
        Connections {
            onDone: {
                let errorDescription = ""
                if(error) {
                    errorDescription = Z.tr("Export failed - drive removed?")
                }
                waitPopup.stopWait(errorDescription, () =>  menuStackLayout.pleaseCloseMe(false))
            }
        }
    }
    HELPERS.TaskList {
        id: tasksExportDb
        taskArray: [
            { 'type': 'block', // check
              'callFunction': () => dbAndDriveStillThere()
            },
            { 'type': 'rpc',  // copy
              'callFunction': () => filesEntity.invokeRPC("RPC_CopyFile(QString p_dest,bool p_overwrite,QString p_source)", {
                                                              "p_source": databaseName,
                                                              "p_dest": targetFilePath,
                                                              "p_overwrite": true }),
              'rpcTarget': filesEntity
            },
            { 'type': 'rpc',  // fsync
              'callFunction': () => filesEntity.invokeRPC("RPC_FSyncPath(QString p_fullPath)", {
                                                              "p_fullPath": targetFilePath}),
              'rpcTarget': filesEntity
            }
        ]
        Connections {
            onDone: {
                let errorDescription = ""
                if(error) {
                    errorDescription = Z.tr("Copy failed - drive removed?")
                }
                waitPopup.stopWait(errorDescription, () =>  menuStackLayout.pleaseCloseMe(false))
            }
        }
    }

    // and the visible items
    Label { // Header
        id: captionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Export stored data")
        font.pointSize: pointSizeHeader
        height: rowHeight
    }
    Column {
        id: selectionColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.top: captionLabel.bottom
        anchors.bottom: buttonExport.top
        Row { // Export type
            height: rowHeight
            Label {
                text: Z.tr("Export type:")
                width: labelWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                font.pointSize: pointSize
            }
            ComboBox {
                id: exportTypeCombo
                width: contentWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pointSize: root.pointSize
                currentIndex: loggerEntity.ExistingSessions.length > 0 ? 0 : 1
                model: {
                    var comboList = []
                    if(loggerEntity.ExistingSessions.length > 0) {
                        comboList.push({ value: "EXPORT_TYPE_MTVIS", enabled: true, label: Z.tr("MtVis XML") + (sessionName === "" ? "" : " (" +Z.tr("Session:") + " " + sessionName + ")") })
                    }
                    else {
                        comboList.push({ value: "EXPORT_TYPE_MTVIS", enabled: false, label: Z.tr("MtVis XML - requires stored sessions") })
                    }
                    comboList.push({ value: "EXPORT_TYPE_SQLITE", enabled: true, label: Z.tr("SQLite DB (complete)") })
                    return comboList
                }
                // we need a customized delegate to support enable/disable (and
                // to get default behaviour back it's more than just copying examples...)
                delegate: ItemDelegate {
                    width: exportTypeCombo.width
                    text: highlighted ? "<font color='" + Material.accentColor + "'>" + modelData.label + "</font>" : modelData.label
                    highlighted: modelData.value === exportTypeCombo.currentPath
                    enabled: modelData.enabled
                    font.pointSize: root.pointSize
                }
                textRole: "label"
                valueRole: "value"
                onCurrentIndexChanged: {
                    exportType = model[currentIndex].value // tried property binding but that did not work
                }
            }
        }
        Row { // Target drive (visible only if more than one drive is inserted)
            height: rowHeight
            visible: mountedPaths.length > 1
            Label {
                text: Z.tr("Target drive:")
                width: labelWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                font.pointSize: pointSize
            }
            MountedDrivesCombo {
                id: mountedDrivesCombo
                width: contentWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pointSize: root.pointSize
            }
        }
        Row { // Export Name
            height: rowHeight
            visible: exportType !== "EXPORT_TYPE_MTVIS" || sessionName !== ""
            Label {
                text: Z.tr("Export name:");
                width: labelWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                font.pointSize: pointSize
            }
            ZLineEdit {
                id: editExportName
                width: contentWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize
                textField.anchors.rightMargin: 0
                property alias aliasExportType: root.exportType
                property var regExCurr
                validator: RegExpValidator {
                    regExp: editExportName.regExCurr
                }
                onAliasExportTypeChanged: {
                    // Note on regexes:
                    // our target is windows most likely so to avoid trouble:
                    // * allow lower case only - Windows is not case sensitive
                    // * start with a letter
                    // * for MTVis: do not allow '.' for paths
                    switch(exportType) {
                    case "EXPORT_TYPE_MTVIS":
                        regExCurr = /\b[_a-z0-9][_\-a-z0-9]*\b/
                        // suggest sessionName (yes we need to ask for overwrite e.g for the cause
                        // of multiple storining of same session name in multiple dbs)
                        var sessionLow = sessionName.toLowerCase()
                        var jRegEx =  RegExp(regExCurr, 'g')
                        var match
                        var str = ""
                        // suggest only combinations od valid parts of session
                        while ((match = jRegEx.exec(sessionLow))) {
                            if(str !== "") {
                                str += '_'
                            }
                            str += match[0]
                        }
                        text = str
                        readOnly = sessionName === ""
                        placeholderText = Z.tr("Name of export path")
                        break
                    case "EXPORT_TYPE_SQLITE":
                        regExCurr = /\b[_a-z0-9][_\-a-z0-9]*.db\b/
                        text = databaseName.substr(databaseName.lastIndexOf('/') + 1).toLowerCase()
                        readOnly = true
                        placeholderText = ""
                        break
                    }
                }
            }
        }
        Button { // Quick link to select session from here
            height: rowHeight
            visible: exportType === "EXPORT_TYPE_MTVIS" && sessionName === ""
            id: buttonSessionSelect
            width: contentWidth
            anchors.right: parent.right
            text: Z.tr("Please select a session first...")
            font.pointSize: pointSize
            onClicked: {
                menuStackLayout.showSessionNameSelector()
            }
        }
    }
    Button { // the export 'action' button
        id: buttonExport
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        height: rowHeight
        text: Z.tr("Export")
        font.pointSize: pointSize
        enabled: {
            let _enabled = editExportName.hasValidInput() && mountedPaths.length > 0
            switch(exportType) {
            case "EXPORT_TYPE_MTVIS":
                _enabled = _enabled && !tasksExportMtVis.running && sessionName !== "" && databaseName !== ""
                break
            case "EXPORT_TYPE_SQLITE":
                _enabled = _enabled && !tasksExportDb.running && databaseName !== ""
                break
            }
            return _enabled
        }

        onClicked: {
            switch(exportType) {
            case "EXPORT_TYPE_MTVIS":
                waitPopup.startWait(Z.tr("Exporting MTVis XML..."))
                tasksExportMtVis.startRun()
                break
            case "EXPORT_TYPE_SQLITE":
                waitPopup.startWait(Z.tr("Exporting database..."))
                tasksExportDb.startRun()
                break
            }
        }
    }
}
