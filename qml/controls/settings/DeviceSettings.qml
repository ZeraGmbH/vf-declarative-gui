import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import QtQuick.VirtualKeyboard.Settings 2.2
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import "qrc:/qml/controls" as CCMP
import ZeraVeinComponents 1.0 as VFControls
import ZeraFa 1.0



SettingsView {
    id: root


    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    rowHeight: 48

    Loader {
        id: fInOutPopup
        active: VeinEntity.hasEntity("POWER1Module4")

        sourceComponent: FrequencyInOutConfigPopup {
            width: root.width
            height: root.height
        }
    }


    Component {
        id: swPllAutomatic
        RowLayout {
            Label {
                textFormat: Text.PlainText
                text: ZTR["PLL channel automatic:"]
                font.pixelSize: 20

                Layout.fillWidth: true
            }

            VFControls.VFSwitch {
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
                text: ZTR["PLL channel:"]
                font.pixelSize: 20

                Layout.fillWidth: true
                opacity: enabled ? 1.0 : 0.7
            }

            Item {
                Layout.fillWidth: true
            }

            VFControls.VFComboBox {
                arrayMode: true
                entity: VeinEntity.getEntity("SampleModule1")
                controlPropertyName: "PAR_PllChannel"
                model: ModuleIntrospection.sampleIntrospection.ComponentInfo.PAR_PllChannel.Validation.Data
                centerVertical: true
                implicitWidth: root.rowWidth/4
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
                text: ZTR["DFT reference channel:"]
                font.pixelSize: 20

                Layout.fillWidth: true
                opacity: enabled ? 1.0 : 0.7
            }

            Item {
                Layout.fillWidth: true
            }

            VFControls.VFComboBox {
                arrayMode: true
                entity: VeinEntity.getEntity("DFTModule1")
                controlPropertyName: "PAR_RefChannel"
                model: ModuleIntrospection.dftIntrospection.ComponentInfo.PAR_RefChannel.Validation.Data
                centerVertical: true
                implicitWidth: root.rowWidth/4
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
                anchors.leftMargin: 20
                anchors.rightMargin: 16
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
                anchors.leftMargin: 20
                anchors.rightMargin: 16
            }
        }
        Item {
            height: root.rowHeight;
            width: root.rowWidth;

            Loader {
                sourceComponent: cbDftChannel
                active: VeinEntity.hasEntity("DFTModule1")
                asynchronous: true

                height: active ? root.rowHeight : 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 16
            }
        }
        Item {
            height: root.rowHeight;
            width: root.rowWidth;

            SettingsInterval {
                id: sInterval
                rowHeight: root.rowHeight
                rowWidth: root.rowWidth-36
                x: 20
            }
        }
        Item {
            height: root.rowHeight * visible; //do not waste space in the layout if not visible
            width: root.rowWidth;
            visible: VeinEntity.hasEntity("POWER1Module4")
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                Label {
                    textFormat: Text.PlainText
                    text: ZTR["Frequency input/output configuration:"];
                    font.pixelSize: 20

                    Layout.fillWidth: true
                }
                Button {
                    text: FA.fa_cogs
                    font.family: FA.old
                    font.pixelSize: 20
                    implicitHeight: root.rowHeight
                    onClicked: fInOutPopup.item.open();
                }
            }
        }






    }

}
