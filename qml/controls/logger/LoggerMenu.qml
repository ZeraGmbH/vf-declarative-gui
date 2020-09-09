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
        return menu.open()
    }
    signal loggerSettingsMenu()
    // internal
    property bool snapshotTrigger: false;
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property bool logEnabled: loggerEntity.LoggingEnabled
    // Snapshot is implemented as logging enable on / off (we should rework this..)
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
            loggerEntity.LoggingEnabled = false;
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
            text: FA.icon(FA.fa_arrow_right) + (loggerEntity.recordName !== undefined ? loggerEntity.recordName : "")
            onTriggered: {
                recordNamePopup.visible = true;
            }
            enabled: loggerEntity.LoggingEnabled !== true
        }
        MenuItem { // Snapshot
            text: FA.icon(FA.fa_camera) + Z.tr("Take snapshot")
            enabled: loggerEntity.LoggingEnabled === false &&
                     loggerEntity.DatabaseReady === true &&
                     !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined )
            onTriggered: {
                snapshotTrigger = true;
                loggerEntity.LoggingEnabled = true
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
                    loggerEntity.LoggingEnabled = true
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
            // we did modify record name - re-open menu so user can
            // start logging without further ado
            menu.open()
        }
    }
}
