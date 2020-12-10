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
    id: root
    property string currentPath
    property alias currentMountPath: drivesCombo.currentPath
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
    onCurrentPathChanged: {
        if(GC.currentSelectedStoragePath !== currentPath) {
            GC.currentSelectedStoragePath = currentPath
        }
    }

    readonly property QtObject fileEntity: VeinEntity.getEntity("_Files")
    readonly property string externalPathExtend: '/' + GC.deviceName + '/database'

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
        // we need to remove our externalPathExtend
        storagePath = storagePath.replace(externalPathExtend, "")
        drivesCombo.selectPath(storagePath)
        GC.currentSelectedStoragePath = storagePath
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
        onCurrentPathChanged: {
            // we cannot use currentIsAutoMounted because nobody tells us what variable
            // is upgraded first
            var isAutomount = model.length ? model[currentIndex].autoMount : false
            root.currentPath = isAutomount ? currentPath + externalPathExtend : currentPath
        }
    }
}
