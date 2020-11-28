import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Material.impl 2.12
import QtQuick.Layouts 1.3
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraFa 1.0
import "qrc:/qml/controls" as CCMP

RowLayout {
    readonly property alias currentPath: drivesCombo.currentPath
    property real pointSize
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")
    readonly property string databaseFileName: String(loggerEntity.DatabaseFile)
    Component.onCompleted: {
        drivesCombo.addExtraPath(filesEntity.LoggerLocalPath, Z.tr("internal"), true)
        selectLocationCombo(false)
    }
    onDatabaseFileNameChanged: {
        selectLocationCombo(false)
    }
    readonly property QtObject fileEntity: VeinEntity.getEntity("_Files")

    signal newIndexSelected();

    function selectLocationCombo(byUser) {
        var storagePath = ""
        if(!byUser) {
            var storagePathArray = databaseFileName.split('/')
            storagePathArray.pop()
            storagePath = storagePathArray.join('/')
        }
        if(storagePath.length === 0) {
            storagePath = GC.currentSelectedStoragePath
        }
        if(drivesCombo.selectPath(storagePath)) {
            GC.currentSelectedStoragePath = storagePath
            newIndexSelected()
        }
    }
    Label {
        textFormat: Text.PlainText
        text: Z.tr("DB location:")
        font.pointSize: pointSize
    }
    Item {
        //spacer
        width: 8
    }
    MountedDrivesCombo {
        id: drivesCombo
        font.pointSize: pointSize
        enabled: loggerEntity.LoggingEnabled === false
        Layout.fillWidth: true
        Layout.fillHeight: true

        onActivated: {
            if(GC.currentSelectedStoragePath !== drivesCombo.currentPath) {
                GC.currentSelectedStoragePath = drivesCombo.currentPath
                loggerEntity.DatabaseFile = ""
                selectLocationCombo(true)
            }
        }
    }
}
