import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import QtQml.Models 2.14
import QtQuick.Controls.Material 2.14
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraComponents 1.0
import ZeraTranslation 1.0

Item {
    property real pointSize
    property real rowHeight

    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")
    readonly property var ttysJson: filesEntity === undefined ? {} : filesEntity.Ttys
    readonly property var ttys: filesEntity === undefined ? [] : Object.keys(ttysJson)
    readonly property var ttyCount: filesEntity === undefined ? 0 : Object.keys(ttysJson).length

    readonly property QtObject scpiEntity: VeinEntity.getEntity("SCPIModule1")
    readonly property bool scpiconnected: scpiEntity ? scpiEntity.PAR_SerialScpiActive : false
    readonly property string scpiSerial: scpiEntity ? scpiEntity.ACT_SerialScpiDeviceFile : ""

    readonly property QtObject sourceEntity: VeinEntity.getEntity("SourceModule1")

    visible: height > 0

    RowLayout {
        anchors.fill: parent
        Label {
            text: Z.tr("Serial IOs:")
            font.pointSize: pointSize
            Layout.fillWidth: true
        }
        ListView {
            Layout.preferredWidth: parent.width * 0.8
            Layout.fillHeight: true
            model: ttys
            clip: true
            boundsBehavior: ListView.OvershootBounds
            delegate: RowLayout {
                id: ttyRow
                property var ttyDev: modelData
                height: rowHeight
                width: parent.width
                Label {
                    text: modelData.replace('/dev/tty', '') + ": "
                    font.pointSize: pointSize
                }
                Label {
                    text: ttysJson[modelData].manufacturer
                    Layout.fillWidth: true
                    font.pointSize: pointSize
                }
                ZComboBox {
                    arrayMode: true
                    model: {
                        let ret = []
                        ret.push(Z.tr("Not connected"))
                        // Global setting will go once we are ready to ship
                        if(sourceEntity && GC.sourceConnectEnabled) {
                            ret.push(Z.tr("Source device"))
                        }
                        if(scpiEntity && ttyRow.ttyDev === scpiSerial) {
                            ret.push(Z.tr("Serial SCPI"))
                        }
                        return ret
                    }
                    centerVertical: true
                    implicitWidth: root.width * 0.3
                    fontSize: pointSize*1.4
                    height: rowHeight-8
                }
            }
        }
    }
}
