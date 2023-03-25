import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import AppStarterForWebGLSingleton 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import ZeraFa 1.0
import anmsettings 1.0
import ZeraLocale 1.0
import SlowMachineSettingsHelper 1.0

SettingsView {
    id: root

    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    rowHeight: height/8.5
    readonly property real pointSize: height > 0 ? height * 0.04 : 10
    readonly property int pixelSize: pointSize*1.4

    ColorPicker {
        id: colorPicker
        // set at rButton.onClicked
        property int systemIndex

        dim: true
        x: parent.width/2 - width/2
        width: parent.width*0.7
        height: parent.height*0.7
        onColorAccepted: {
            GC.setSystemColorByIndex(systemIndex, t_color)
        }
    }

    DefaultColorPopup {
        id: defaultColoursPopup
        x: root.width * 5 / 10
        y: 0
        height: root.height - y
        width: root.width - x
    }

    model: VisualItemModel {
        Item {
            height: root.rowHeight
            width: root.rowWidth
            RowLayout {
                anchors.fill: parent
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Language:")
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                }
                ZVisualComboBox {
                    id: localeCB
                    model: Z.tr("TRANSLATION_LOCALES")
                    imageModel: Z.tr("TRANSLATION_FLAGS")
                    height: root.rowHeight * 0.9
                    width: height*2.5
                    contentRowHeight: height*1.2
                    property string intermediate: ZLocale.localeName

                    onIntermediateChanged: {
                        if(model[currentIndex] !== intermediate) {
                            currentIndex = model.indexOf(intermediate)
                        }
                    }
                    onSelectedTextChanged: {
                        if(ZLocale.localeName !== selectedText) {
                            GC.setLocale(selectedText, true)
                        }
                    }
                }
            }
        }
        Item {
            height: root.rowHeight
            width: root.rowWidth
            RowLayout {
                anchors.fill: parent
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Display harmonic tables relative to the fundamental oscillation:")
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                }
                CheckBox {
                    id: actHarmonicsTableAsRelative
                    height: parent.height
                    Component.onCompleted: checked = GC.showFftTableAsRelative
                    onCheckedChanged: {
                        SlwMachSettingsHelper.startShowFftTableAsRelativeChange(checked)
                    }
                }
            }
        }
        Item {
            height: root.rowHeight
            width: root.rowWidth
            RowLayout {
                anchors.fill: parent
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Max decimals total:")
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                }
                ZSpinBox {
                    id: actDecimalPlacesTotal
                    pointSize: root.pointSize
                    spinBox.width: root.rowWidth / 4
                    Component.onCompleted: text = GC.digitsTotal
                    validator: IntValidator {
                        bottom: 1
                        top: 7
                    }
                    function doApplyInput(newText) {
                        SlwMachSettingsHelper.startDigitsTotalChange(newText)
                        return true
                    }
                }
            }
        }

        Item {
            height: root.rowHeight
            width: root.rowWidth
            RowLayout {
                anchors.fill: parent
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Max places after the decimal point:")
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                }
                ZSpinBox {
                    id: actDecimalPlaces
                    pointSize: root.pointSize
                    spinBox.width: root.rowWidth / 4
                    Component.onCompleted: text = GC.decimalPlaces
                    validator: IntValidator {
                        bottom: 1
                        top: 7
                    }
                    function doApplyInput(newText) {
                        SlwMachSettingsHelper.startDecimalPlacesChange(newText)
                        return true
                    }
                }
            }
        }

        Item {
            id: colorRow
            visible: currentSession !== "com5003-ref-session.json" ///@todo replace hardcoded
            height: root.rowHeight
            width: root.rowWidth

            RowLayout {
                anchors.fill: parent
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("System colors:")
                    font.pointSize: pointSize
                }
                ListView {
                    clip: true
                    Layout.fillWidth: true
                    height: parent.height
                    model: root.channelCount
                    orientation: ListView.Horizontal
                    layoutDirection: "RightToLeft"
                    spacing: 2
                    boundsBehavior: Flickable.OvershootBounds
                    ScrollIndicator.horizontal: ScrollIndicator {
                        onActiveChanged: active = true
                        active: true
                    }
                    delegate: Item {
                        width:  rButton.width
                        height: root.rowHeight
                        Button {
                            id: rButton
                            width: root.rowHeight*1.18
                            font.pointSize: pointSize * 0.65
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            text: {
                                let workingIndex = root.channelCount-index
                                let colorLead = "<font color='" + SlwMachSettingsHelper.getCurrentColor(workingIndex) + "'>"
                                let colorTrail = "</font>"
                                return colorLead + Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(workingIndex)+"Range"].ChannelName) + colorTrail
                            }
                            onClicked: {
                                colorPicker.systemIndex = root.channelCount-index
                                /// @bug setting the the same value twice doesn't reset the sliders
                                colorPicker.oldColor = "transparent"
                                colorPicker.oldColor = SlwMachSettingsHelper.getCurrentColor(colorPicker.systemIndex)
                                colorPicker.open()
                            }
                        }
                    }
                }
                Button {
                    font.pointSize: root.rowHeight * 0.15
                    text: "▼"
                    onClicked: {
                        defaultColoursPopup.open()
                    }
                }
            }
        }
        Loader {
            active: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount > 6
            height: root.rowHeight
            width: root.rowWidth
            sourceComponent: RowLayout {
                anchors.fill: parent
                Label {
                    textFormat: Text.PlainText
                    text: Z.tr("Show AUX phase values:")
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                }
                CheckBox {
                    height: parent.height
                    Component.onCompleted: checked = GC.showAuxPhases
                    onCheckedChanged: {
                        SlwMachSettingsHelper.startAuxPhaseChange(checked)
                    }
                }
            }
        }
        Item {
            height: root.rowHeight
            width: root.rowWidth
            visible: !ASWGL.isServer
            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 24+labelRemotWeb.width
                anchors.rightMargin: 24+webOnOff.width
                anchors.topMargin: -root.rowHeight / 8
                anchors.bottomMargin: -root.rowHeight / 8
                visible: ASWGL.running
                ListView {
                    id: ipInfo
                    anchors.fill: parent
                    anchors.margins: root.rowHeight / 6
                    width: parent.width
                    boundsBehavior: Flickable.OvershootBounds
                    spacing: root.rowHeight / 8
                    model: InfoInterface { }
                    delegate: RowLayout {
                        Text {
                            font.pointSize: root.rowHeight / 5.2
                            text: ipv4 + ':' + ASWGL.port
                        }
                        Rectangle {
                            Layout.fillWidth: true
                        }
                    }
                }
            }
            RowLayout {
                anchors.fill: parent
                Label {
                    id: labelRemotWeb
                    textFormat: Text.PlainText
                    text: !ASWGL.running ? Z.tr("Remote web (experimental):") : Z.tr("Browser addresses:")
                    font.pointSize: pointSize
                }
                Item { Layout.fillWidth: true }
                CheckBox {
                    id: webOnOff
                    height: parent.height
                    checked: ASWGL.running
                    onCheckedChanged: {
                        if(!ASWGL.running) {
                            ASWGL.applicationPath = "vf-declarative-gui"
                            let params = ["-w"]
                            //params.push("-s")
                            ASWGL.additionalParams = params
                        }
                        ASWGL.running = checked
                    }
                }
            }
        }
    }
}
