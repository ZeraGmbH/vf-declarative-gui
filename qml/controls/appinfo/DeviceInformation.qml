import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import AdjustmentState 1.0
import ZeraTranslation  1.0

Item {
    id: root

    readonly property QtObject statusEnt: VeinEntity.getEntity("StatusModule1");
    readonly property real rowHeight: height > 0 ? height/20 : 10
    readonly property real pointSize: rowHeight * 0.7

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

    VisualItemModel {
        id: statusModel

        RowLayout {
            width: parent.width
            height: root.rowHeight
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("Serial number:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: statusEnt.PAR_SerialNr
            }
        }
        RowLayout {
            width: parent.width
            height: root.rowHeight
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("Operating system version:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: statusEnt.INF_ReleaseNr
            }
        }
        RowLayout {
            width: parent.width
            height: root.rowHeight
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("PCB version:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: statusEnt.INF_PCBVersion
            }
        }
        RowLayout {
            width: parent.width
            height: root.rowHeight
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("PCB server version:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: statusEnt.INF_PCBServerVersion
            }
        }
        RowLayout {
            width: parent.width
            height: root.rowHeight
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("DSP server version:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: statusEnt.INF_DSPServerVersion
            }
        }
        RowLayout {
            width: parent.width
            height: root.rowHeight
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("DSP firmware version:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: statusEnt.INF_DSPVersion
            }
        }
        RowLayout {
            width: parent.width
            height: root.rowHeight
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("FPGA firmware version:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: statusEnt.INF_FPGAVersion
            }
        }
        RowLayout {
            width: parent.width
            height: root.rowHeight
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("Microcontroller firmware version:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: statusEnt.INF_CTRLVersion
            }
        }
        RowLayout {
            width: parent.width
            height: root.rowHeight
            Material.foreground: AdjState.adjusted ? Material.White : Material.Red
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("Adjustment status:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: AdjState.adjustmentStatusDescription
            }
        }
        RowLayout {
            width: parent.width
            height: root.rowHeight
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("Adjustment checksum:")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: root.pointSize
                text: statusEnt.INF_AdjChksum
            }
        }
        ColumnLayout {
            width: parent.width
            spacing: rowHeight/2
            Repeater {
                id: repeaterVersions
                model: []
                RowLayout {
                    height: root.rowHeight
                    Label {
                        text: modelData[0] + ":"
                        font.pointSize: root.pointSize
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Label {
                        font.pointSize: root.pointSize
                        text: modelData[1]
                    }
                }
            }
        }
    }

    ListView {
        id: statusListView
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: rowHeight/2
        model: statusModel
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: rightScrollbar
    }
    ScrollBar {
        id: rightScrollbar
        anchors.left: statusListView.right
        anchors.top: statusListView.top
        anchors.bottom: statusListView.bottom
        visible: statusListView.contentHeight>statusListView.height
        Component.onCompleted: {
            policy = ScrollBar.AlwaysOn;
        }
    }
}
