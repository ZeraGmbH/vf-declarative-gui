import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0

SettingsView {
    id: root
    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    rowHeight: height > 0 ? height / 9 : 10
    readonly property real pointSize: height > 0 ? height * 0.04 : 10
    readonly property int pixelSize: pointSize*1.4

    Component {
        id: swPllAutomatic
        RowLayout {
            Label {
                textFormat: Text.PlainText
                text: Z.tr("PLL channel automatic:")
                font.pointSize: pointSize
                Layout.fillWidth: true
            }
            VFSwitch {
                height: parent.height
                entity: VeinEntity.getEntity("SampleModule1")
                controlPropertyName: "PAR_PllAutomaticOnOff"
            }
        }
    }
    Component {
        id: cbPllChannel
        RowLayout {
            enabled: VeinEntity.getEntity("SampleModule1").PAR_PllAutomaticOnOff === 0
            Label {
                textFormat: Text.PlainText
                text: Z.tr("PLL channel:")
                font.pointSize: pointSize
                Layout.fillWidth: true
                opacity: enabled ? 1.0 : 0.7
            }
            Item {
                Layout.fillWidth: true
            }
            VFComboBox {
                arrayMode: true
                entity: VeinEntity.getEntity("SampleModule1")
                controlPropertyName: "PAR_PllChannel"
                model: ModuleIntrospection.sampleIntrospection.ComponentInfo.PAR_PllChannel.Validation.Data
                centerVertical: true
                implicitWidth: root.rowWidth/4
                fontSize: root.pixelSize
                height: root.rowHeight-8
                opacity: enabled ? 1.0 : 0.7
            }
        }
    }

    Component {
        id: cbDftChannel
        RowLayout {
            Label {
                textFormat: Text.PlainText
                text: Z.tr("DFT reference channel:")
                font.pointSize: pointSize
                Layout.fillWidth: true
                opacity: enabled ? 1.0 : 0.7
            }
            Item {
                Layout.fillWidth: true
            }
            VFComboBox {
                arrayMode: true
                entity: VeinEntity.getEntity("DFTModule1")
                controlPropertyName: "PAR_RefChannel"
                model: ModuleIntrospection.dftIntrospection.ComponentInfo.PAR_RefChannel.Validation.Data
                centerVertical: true
                implicitWidth: root.rowWidth/4
                fontSize: root.pixelSize
                height: root.rowHeight-8
                opacity: enabled ? 1.0 : 0.7
            }
        }
    }

    model: VisualItemModel {
        Item {
            height: root.rowHeight;
            width: root.rowWidth;
            Loader {
                sourceComponent: swPllAutomatic
                active: VeinEntity.hasEntity("SampleModule1")
                asynchronous: true

                height: active ? root.rowHeight : 0
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
        Item {
            height: root.rowHeight;
            width: root.rowWidth;
            Loader {
                sourceComponent: cbPllChannel
                active: VeinEntity.hasEntity("SampleModule1")
                asynchronous: true

                height: active ? root.rowHeight : 0
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
        Item {
            height: root.rowHeight;
            width: root.rowWidth;
            Loader {
                sourceComponent: cbDftChannel
                active: VeinEntity.hasEntity("DFTModule1")
                asynchronous: true
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
        SettingsInterval {
            height: hasPeriodEntries ? 2*root.rowHeight : root.rowHeight
            width: root.rowWidth;
            pointSize: root.pointSize
        }
        SerialSettings {
            height: root.rowHeight * Math.min(ttyCount, 4)
            rowHeight: root.rowHeight
            width: root.rowWidth;
            id: serialSettings
            pointSize: root.pointSize
        }
    }
}
