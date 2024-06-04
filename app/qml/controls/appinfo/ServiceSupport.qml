import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import AdjustmentState 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import QmlFileIO 1.0

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
                // code repetition from here....
                Component.onCompleted: {
                    root.appendVersions("Serial number:", statusEnt.PAR_SerialNr)
                    root.appendVersions("Operating system version:", statusEnt.INF_ReleaseNr)
                    root.appendVersions("PCB server version:", statusEnt.INF_PCBServerVersion)
                    root.appendVersions("DSP server version:", statusEnt.INF_DSPServerVersion)
                    root.appendVersions("DSP firmware version:", statusEnt.INF_DSPVersion)
                    root.appendVersions("FPGA firmware version:", statusEnt.INF_FPGAVersion)
                    root.appendVersions("Adjustment status:", AdjState.adjustmentStatusDescription)
                }
                Repeater {
                    id: repeaterPCBVersions
                    model:  {
                        let ctrlVersions = []
                        if(pcbVersionInfo !== "") {
                            let jsonInfo = JSON.parse(pcbVersionInfo)
                            for(let jsonEntry in jsonInfo) {
                                let item = [Z.tr(jsonEntry), jsonInfo[jsonEntry]]
                                ctrlVersions.push(item)
                            }
                        }
                        return ctrlVersions
                    }
                    Component.onCompleted: {
                            root.appendVersions(modelData[0] + ":", modelData[1])
                        }
                }

                Repeater {
                    id: repeaterCtrlVersions
                    model:  {
                        let ctrlVersions = []
                        if(ctrlVersionInfo !== "") {
                            let jsonCpuInfo = JSON.parse(ctrlVersionInfo)
                            for(let jsonEntry in jsonCpuInfo) {
                                let item = [Z.tr(jsonEntry), jsonCpuInfo[jsonEntry]]
                                ctrlVersions.push(item)
                            }
                        }
                        return ctrlVersions
                    }
                    Component.onCompleted: {
                        root.appendVersions(modelData[0] + ":", modelData[1])
                    }
                }
                // code repetition until here....
                onClicked: {
                    QmlFileIO.storeJournalctlOnUsb(root.versionMap)
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

