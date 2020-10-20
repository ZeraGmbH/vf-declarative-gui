import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import GlobalConfig 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraFa 1.0

Item {
    id: root
    // external
    property real pointSize: 16
    function open() {
        // Support users: in case there is no database available:
        // * do not show menu
        // * open to settings immediately
        if(loggerEntity.DatabaseReady !== true) {
            if(loggerEntity.DatabaseFile === "" && GC.currDatabaseFileName) {
                loggerEntity.DatabaseFile = GC.currDatabaseFileName
                loggerEntity.sessionName = GC.currDatabaseSessionName
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

    readonly property bool databaseReady: loggerEntity.DatabaseReady
    signal loggerSettingsMenu()
    signal loggerSessionsMenu(var loggerEntity)
    signal loggerCustomDataMenu()
    // internal
    property bool snapshotTrigger: false;
    property bool startLoggingAfterSessionSelect: false
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property QtObject systemEntity: VeinEntity.getEntity("_System")

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
    readonly property string customContentSetName: "ZeraCustomContentSet"

    function startLogging() {
        // No logging active?
        if(veinResponsesRequired === 0) {
            // contentSets: create & set if necessary
            var strDbContentSets = GC.dbContentSetsFromContext(GC.currentGuiContext)
            // Translate custom data to array of contentSets
            if(strDbContentSets === customContentSetName) {
                strDbContentSets = GC.getLoggerCustomContentSets()
            }
            // Convert ',' setting to array / keep contextSets not available (currently) in strContentSetsNotFound
            // for warning
            var strContentSetsNotFound = ""
            var dbContentSetArrWanted = strDbContentSets.split(',')
            var dbContentSetToSetArr = []
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
            if(strContentSetsNotFound !== "") {
                console.warn("Cannot find content set(s) \"" + strContentSetsNotFound + "\" in available content sets!" )
            }
            if(JSON.stringify(loggerEntity.currentContentSets.sort()) !== JSON.stringify(dbContentSetToSetArr.sort())) {
                ++veinResponsesRequired // we listen to loggedComponents -> one event
                loggerEntity.currentContentSets = dbContentSetToSetArr
            }

            // guiContext: create & set if necessary
            var guiContext = GC.currentGuiContext.name
            if(loggerEntity.guiContext !== guiContext) {
                ++veinResponsesRequired // we get a locale and a remote event
                ++veinResponsesRequired
                loggerEntity.guiContext = guiContext
            }

            // transactionName: create & set if necessary
            var dateTime = new Date();
            var transactionName = (snapshotTrigger ? "Snapshot" : "Recording") + "_" + Qt.formatDateTime(dateTime, "yyyy_MM_dd_hh_mm_ss")
            if(loggerEntity.transactionName !== transactionName) {
                ++veinResponsesRequired // we get a locale and a remote event
                ++veinResponsesRequired
                loggerEntity.transactionName = transactionName
            }
            if(veinResponsesRequired===0) {
                loggerEntity.LoggingEnabled = true
            }
        }
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
        onCustomContentSetsChanged: {
            checkCustomPlausis(false)
        }
        function checkCustomPlausis(onOpenMenu) {
            if(GC.currentGuiContext !== undefined) { // avoid initial fire
                var isCustomDataSelected = GC.getLoggerContentType() === GC.contentTypeEnum.CONTENT_TYPE_CUSTOM
                var actionRequired = false
                // Custom data selected but nothing selected: select fallback
                if(isCustomDataSelected && customContentSets === "") {
                    actionRequired = true
                    contentTypeRadioToSet = GC.contentTypeEnum.CONTENT_TYPE_CONTEXT
                }
                // Custom data was modified: select custom data menu
                else if(!onOpenMenu && !isCustomDataSelected && customContentSets !== "") {
                    actionRequired = true
                    contentTypeRadioToSet = GC.contentTypeEnum.CONTENT_TYPE_CUSTOM
                }
                if(actionRequired) {
                    // Again: Althogh everything works fine QML detects a property loop...
                    propertyLoopAvoidingSetDefaultContentSet.start()
                }
            }
        }
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
                if(contentTypeRadioToSet === GC.getLoggerContentType()) {
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
    Timer {
        id: propertyLoopAvoidingSetDefaultContentSet
        interval: 0
        repeat: false
        onTriggered: {
            GC.setLoggerContentType(radioMenuGroup.contentTypeRadioToSet)
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
            // adjust width to content. Stolen:
            // https://martin.rpdev.net/2018/03/13/qt-quick-controls-2-automatically-set-the-width-of-menus.html
            var result = 0;
            var padding = 0;
            // static menu entries
            for(var i = 0; i < count; ++i) {
                var item = itemAt(i);
                result = Math.max(item.contentItem.implicitWidth, result);
                padding = Math.max(item.padding, padding);
            }
            // dynamic menu entries
            var radioTxt
            var radioTextWidth
            for(i = 0; i < instantiator.model.length; ++i) {
                radioTxt = Z.tr(instantiator.model[i])
                radioTextWidth = fontMetrics.advanceWidth(radioTxt)
                result = Math.max(radioTextWidth, result);
                padding = Math.max(fontMetrics.height+5, padding);
            }
            // special menu entry
            radioTxt = customDataSettingRadio.text
            radioTextWidth = fontMetrics.advanceWidth(radioTxt)
            result = Math.max(radioTextWidth + customDataSettingButton.width, result);
            padding = Math.max(fontMetrics.height+5 + 2*customDataSettingButton.anchors.rightMargin, padding);

            return result + padding * 2;
        }
        onAboutToShow: {
            // Under some conditions updating javascript arrays do not cause a binded
            // property to update [1]. So to avoid surprises assign model for dynamic
            // part of menu each time menu openes
            // [1] https://github.com/schnitzeltony/dyn-menu-qml/blob/master/main.qml
            instantiator.model = GC.getDefaultDbContentSetLists(GC.currentGuiContext)

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
                return FA.icon(FA.fa_arrow_right) + menuText
            }
            onTriggered: {
                startLoggingAfterSessionSelect = false
                loggerSessionsMenu(loggerEntity)
            }
            enabled: loggerEntity.LoggingEnabled !== true &&
                     loggerEntity.DatabaseReady === true
        }
        MenuSeparator { } // (pos 1)
        Instantiator { // dynamic part (context/all) - injected before position 2
            id: instantiator
            delegate: MenuItem {
                property alias radio: dynRadio
                enabled: loggerEntity.LoggingEnabled !== true
                RadioButton {
                    id: dynRadio
                    anchors.fill: parent
                    readonly property int enumContentType: {
                        var ret = (modelData == "ZeraAll" ?
                                    GC.contentTypeEnum.CONTENT_TYPE_ALL :
                                    GC.contentTypeEnum.CONTENT_TYPE_CONTEXT)
                        return ret
                    }
                    text: Z.tr("Menu" + modelData)
                }
            }
            onObjectAdded: {
                menu.insertItem(index + 2, object)
                radioMenuGroup.addButton(object.radio)
            }
            onObjectRemoved: {
                menu.removeItem(object)
                // we cannot use radios attached property ButtonGroup.group
                // in dynamic menus: QML does not remove radio on remove so
                // we have to keep track of radioMenuGroup members. See also
                // onObjectAdded
                radioMenuGroup.removeButton(object.radio)
            }
        }
        MenuItem { // custom contents
            enabled: loggerEntity.LoggingEnabled !== true
            RadioButton {
                id: customDataSettingRadio
                anchors.fill: parent
                property var enumContentType: GC.contentTypeEnum.CONTENT_TYPE_CUSTOM
                text: Z.tr("Custom data")
                ButtonGroup.group: radioMenuGroup
                enabled: GC.getLoggerCustomContentSets() !== ""
            }
            Button {
                id: customDataSettingButton
                text: FA.fa_cogs
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: GC.standardTextHorizMargin
                onClicked: {
                    loggerCustomDataMenu()
                    menu.close()
                }
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
                    startLogging()
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
                      (" " + GC.msToTime(loggerEntity.ScheduledLoggingCountdown)) : "") :
                      FA.icon(FA.fa_play) + Z.tr("Start logging")

            enabled: loggerEntity.DatabaseReady === true &&
                     (loggerEntity.LoggingEnabled === true ||
                     !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined ))
            onTriggered: {
                if(loggerEntity.LoggingEnabled !== true) { // Start
                    snapshotTrigger = false;
                    if(sessionNameLogger !== "") {
                        startLogging()
                    }
                    else {
                        startLoggingAfterSessionSelect = true
                        loggerSessionsMenu(loggerEntity)
                    }
                }
                else { // Stop
                    loggerEntity.LoggingEnabled = false
                }
            }
        }
        MenuSeparator { }
        MenuItem { // Settings
            text: FA.icon(FA.fa_cogs) + Z.tr("Settings...")
            onTriggered: {
                loggerSettingsMenu()
            }
        }
    }
}
