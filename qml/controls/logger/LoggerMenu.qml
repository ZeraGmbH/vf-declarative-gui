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
    property bool popupRecordnameAccepted: false
    onRecordNameLoggerChanged: {
        if(popupRecordnameAccepted) {
            popupRecordnameAccepted = false
            if(startLoggingAfterRecordSelect) {
                loggerEntity.LoggingEnabled = true
            }
            else {
                // we did modify record name - re-open menu so user can
                // start logging without further ado
                menu.open()
            }
        }
    }

    // menu with logger operations
    Menu {
        id: menu
        font.family: FA.old
        font.pointSize: root.pointSize
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
            return result + padding * 2;
        }
        MenuItem { // current record name
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
                recordNamePopup.visible = true;
            }
            enabled: loggerEntity.LoggingEnabled !== true
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
                    loggerEntity.LoggingEnabled = true
                }
                else {
                    startLoggingAfterRecordSelect = true
                    recordNamePopup.visible = true;
                }
            }
        }
        MenuItem { // Start/Stop
            text: loggerEntity.LoggingEnabled === true ? FA.icon(FA.fa_stop) + Z.tr("Stop logging") : FA.icon(FA.fa_play) + Z.tr("Start logging")
            enabled: loggerEntity.DatabaseReady === true &&
                     (loggerEntity.LoggingEnabled === true ||
                     !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined ))
            onTriggered: {
                if(loggerEntity.LoggingEnabled !== true) { // Start
                    snapshotTrigger = false;
                    if(recordNameLogger !== "") {
                        loggerEntity.LoggingEnabled = true
                    }
                    else {
                        startLoggingAfterRecordSelect = true
                        recordNamePopup.visible = true;
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
    // database record setter popup
    LoggerRecordNamePopup {
        id: recordNamePopup
        onSigAccepted: {
            loggerEntity.recordName = t_resultText;
            // before continuing, we have to wait for recordname accepted
            // otherwise at least snapshots won't be stored
            // see onRecordNameLoggerChanged for further activities
            popupRecordnameAccepted = true
        }
    }
}
