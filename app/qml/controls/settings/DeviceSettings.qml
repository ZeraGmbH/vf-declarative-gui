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

SettingsView {
    id: root
    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    rowHeight: height > 0 ? height * 0.11 : 10
    readonly property real pointSize: rowHeight * 0.36

    Component {
        id: swPllAutomatic
        RowLayout {
            anchors.fill: parent
            Label {
                textFormat: Text.PlainText
                text: Z.tr("PLL channel automatic:")
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            VFSwitch {
                Layout.fillHeight: true
                entity: VeinEntity.getEntity("SampleModule1")
                controlPropertyName: "PAR_PllAutomaticOnOff"
            }
        }
    }
    Component {
        id: cbPllChannel
        RowLayout {
            anchors.fill: parent
            enabled: VeinEntity.getEntity("SampleModule1").PAR_PllAutomaticOnOff === 0
            Label {
                textFormat: Text.PlainText
                text: Z.tr("PLL channel:")
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
                opacity: enabled ? 1.0 : 0.5
            }
            Item {
                Layout.fillWidth: true
            }
            VFComboBox {
                // override
                function translateText(text){
                    return Z.tr(text)
                }
                arrayMode: true
                entity: VeinEntity.getEntity("SampleModule1")
                controlPropertyName: "PAR_PllChannel"
                model: ModuleIntrospection.sampleIntrospection.ComponentInfo.PAR_PllChannel.Validation.Data
                Layout.preferredWidth: root.rowWidth/4
                Layout.preferredHeight: root.rowHeight*0.9
                opacity: enabled ? 1.0 : 0.5
                pointSize: root.pointSize
            }
        }
    }

    Component {
        id: cbDftChannel
        RowLayout {
            anchors.fill: parent
            Label {
                textFormat: Text.PlainText
                text: Z.tr("DFT reference channel:")
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
                opacity: enabled ? 1.0 : 0.5
            }
            Item {
                Layout.fillWidth: true
            }
            VFComboBox {
                // override
                function translateText(text){
                    return Z.tr(text)
                }
                arrayMode: true
                entity: VeinEntity.getEntity("DFTModule1")
                controlPropertyName: "PAR_RefChannel"
                model: ModuleIntrospection.dftIntrospection.ComponentInfo.PAR_RefChannel.Validation.Data
                Layout.preferredWidth: root.rowWidth/4
                Layout.preferredHeight: root.rowHeight*0.9
                opacity: enabled ? 1.0 : 0.5
                pointSize: root.pointSize
            }
        }
    }

    Component {
        id: swScpiQueue
        RowLayout {
            anchors.fill: parent
            Label {
                textFormat: Text.PlainText
                text: Z.tr("SCPI sequential mode:")
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            VFSwitch {
                Layout.fillHeight: true
                entity: VeinEntity.getEntity("SCPIModule1")
                controlPropertyName: "PAR_OptionalScpiQueue"
            }
        }
    }

    readonly property bool showPll: VeinEntity.hasEntity("SampleModule1") && !VeinEntity.getEntity("SampleModule1").ACT_PllFixed
    model: VisualItemModel {
        Loader {
            sourceComponent: swPllAutomatic
            active: showPll
            asynchronous: true

            height: active ? root.rowHeight : 0
            anchors.left: parent.left
            anchors.right: parent.right
        }
        Loader {
            sourceComponent: cbPllChannel
            active: showPll
            asynchronous: true

            height: active ? root.rowHeight : 0
            anchors.left: parent.left
            anchors.right: parent.right
        }
        Loader {
            sourceComponent: cbDftChannel
            active: VeinEntity.hasEntity("DFTModule1")
            asynchronous: true

            height: active ? root.rowHeight : 0
            anchors.left: parent.left
            anchors.right: parent.right
        }
        SettingsInterval {
            rowHeight: root.rowHeight
            width: root.rowWidth;
            pointSize: root.pointSize
        }
        Loader {
            sourceComponent: swScpiQueue
            active: VeinEntity.hasEntity("SCPIModule1") && VeinEntity.getEntity("_System").DevMode
            asynchronous: true

            height: active ? root.rowHeight : 0
            anchors.left: parent.left
            anchors.right: parent.right
        }
        SerialSettings {
            height: root.rowHeight * Math.min(ttyCount, 4)
            rowHeight: root.rowHeight
            width: root.rowWidth;
            pointSize: root.pointSize
        }
    }
}
