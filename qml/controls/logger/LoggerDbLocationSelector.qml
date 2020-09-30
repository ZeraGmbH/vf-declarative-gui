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
    property int pointSize: 20;
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
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

    Connections {
        target: loggerEntity
        onSigRPCFinished: {
            if(t_resultData["RemoteProcedureData::resultCode"] !== 0) {
                console.warn("RPC error:", t_resultData["RemoteProcedureData::errorMessage"]);
            }
            if(t_identifier === listStorageTracer) {
                root.storageList = t_resultData["ZeraDBLogger::storageList"];
                listStorageTracer = undefined;
                if(storageList.length>0) {
                    var selectedStorage = String(loggerEntity.DatabaseFile);
                    if(selectedStorage.length === 0) {
                        selectedStorage = GC.currentSelectedStoragePath;
                    }

                    for(var storageIdx in storageList) {
                        if(selectedStorage.indexOf(storageList[storageIdx]) === 0) {
                            root.currentIndex = storageIdx;
                            root.newIndexSelected(false);
                        }
                    }
                }
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
        model: root.storageList;
        font.pointSize: root.pointSize
        enabled: root.storageList.length > 0 && loggerEntity.LoggingEnabled === false
        Layout.fillWidth: true
        Layout.fillHeight: true

        Connections {
            target: GC
            onCurrentSelectedStoragePathChanged: {
                currentIndex = storageList.indexOf(GC.currentSelectedStoragePath);
            }
        }
        onActivated: {
            if(GC.currentSelectedStoragePath !== storageList[index]) {
                GC.currentSelectedStoragePath = storageList[index]
                root.newIndexSelected(true);
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
