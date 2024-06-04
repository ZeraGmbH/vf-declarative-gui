import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import AdjustmentState 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import QmlFileIO 1.0
import GlobalConfig 1.0


Item {
    id: root
    readonly property real rowHeight: height > 0 ? height/20 : 10
    readonly property real pointSize: rowHeight * 0.7
    readonly property QtObject statusEnt: VeinEntity.getEntity("StatusModule1");

    readonly property string ctrlVersionInfo: VeinEntity.getEntity("StatusModule1")["INF_CTRLVersion"]
    readonly property string pcbVersionInfo: VeinEntity.getEntity("StatusModule1")["INF_PCBVersion"]

    property var dynVersions: []
    readonly property bool hasCpuInfo: statusEnt.hasComponent("INF_CpuInfo")
    onHasCpuInfoChanged: {
        if(hasCpuInfo) {
            appendDynVersions(VeinEntity.getEntity("StatusModule1")["INF_CpuInfo"])
        }
    }

    function appendDynVersions(strJsonCpuInfo) {
        // Vein/JSON version lookup fields:
        // 1st: Text displayed in label
        // 2nd: JSON input field name
        let dynVersionLookup = [
            [Z.tr("CPU-board number"),   "PartNumber"],
            [Z.tr("CPU-board assembly"),  "Assembly"],
            [Z.tr("CPU-board date"),    "Date"],
        ];
        // 1st: Text displayed in label
        // 2nd: version
        if(strJsonCpuInfo !== "") {
            let jsonCpuInfo = JSON.parse(strJsonCpuInfo)
            for(let lookupItem=0; lookupItem < dynVersionLookup.length; lookupItem++) {
                let jsonVerName = dynVersionLookup[lookupItem][1]
                if(jsonVerName in jsonCpuInfo) {
                    let item = [dynVersionLookup[lookupItem][0], jsonCpuInfo[jsonVerName]]
                    dynVersions.push(item)
                }
            }
            repeaterVersions.model = dynVersions
        }
    }

    property var versionMap: ({})
      function appendVersions(strLabel, version) {
          versionMap[strLabel] = version
      }


    VisualItemModel {
        id: supportModel

        RowLayout {
            width: parent.width
            height: root.rowHeight * 4
            Button {
                id: buttonStoreLog
                property bool buttonEnabled: true
                font.pointSize: root.pointSize
                text: Z.tr("Save logfile to USB")
                width: implicitContentWidth
                Layout.preferredWidth: root.width * 0.4
                enabled: (QmlFileIO.mountedPaths.length > 0) && buttonEnabled
                highlighted: true
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    QmlFileIO.storeJournalctlOnUsb(GC.versionMap)
                    buttonEnabled = false
                    buttonTimer.start()
                }
            }
            Timer {
                id: buttonTimer
                interval: 1000
                repeat: false
                onTriggered: {
                    buttonStoreLog.buttonEnabled = true
                }
            }
        }

        RowLayout {
            width: parent.width
            height: root.rowHeight
            Button {
                id: buttonStartUpdate
                property bool buttonUpdateEnabled: true
                font.pointSize: root.pointSize
                text: Z.tr("Start Software-Update")
                width: implicitContentWidth
                Layout.preferredWidth: parent.width * 0.4
                enabled: false //conditions for sw update
                highlighted: true
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    //action sw update
                }
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: supportModel
    }
}

