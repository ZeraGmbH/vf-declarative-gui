import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import SessionState 1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import AppStarterForWebGLSingleton 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import anmsettings 1.0
import ZeraLocale 1.0
import SlowMachineSettingsHelper 1.0

SettingsView {
    id: root

    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    readonly property real safeHeight: height > 0.0 ? height : 10
    rowHeight: safeHeight/8.5
    readonly property real pointSize: rowHeight * 0.34

    ColorPicker {
        id: colorPicker
        // set at rButton.onClicked
        property int systemIndex

        dim: true
        x: parent.width/2 - width/2
        width: root.width*0.7
        height: root.safeHeight*0.7
        onColorAccepted: {
            GC.setSystemColorByIndex(systemIndex, t_color)
        }
    }

    DefaultColorPopup {
        id: defaultColoursPopup
        x: root.width * 5 / 10
        y: 0
        height: root.safeHeight - y
        width: root.width - x
    }

    model: VisualItemModel {
        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Language:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZVisualComboBox {
                id: localeCB
                model: Z.tr("TRANSLATION_LOCALES")
                imageModel: Z.tr("TRANSLATION_FLAGS")
                Layout.preferredHeight: root.rowHeight * 0.9
                Layout.preferredWidth: Layout.preferredHeight*2.5
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
        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Harm. table relative to the fundamental:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZCheckBox {
                id: actHarmonicsTableAsRelative
                Layout.fillHeight: true
                Component.onCompleted: checked = GC.showFftTableAsRelative
                onCheckedChanged: {
                    SlwMachSettingsHelper.startShowFftTableAsRelativeChange(checked)
                }
            }
        }
        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Show angles in harmonics:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZCheckBox {
                id: actHarmonicsShowAngles
                Layout.fillHeight: true
                Component.onCompleted: checked = GC.showFftTableAngles
                onCheckedChanged: {
                    SlwMachSettingsHelper.startShowFftAnglesChange(checked)
                }
            }
        }
        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Max decimals total:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZSpinBox {
                id: actDecimalPlacesTotal
                Layout.fillHeight: true
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

        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Max places after the decimal point:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZSpinBox {
                id: actDecimalPlaces
                Layout.fillHeight: true
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

        RowLayout {
            visible: !SessionState.refSession
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("System colors:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ListView {
                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.channelCount
                orientation: ListView.Horizontal
                layoutDirection: "RightToLeft"
                spacing: 2
                delegate: Button {
                    id: rButton
                    width: root.rowHeight*1.18
                    height: root.rowHeight
                    font.pointSize: pointSize * 0.65
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
            Button {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillHeight: true
                Layout.preferredWidth: root.rowHeight * 0.7
                font.pointSize: root.rowHeight * 0.2
                text: "▼"
                onClicked: {
                    defaultColoursPopup.open()
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
                    text: Z.tr("Show AUX phase values:")
                    textFormat: Text.PlainText
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Label.AlignVCenter
                }
                ZCheckBox {
                    Layout.fillHeight: true
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
            RowLayout {
                anchors.fill: parent
                Label {
                    id: labelRemotWeb
                    text: !ASWGL.running ? Z.tr("Remote web (experimental):") : Z.tr("Browser addresses:")
                    textFormat: Text.PlainText
                    font.pointSize: pointSize
                    Layout.fillHeight: true
                    verticalAlignment: Label.AlignVCenter
                }
                Rectangle {
                    opacity: ASWGL.running ? 1 : 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ListView {
                        id: ipInfo
                        anchors.fill: parent
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: root.rowHeight / 6
                        boundsBehavior: Flickable.OvershootBounds
                        orientation: ListView.Horizontal
                        spacing: root.rowHeight / 2
                        model: InfoInterface { }
                        delegate: Text {
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: root.rowHeight / 3.5
                            text: ipv4 + ':' + ASWGL.port
                        }
                    }
                }
                ZCheckBox {
                    id: webOnOff
                    Layout.fillHeight: true
                    checked: ASWGL.running
                    onCheckedChanged: {
                        let userWantsOn = !ASWGL.running && checked
                        if(userWantsOn)
                            GC.setWebRemoteOn(true)
                        let userWantsOff = ASWGL.running && !checked
                        if(userWantsOff)
                            GC.setWebRemoteOn(false)
                        ASWGL.running = checked
                    }
                }
            }
        }
    }
}
