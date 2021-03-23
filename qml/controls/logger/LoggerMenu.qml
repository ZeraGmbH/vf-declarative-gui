import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import GlobalConfig 1.0
import FunctionTools 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraFa 1.0

Item {
    id: root
    // external
    property real pointSize: 16
    function open() {
        var oldPersitenceDone = GC.dbPersitenceDone
        GC.dbPersitenceDone = true
        // Support users: in case there is no database available:
        // * do not show menu
        // * open to settings immediately
        if(loggerEntity.DatabaseReady !== true) {
            if(!oldPersitenceDone && loggerEntity.DatabaseFile === "" && GC.currDatabaseFileName !== "") {
                loggerEntity.DatabaseFile = GC.currDatabaseFileName
                if(GC.currDatabaseSessionName !== "") {
                    setSessionNameForPersitence = true
                }
                return menu.open()
            }
            else {
                loggerSettingsMenu()
            }
        }
        else{
            return menu.open()
        }
    }

    signal loggerSettingsMenu()
    signal loggerSessionsMenu(var loggerEntity)
    signal loggerCustomDataMenu()
    signal loggerExportMenu()
    // internal
    property bool snapshotTrigger: false;
    property bool startLoggingAfterSessionSelect: false
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property QtObject systemEntity: VeinEntity.getEntity("_System")
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")
    property bool setSessionNameForPersitence: false
    readonly property string databaseFile: loggerEntity.DatabaseFile
    onDatabaseFileChanged: {
        if(setSessionNameForPersitence && databaseFile !== "") {
            loggerEntity.sessionName = GC.currDatabaseSessionName
        }
        setSessionNameForPersitence = false
    }

    property int veinResponsesRequired: 0
    function handleVeinRecordingStartReply() {
        if(veinResponsesRequired > 0) {
            --veinResponsesRequired
            if(veinResponsesRequired === 0) { // vein has accepted everything?
                loggerEntity.LoggingEnabled = true
            }
        }
    }

    // Vein reports contentSets changed by change of LoggedComponents
    readonly property var loggedComponents: systemEntity.LoggedComponents
    onLoggedComponentsChanged: { handleVeinRecordingStartReply() }

    readonly property var vtransactionName: loggerEntity.transactionName
    onVtransactionNameChanged: { handleVeinRecordingStartReply() }

    readonly property var vguiContext: loggerEntity.guiContext
    onVguiContextChanged: { handleVeinRecordingStartReply() }

    readonly property string sessionNameLogger: loggerEntity.sessionName !== undefined ? loggerEntity.sessionName : ""

    function takeSnapshot(){
        var dateTime = new Date();
        var strDbContentSets = GC.dbContentSetsFromContext(GC.currentGuiContext)
        var transactionName = (snapshotTrigger ? "Snapshot" : "Recording") + "_" + Qt.formatDateTime(dateTime, "yyyy_MM_dd_hh_mm_ss")
        var type = loggerEntity.ENUM_LogType["snapshot"]
        var guiContext = GC.currentGuiContext.name;
        var dbContentSetArrWanted = strDbContentSets.split(',');
        var dbContentSetToSetArr = [];
        for(var currSetIdx in dbContentSetArrWanted) {
            if(loggerEntity.availableContentSets && loggerEntity.availableContentSets.includes(dbContentSetArrWanted[currSetIdx])) {
                dbContentSetToSetArr.push(dbContentSetArrWanted[currSetIdx])
            }
            else {
                if(strContentSetsNotFound !== "") {
                    strContentSetsNotFound += ", "
                }
                strContentSetsNotFound += dbContentSetArrWanted[currSet]
            }
        }
        loggerEntity.invokeRPC("RPC_startLogging(QStringList p_contentSets,float p_duration,QString p_guiContext,ENUM_LogType p_logType,QString p_transaction)",
                               {
                                   "p_contentSets" : dbContentSetToSetArr,
                                   "p_guiContext": guiContext,
                                   "p_duration" : 0,
                                   "p_logType" : type,
                                   "p_transaction" : transactionName

                               });
    }

    function startLogging() {
        var dateTime = new Date();
        var strDbContentSets = GC.dbContentSetsFromContext(GC.currentGuiContext)
        var transactionName = (snapshotTrigger ? "Snapshot" : "Recording") + "_" + Qt.formatDateTime(dateTime, "yyyy_MM_dd_hh_mm_ss")
        var type = loggerEntity.ENUM_LogType["startStop"]
        var guiContext = GC.currentGuiContext.name;
        var dbContentSetArrWanted = strDbContentSets.split(',');
        var dbContentSetToSetArr = [];
        for(var currSetIdx in dbContentSetArrWanted) {
            if(loggerEntity.availableContentSets && loggerEntity.availableContentSets.includes(dbContentSetArrWanted[currSetIdx])) {
                dbContentSetToSetArr.push(dbContentSetArrWanted[currSetIdx])
            }
            else {
                if(strContentSetsNotFound !== "") {
                    strContentSetsNotFound += ", "
                }
                strContentSetsNotFound += dbContentSetArrWanted[currSet]
            }
        }
        loggerEntity.invokeRPC("RPC_startLogging(QStringList p_contentSets,float p_duration,QString p_guiContext,ENUM_LogType p_logType,QString p_transaction)",
                               {
                                   "p_contentSets" : dbContentSetToSetArr,
                                   "p_guiContext": guiContext,
                                   "p_duration" : 0,
                                   "p_logType" : type,
                                   "p_transaction" : transactionName

                               });
    }

    function stopLogging(){
        loggerEntity.invokeRPC("RPC_stopLogging(QList<int> p_transaction)",
                               {
                                "p_transaction" : []
                               });
    }

    // Snapshot is implemented as logging enable on / off
    // TODO: we MUST-MUST-MUST!!! rework this
    readonly property bool logEnabled: loggerEntity.LoggingEnabled
    onLogEnabledChanged: {
        if(logEnabled && snapshotTrigger) {
            snapshotTrigger = false;
            // causes warning about property loop so use the timer as workaround
            //loggerEntity.LoggingEnabled = false;
            propertyLoopAvoidingLoggingEnabledTimer.start();
        }
    }
    Timer {
        id: propertyLoopAvoidingLoggingEnabledTimer
        interval: 0
        repeat: false
        onTriggered: {
            loggerEntity.LoggingEnabled = false
        }
    }
    // Endof TODO


    ButtonGroup {
        id: radioMenuGroup
        property string customContentSets: GC.getLoggerCustomContentSets()
        property int contentTypeRadioToSet
        function checkRadiosFromSettings() {
            var radioChecked = false
            var radioContextSpecific
            for(var idx=0; idx<buttons.length; ++idx) {
                var radio = buttons[idx]
                var contentTypeRadioToSet = radio.enumContentType
                // all menus have a context specific entry - keep it as fallback
                if(contentTypeRadioToSet === GC.contentTypeEnum.CONTENT_TYPE_CONTEXT) {
                    radioContextSpecific = radio
                }
                if(contentTypeRadioToSet === GC.loggerContentType) {
                    radio.checked = true
                    radioChecked = true
                    break;
                }
            }
            // in case current context does not have last selected
            // menu entry: select fallback
            if(!radioChecked && radioContextSpecific) {
                radioContextSpecific.checked = true
            }
        }
        onClicked: {
            GC.setLoggerContentType(checkedButton.enumContentType)
        }
    }

    // menu with logger operations
    Menu {
        id: menu
        font.family: FA.old
        font.pointSize: root.pointSize
        FontMetrics {
            id: fontMetrics
            font: menu.font
        }
        width: {
            var maxWidth = 0
            // iterate menu items
            for(var i = 0; i < count; ++i) {
                var item = itemAt(i);
                var linewidth
                if("menuRadio" in item && "menuButton" in item) {
                    var radioTxt = item.menuRadio.text
                    var radioTextWidth = fontMetrics.height /*button*/ + fontMetrics.advanceWidth(radioTxt) /* text */
                    var menuButton = item.menuButton
                    linewidth =
                            radioTextWidth + 2*item.padding +
                            (menuButton.visible ? menuButton.width+GC.standardTextHorizMargin : 0)
                }
                else if("rightAlignedLabel" in item) {
                    var lblTxt = item.rightAlignedLabel.text.replace(/<[^>]*>/g, '') // no HTML text
                    var lblTextWidth = fontMetrics.advanceWidth(lblTxt)
                    linewidth =
                            item.contentItem.implicitWidth + 2*item.padding +
                            lblTextWidth + GC.standardTextHorizMargin
                }
                else {
                    linewidth = item.contentItem.implicitWidth + 2*item.padding
                }
                maxWidth = Math.max(maxWidth, linewidth)
            }
            return maxWidth
        }
        onAboutToShow: {
            // Under some conditions updating javascript arrays do not cause a binded
            // property to update [1]. So to avoid surprises assign model for dynamic
            // part of menu each time menu openes
            // [1] https://github.com/schnitzeltony/dyn-menu-qml/blob/master/main.qml
            instantiatorContentSelectorMenu.model = GC.getDefaultDbContentSetLists(GC.currentGuiContext)

            radioMenuGroup.checkRadiosFromSettings()
        }
        MenuItem { // current session name (pos 0)
            text: {
                // No database cannot happen here: We force move to settings in open()
                var menuText = ""
                if(sessionNameLogger === "") {
                    menuText = Z.tr("-- no session --")
                }
                else {
                    menuText = loggerEntity.sessionName
                }
                return FA.icon(FA.fa_folder_open) + menuText
            }
            onTriggered: {
                startLoggingAfterSessionSelect = false
                loggerSessionsMenu(loggerEntity)
            }
            enabled: loggerEntity.LoggingEnabled !== true &&
                     loggerEntity.DatabaseReady === true
        }
        MenuSeparator { } // (pos 1)
        Instantiator { // dynamic part (currently context/all/custom) - injected before position 2
            id: instantiatorContentSelectorMenu
            delegate: MenuItem {
                property alias menuRadio: dynRadio
                property alias menuButton: dynButton
                enabled: loggerEntity.LoggingEnabled !== true
                RadioButton {
                    id: dynRadio
                    anchors.fill: parent
                    text: Z.tr("Menu" + modelData) // prepend 'Menu' for translation
                    readonly property int enumContentType: {
                        var contentType = GC.contentTypeEnum.CONTENT_TYPE_CONTEXT
                        switch(modelData) {
                        case "ZeraAll":
                            contentType = GC.contentTypeEnum.CONTENT_TYPE_ALL
                            break;
                        case "ZeraCustom":
                            contentType = GC.contentTypeEnum.CONTENT_TYPE_CUSTOM
                            break;
                        }
                        return contentType
                    }
                    // Now that GC.getLoggerCustomContentSets() returns at least
                    // the content matching GUI context we can enable
                    // ZeraCustom radio always. Leave this commented - maybe we
                    // need to disable a radio later for other reasons
                    /*enabled: {
                        var isEnabled = true
                        switch(modelData) {
                        case "ZeraCustom":
                            isEnabled = GC.getLoggerCustomContentSets() !== ""
                            break
                        }
                        return isEnabled
                    }*/
                }
                Button {
                    id: dynButton
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: GC.standardTextHorizMargin

                    text: FA.fa_cogs
                    visible: {
                        var isVisible = false
                        switch(modelData) {
                        case "ZeraCustom":
                            isVisible = true
                            break
                        }
                        return isVisible
                    }
                    onClicked: {
                        switch(modelData) {
                        case "ZeraCustom":
                            loggerCustomDataMenu()
                            menu.close()
                            break
                        }
                    }
                }
            }
            onObjectAdded: {
                menu.insertItem(index + 2, object)
                radioMenuGroup.addButton(object.menuRadio)
            }
            onObjectRemoved: {
                menu.removeItem(object)
                // we cannot use radios attached property ButtonGroup.group
                // in dynamic menus: QML does not remove radio on remove so
                // we have to keep track of radioMenuGroup members. See also
                // onObjectAdded
                radioMenuGroup.removeButton(object.menuRadio)
            }
        }
        MenuSeparator { }
        MenuItem { // Snapshot
            text: FA.icon(FA.fa_camera) + Z.tr("Take snapshot")
            enabled: loggerEntity.LoggingEnabled === false &&
                     loggerEntity.DatabaseReady === true &&
                     !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined )
            onTriggered: {
                snapshotTrigger = true;
                if(sessionNameLogger !== "") {
                    takeSnapshot();
                }
                else {
                    startLoggingAfterSessionSelect = true
                    loggerSessionsMenu(loggerEntity)
                }
            }
        }
        MenuItem { // Start/Stop
            text: loggerEntity.LoggingEnabled === true ?
                      FA.icon(FA.fa_stop) + Z.tr("Stop logging") + (loggerEntity.ScheduledLoggingEnabled === true ?
                      (" " + FT.msToTime(loggerEntity.ScheduledLoggingCountdown)) : "") :
                      FA.icon(FA.fa_play) + Z.tr("Start logging")

            enabled: loggerEntity.DatabaseReady === true &&
                     (loggerEntity.LoggingEnabled === true ||
                     !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined ))
            onTriggered: {
                if(loggerEntity.LoggingEnabled !== true) { // Start
                    snapshotTrigger = false;
                    if(sessionNameLogger !== "") {
                        startLogging();
                    }
                    else {
                        startLoggingAfterSessionSelect = true
                        loggerSessionsMenu(loggerEntity);
                    }
                }
                else { // Stop
                    stopLogging();
                }
            }
        }
        MenuSeparator { }
        MenuItem { // Export
            text: FA.icon(FA.fa_save) + Z.tr("Export...")
            onTriggered: {
                loggerExportMenu()
            }
            enabled: filesEntity.AutoMountedPaths.length !== 0 &&
                     loggerEntity.LoggingEnabled === false &&
                     loggerEntity.DatabaseReady === true
        }

        MenuSeparator { }
        MenuItem { // Settings
            property alias rightAlignedLabel: raLabel
            text: FA.icon(FA.fa_cogs) + Z.tr("Settings...")
            Label {
                id: raLabel
                font: menu.font
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: GC.standardTextHorizMargin
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                text: {
                    var tmpArr = loggerEntity.DatabaseFile.split('/')
                    var dbName = tmpArr[tmpArr.length-1].replace('.db', '')
                    return FA.icon(FA.fa_database) + dbName
                }
            }
            onTriggered: {
                loggerSettingsMenu()
            }
        }
    }
}
