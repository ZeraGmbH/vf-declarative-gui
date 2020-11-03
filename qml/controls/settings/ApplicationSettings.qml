import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import ZeraFa 1.0
import ZeraLocale 1.0
import "qrc:/qml/controls" as CCMP


SettingsView {
    id: root

    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    rowHeight: 48

    ColorPicker {
        id: colorPicker
        // set at rButton.onClicked
        property int systemIndex;

        dim: true
        x: parent.width/2 - width/2
        width: parent.width*0.7
        height: parent.height*0.7
        onColorAccepted: {
            GC.setSystemColorByIndex(systemIndex, t_color)
        }
    }

    model: VisualItemModel {
        Item {
            height: root.rowHeight;
            width: root.rowWidth;

            RowLayout {
                anchors.fill: parent
                anchors.rightMargin: 16
                anchors.leftMargin: 16

                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Language:")
                    font.pixelSize: 20
                    Layout.fillWidth: true
                }
                ZVisualComboBox {
                    id: localeCB
                    model: Z.tr("TRANSLATION_LOCALES")
                    imageModel: Z.tr("TRANSLATION_FLAGS")
                    height: root.rowHeight-8
                    width: height*2.5
                    contentRowHeight: height*1.2
                    contentFlow: GridView.FlowTopToBottom

                    property string intermediate: ZLocale.localeName
                    onIntermediateChanged: {
                        if(model[currentIndex] !== intermediate) {
                            currentIndex = model.indexOf(intermediate);
                        }
                    }

                    onSelectedTextChanged: {
                        if(ZLocale.localeName !== selectedText) {
                            GC.setLocale(selectedText, true);
                        }
                    }
                }
            }
        }

        Item {
            height: root.rowHeight;
            width: root.rowWidth;
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Display harmonic tables relative to the fundamental oscillation:")
                    font.pixelSize: 20

                    Layout.fillWidth: true
                }
                CheckBox {
                    id: actHarmonicsTableAsRelative
                    height: parent.height
                    Component.onCompleted: checked = GC.showFftTableAsRelative
                    onCheckedChanged: {
                        GC.setShowFftTableAsRelative(checked);
                    }
                }
            }
        }

        Item {
            height: root.rowHeight;
            width: root.rowWidth;
            RowLayout {
                anchors.fill: parent
                anchors.rightMargin: 0
                anchors.leftMargin: 16

                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Max decimals total:")
                    font.pixelSize: 20
                    Layout.fillWidth: true
                }

                ZSpinBox {
                    id: actDecimalPlacesTotal
                    text: GC.digitsTotal
                    validator: IntValidator {
                        bottom: 1
                        top: 7
                    }
                    function doApplyInput(newText) {
                        GC.setDigitsTotal(newText)
                        return true
                    }
                }
            }
        }

        Item {
            height: root.rowHeight;
            width: root.rowWidth;
            RowLayout {
                anchors.fill: parent
                anchors.rightMargin: 0
                anchors.leftMargin: 16

                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Max places after the decimal point:")
                    font.pixelSize: 20
                    Layout.fillWidth: true
                }

                ZSpinBox {
                    id: actDecimalPlaces
                    text: GC.decimalPlaces
                    validator: IntValidator {
                        bottom: 1
                        top: 7
                    }
                    function doApplyInput(newText) {
                        GC.setDecimalPlaces(newText)
                        return true
                    }
                }
            }
        }

        Item {
            visible: currentSession !== "com5003-ref-session.json" ///@todo replace hardcoded
            height: root.rowHeight;
            width: root.rowWidth;

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("System colors:")
                    font.pixelSize: 20
                }
                ListView {
                    clip: true
                    Layout.fillWidth: true
                    height: parent.height
                    model: root.channelCount
                    orientation: ListView.Horizontal
                    layoutDirection: "RightToLeft"
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollIndicator.horizontal: ScrollIndicator {
                        onActiveChanged: active = true;
                        active: true
                    }

                    delegate: Item {
                        width:  rButton.width// + lChannel.contentWidth
                        height: root.rowHeight

                        Button{
                            id: rButton
                            width: root.rowHeight*1.18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            text: {
                                var workingIndex = root.channelCount-index
                                var colorLead = "<font color='" + GC.systemColorByIndex(workingIndex) + "'>"
                                var colorTrail = "</font>"
                                return colorLead + ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(workingIndex)+"Range"].ChannelName + colorTrail
                            }
                            onClicked: {
                                colorPicker.systemIndex = root.channelCount-index;
                                /// @bug setting the the same value twice doesn't reset the sliders
                                colorPicker.oldColor = "transparent";
                                colorPicker.oldColor = GC.systemColorByIndex(colorPicker.systemIndex);
                                colorPicker.open();
                            }
                        }
                    }
                }
                Button {
                    font.family: FA.old
                    font.pointSize: 12
                    text: FA.fa_undo
                    onClicked: {
                        GC.setSystemDefaultColors()
                    }
                }
            }
        }
        Loader {
            active: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount > 6
            height: root.rowHeight;
            width: root.rowWidth;
            sourceComponent: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Show AUX phase values:")
                    font.pixelSize: 20

                    Layout.fillWidth: true
                }
                CheckBox {
                    height: parent.height
                    Component.onCompleted: checked = GC.showAuxPhases
                    onCheckedChanged: {
                        GC.setShowAuxPhases(checked);
                    }
                }
            }
        }
    }
}
