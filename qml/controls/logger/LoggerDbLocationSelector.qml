import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
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
    property var listStorageTracer;

    signal newIndexSelected(bool byUser);

    Component.onCompleted: updateStorageList();

    function updateStorageList() {
        if(!listStorageTracer) {
            listStorageTracer = loggerEntity.invokeRPC("listStorages()", ({}))
        }
        else {
            console.warn("Storage list update already in progress");
        }
    }
    function selectLocationCombo(byUser) {
        if(storageList.length>0) {
            var selectedStorage = byUser ? "" : databaseFileName
            if(selectedStorage.length === 0) {
                selectedStorage = GC.currentSelectedStoragePath
            }
            // We must find string with max match: At least during debug
            // /home and /home/superandy/temp caused touble selecting correct entry
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
            if(indexFound > 0) {
                GC.currentSelectedStoragePath = storageList[indexFound]
                currentIndex = indexFound
                newIndexSelected(byUser)
            }
        }
    }

    Connections {
        target: loggerEntity
        onSigRPCFinished: {
            if(t_resultData["RemoteProcedureData::resultCode"] !== 0) {
                console.warn("RPC error:", t_resultData["RemoteProcedureData::errorMessage"]);
            }
            if(t_identifier === listStorageTracer) {
                listStorageTracer = undefined
                storageList = t_resultData["ZeraDBLogger::storageList"]
                var tmpStorageListForDisplay = storageList.slice()
                for(var storageIdx in storageList) {
                    // create more user friendly display content
                    if(tmpStorageListForDisplay[storageIdx].startsWith("/home/operator/logger")) {
                        tmpStorageListForDisplay[storageIdx] = tmpStorageListForDisplay[storageIdx].replace("/home/operator/logger", Z.tr("internal"))
                    }
                    else {
                        tmpStorageListForDisplay[storageIdx] = Z.tr("external") + " (" + tmpStorageListForDisplay[storageIdx] + ")"
                    }
                }
                // Fill & select combo
                storageListForDisplay = tmpStorageListForDisplay
                selectLocationCombo(false)
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

    Item {
        width: storageListIndicator.width
        visible: root.storageList.length === 0 && storageListIndicator.opacity === 0;
        Label {
            id: storageListWarning
            anchors.centerIn: parent
            font.family: FA.old
            font.pointSize: root.pointSize
            text: FA.fa_exclamation_triangle
            color: Material.color(Material.Yellow)
        }
    }
    BusyIndicator {
        id: storageListIndicator
        opacity: root.listStorageTracer !== undefined
        Behavior on opacity {
            NumberAnimation { from: 1; duration: 1000; }
        }
        visible: storageListWarning.visible === false
    }
    ComboBox {
        id: dbLocationSelector
        model: root.storageListForDisplay
        font.pointSize: root.pointSize
        enabled: root.storageList.length > 0 && loggerEntity.LoggingEnabled === false
        Layout.fillWidth: true
        Layout.fillHeight: true

        onActivated: {
            if(GC.currentSelectedStoragePath !== storageList[index]) {
                GC.currentSelectedStoragePath = storageList[index]
                loggerEntity.DatabaseFile = ""
                selectLocationCombo(true)
            }
        }
    }
    Button {
        font.family: FA.old
        font.pointSize: root.pointSize
        text: FA.fa_refresh
        Layout.fillHeight: true
        onClicked: {
            if(root.listStorageTracer === undefined) {
                root.updateStorageList();
            }
        }
    }
}
