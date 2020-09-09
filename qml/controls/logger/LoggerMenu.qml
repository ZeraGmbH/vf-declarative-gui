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
    property real pointSize: 14
    function open() {
        return menu.open()
    }
    signal loggerSettingsMenu()
    // internal
    property bool snapshotTrigger: false;
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property bool logEnabled: loggerEntity.LoggingEnabled
    onLogEnabledChanged: {
        // Snapshot is implemented as logging enable on / off (we should rework this..)
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
            loggerEntity.LoggingEnabled = false;
        }
    }
    // menu with logger operations
    Menu {
        id: menu
        font.family: FA.old
        font.pointSize: root.pointSize
        MenuItem { // Snapshot
            text: FA.icon(FA.fa_camera) + Z.tr("Take snapshot")
            enabled: loggerEntity.LoggingEnabled === false &&
                     loggerEntity.DatabaseReady === true &&
                     !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined )
            onTriggered: {
                snapshotTrigger = true;
                recordNamePopup.visible = true;
            }
        }
        MenuItem { // Start/Stop
            text: loggerEntity.LoggingEnabled === true ? FA.icon(FA.fa_stop) + Z.tr("Stop logging") : FA.icon(FA.fa_play) + Z.tr("Start logging")
            enabled: loggerEntity.DatabaseReady === true &&
                     (loggerEntity.LoggingEnabled === true ||
                     !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined ))
            onTriggered: {
                if(loggerEntity.LoggingEnabled !== true) { // Start
                    recordNamePopup.visible = true;
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
            if(loggerEntity.LoggingEnabled !== true) {
                loggerEntity.recordName = t_resultText;
                loggerEntity.LoggingEnabled = true;
            }
        }
        onSigCanceled: {
            if(loggerEntity.LoggingEnabled !== true) {
                snapshotTrigger = false;
            }
        }
    }
}
