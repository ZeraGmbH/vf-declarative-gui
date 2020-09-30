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
            loggerSettingsMenu()
        }
        else{
            return menu.open()
        }
    }

    readonly property bool databaseReady: loggerEntity.DatabaseReady
    signal loggerSettingsMenu()
    signal loggerRecordsMenu(var loggerEntity)
    // internal
    property bool snapshotTrigger: false;
    property bool startLoggingAfterRecordSelect: false
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")

    // Snapshot is implemented as logging enable on / off
    // TODO: we MUST-MUST-MUST!!! rework this
    readonly property bool logEnabled: loggerEntity.LoggingEnabled
    onLogEnabledChanged: {
        if(logEnabled && snapshotTrigger) {
            snapshotTrigger = false;
            // causes (wrong?) warning about property loop so use the timer as workaround
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

    readonly property string recordNameLogger: loggerEntity.recordName !== undefined ? loggerEntity.recordName : ""

    function setLoggingEnvironment() {
        var dbContentSet = GC.getDbContentSet(GC.currentGuiContext)
        if(loggerEntity.availableContentSets && loggerEntity.availableContentSets.includes(dbContentSet)) {
            // TODO: Once we have user content sets in logger this needs rework
            loggerEntity.currentContentSet = dbContentSet
            var dateTime = new Date();
            var transactionName = (snapshotTrigger ? "Snapshot" : "Recording") + "_" + Qt.formatDateTime(dateTime, "yyyy_MM_dd_hh_mm_ss")
            loggerEntity.transactionName = transactionName
        }
        else {
            console.warn("Cannot find content set \"" + dbContentSet + "\" in available content sets!" )
        }
    }

    ButtonGroup{
        id: radioMenuGroup
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
            for(var i = 0; i < count; ++i) {
                var item = itemAt(i);
                result = Math.max(item.contentItem.implicitWidth, result);
                padding = Math.max(item.padding, padding);
            }
            for(i = 0; i < instantiator.model.length; ++i) {
                var radioTxt = Z.tr(instantiator.model[i])
                var radioTextWidth = fontMetrics.advanceWidth(radioTxt)
                result = Math.max(radioTextWidth, result);
                padding = Math.max(fontMetrics.height+5, padding);
            }
            return result + padding * 2;
        }
        // Under some conditions updating javascript arrays do not cause a binded
        // property to update [1]. So to avoid surprises assign model for dynamic
        // part of menu each time menu openes
        // [1] https://github.com/schnitzeltony/dyn-menu-qml/blob/master/main.qml
        onAboutToShow: { instantiator.model = GC.getDefaultDbContentSetLists(GC.currentGuiContext) }
        MenuItem { // current record name (pos 0)
            text: {
                // No database cannot happen here: We force move to settings in open()
                var menuText = ""
                if(recordNameLogger === "") {
                    menuText = Z.tr("-- no record --")
                }
                else {
                    menuText = loggerEntity.recordName
                }
                return FA.icon(FA.fa_arrow_right) + menuText
            }
            onTriggered: {
                startLoggingAfterRecordSelect = false
                loggerRecordsMenu(loggerEntity)
            }
            enabled: loggerEntity.LoggingEnabled !== true
        }
        MenuSeparator { } // (pos 1)
        Instantiator { // dynamic part - injected before position 2
            id: instantiator
            delegate: MenuItem {
                enabled: loggerEntity.LoggingEnabled !== true
                RadioButton {
                    id: radioButon
                    anchors.fill: parent
                    text: Z.tr(modelData)
                    ButtonGroup.group: radioMenuGroup
                    checked: modelData === GC.getDbContentSet(GC.currentGuiContext)
                    onToggled: {
                        if(checked) {
                            GC.setDbContentSet(GC.currentGuiContext, modelData)
                        }
                    }
                }
            }
            onObjectAdded: menu.insertItem(index + 2, object)
            onObjectRemoved: menu.removeItem(object)
        }
        MenuSeparator { }
        MenuItem { // Snapshot
            text: FA.icon(FA.fa_camera) + Z.tr("Take snapshot")
            enabled: loggerEntity.LoggingEnabled === false &&
                     loggerEntity.DatabaseReady === true &&
                     !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined )
            onTriggered: {
                snapshotTrigger = true;
                if(recordNameLogger !== "") {
                    setLoggingEnvironment()
                    loggerEntity.LoggingEnabled = true
                }
                else {
                    startLoggingAfterRecordSelect = true
                    loggerRecordsMenu(loggerEntity)
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
                    if(recordNameLogger !== "") {
                        setLoggingEnvironment()
                        loggerEntity.LoggingEnabled = true
                    }
                    else {
                        startLoggingAfterRecordSelect = true
                        loggerRecordsMenu(loggerEntity)
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
