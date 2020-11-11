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
    property alias currentIndex: dbLocationSelector.currentIndex

    property var storageList: [];
    property var storageListForDisplay: [];
    property int pointSize: 20;
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property string databaseFileName: String(loggerEntity.DatabaseFile)
    onDatabaseFileNameChanged: {
        selectLocationCombo(false)
    }
    readonly property QtObject fileEntity: VeinEntity.getEntity("_Files")
    readonly property var mountedPaths: fileEntity ? fileEntity.AutoMountedPaths : []
    readonly property string loggerLocalPath: fileEntity.LoggerLocalPath
    onMountedPathsChanged: {
        // note: as soon as we are landing here, we can rely on fileEntity available
        // 1. local/internal array entries
        storageList = [fileEntity.LoggerLocalPath]
        var tmpStorageListForDisplay = [Z.tr("internal")]
        // 2. append removable partitions
        for(var extPartNo in mountedPaths) {
            storageList.push(mountedPaths[extPartNo])
            // TODO: human readable names
            tmpStorageListForDisplay.push(mountedPaths[extPartNo])
        }
        // 3. Fill & select combo
        storageListForDisplay = tmpStorageListForDisplay
        selectLocationCombo(false)
        // 4. Notify user
        dbLocationSelector.notifyMountChange()
    }

    signal newIndexSelected(bool byUser);

    function selectLocationCombo(byUser) {
        if(storageList.length>0) {
            var selectedStorage = byUser ? "" : databaseFileName
            if(selectedStorage.length === 0) {
                selectedStorage = GC.currentSelectedStoragePath
            }
            // We must find string with max match: At least during debug
            // /home and /home/superandy/temp caused trouble selecting correct entry
            var indexFound = -1
            var maxMatch = 0
            for(var storageIdx in storageList) {
                // set current index
                var currStorage = storageList[storageIdx]
                // check total match first for path from GC.currentSelectedStoragePath
                if(currStorage === selectedStorage) {
                    indexFound = storageIdx
                    break;
                }
                // partial match for file name - keep best match
                else if(selectedStorage.indexOf(currStorage) === 0) {
                    if(currStorage.length > maxMatch) {
                        maxMatch = currStorage.length
                        indexFound = storageIdx
                    }
                }
            }
            if(indexFound >= 0) {
                GC.currentSelectedStoragePath = storageList[indexFound]
                currentIndex = indexFound
                newIndexSelected(byUser)
            }
        }
    }
    Label {
        textFormat: Text.PlainText
        text: Z.tr("DB location:")
        font.pointSize: root.pointSize
    }
    Item {
        //spacer
        width: 8
    }
    ComboBox {
        id: dbLocationSelector
        model: root.storageListForDisplay
        font.pointSize: root.pointSize
        enabled: root.storageList.length > 0 && loggerEntity.LoggingEnabled === false
        Layout.fillWidth: true
        Layout.fillHeight: true

        property bool ignoreFirstMoutChange: true
        function notifyMountChange() {
            if(!ignoreFirstMoutChange) {
                comboRipple.active = true
                comboRippleTimer.start()
            }
            ignoreFirstMoutChange = false
        }
        onActivated: {
            if(GC.currentSelectedStoragePath !== storageList[index]) {
                GC.currentSelectedStoragePath = storageList[index]
                loggerEntity.DatabaseFile = ""
                selectLocationCombo(true)
            }
        }
        Ripple {
            id: comboRipple
            clipRadius: 2
            anchors.fill: parent
            anchor: dbLocationSelector
            color: dbLocationSelector.Material.highlightedRippleColor // dbLocationSelector.Material.rippleColor
        }
        Timer {
            id: comboRippleTimer
            interval: 700
            onTriggered: {
                comboRipple.active = false
            }
        }
    }
}
