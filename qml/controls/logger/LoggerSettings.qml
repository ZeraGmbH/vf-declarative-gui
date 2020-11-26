import QtQuick 2.5
import QtQuick.Controls 2.0
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

    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property string dbFileName: loggerEntity.DatabaseFile
    onDbFileNameChanged: {
        GC.setCurrDatabaseFileName(dbFileName)
    }

    horizMargin: GC.standardTextHorizMargin
    rowHeight: parent.height/8

    readonly property real fontScale: 0.3
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10

    Loader {
        id: loggerSearchPopup
        active: false
        sourceComponent: LoggerDbSearchDialog {
            width: root.width
            height: Qt.inputMethod.visible ? root.height/2 : root.height
            visible: true
            onClosed: loggerSearchPopup.active = false;
            onFileSelected: {
                if(root.loggerEntity.DatabaseFile !== t_file) {
                    root.loggerEntity.DatabaseFile = t_file;
                }
            }
        }
    }
    model: ObjectModel {
        Column {
            spacing: root.rowHeight/4.5
            Label {
                text: Z.tr("Database Logging")
                width: root.rowWidth;
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: root.pointSize
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
            RowLayout {
                height: root.rowHeight;
                width: root.rowWidth;

                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Database filename:")
                    font.pointSize: root.pointSize
                }
                Item {
                    //spacer
                    width: 24
                }
                VFLineEdit {
                    id: fileNameField
                    entity: loggerEntity
                    controlPropertyName: "DatabaseFile"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    pointSize: root.pointSize
                    placeholderText: Z.tr("filename")
                    textField.enabled: loggerEntity.LoggingEnabled === false
                    validator: RegExpValidator {
                        // our target is windows most likely!
                        regExp: /^[a-z][_a-z0-9]*$/
                    }
                    // overrides
                    function transformIncoming(t_incoming) {
                        // Since we do not allow subfolders, do a simple basename and remove .db
                        return t_incoming.split('/').reverse()[0].replace(".db", "")
                    }
                    function doApplyInput(newText) {
                        loggerEntity.DatabaseFile = dbLocationSelector.currentPath+"/" + newText + ".db"
                        // wait to be applied
                        return false
                    }
                    function baseActiveFocusChange(actFocus) {
                        if(!actFocus) {
                            // avoid unwanted database creation
                            discardInput()
                        }
                    }
                }
                Label {
                    textFormat: Text.PlainText
                    text: ".db"
                    font.pointSize: root.pointSize
                    horizontalAlignment: Text.AlignLeft
                }
                Item {
                    //spacer
                    width: GC.standardMarginWithMin
                }
                Button { // search database
                    font.family: FA.old
                    implicitHeight: root.rowHeight
                    font.pointSize: root.pointSize
                    text: FA.fa_search
                    enabled: loggerEntity.LoggingEnabled === false
                    onClicked: {
                        loggerSearchPopup.active = true;
                    }
                }
                Button { // unmount database
                    text: (enabled ? "<font color=\"#EEff0000\">" : "<font color=\"grey\">") + FA.fa_eject  // darker red
                    font.family: FA.old
                    font.pointSize: root.pointSize
                    implicitHeight: root.rowHeight
                    enabled: root.loggerEntity.DatabaseFile.length > 0 && loggerEntity.LoggingEnabled === false
                    onClicked: {
                        root.loggerEntity.DatabaseFile = ""
                    }
                }
            }
            RowLayout {
                height: root.rowHeight;
                width: root.rowWidth;
                visible: loggerEntity.DatabaseReady === true
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("DB size:")
                    font.pointSize: root.pointSize
                    Layout.fillWidth: true
                }
                Label {
                    // mountPoint is used to get FilesystemInfo -> TODO replace by _FILES.
                    readonly property string mountPoint: GC.currentSelectedStoragePath === "/home/operator/logger" ? "/" : GC.currentSelectedStoragePath;
                    readonly property double available: loggerEntity.FilesystemInfo[mountPoint] ? loggerEntity.FilesystemInfo[mountPoint].FilesystemFree : NaN
                    readonly property double total: loggerEntity.FilesystemInfo[mountPoint] ? loggerEntity.FilesystemInfo[mountPoint].FilesystemTotal : NaN
                    readonly property double percentAvail: total > 0 ? (available/total * 100).toFixed(2) : 0.0;
                    text:  Z.tr("<b>%1MB</b> (available <b>%2GB</b> / %3%)").arg((loggerEntity.DatabaseFileSize/Math.pow(1024, 2)).toFixed(2)).arg(available.toFixed(2)).arg(percentAvail);
                    font.pointSize: root.pointSize
                }
            }
            LoggerDbLocationSelector {
                id: dbLocationSelector
                height: root.rowHeight;
                width: root.rowWidth;
                pointSize: root.pointSize
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
        }
    }
}
