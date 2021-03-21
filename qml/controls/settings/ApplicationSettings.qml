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

    Popup {
        id: defaultColoursPopup
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: root.width * 5 / 10
        y: 0 //root.height * 1 / 20
        height: root.height - y
        width: root.width - x

        readonly property real sliderLabelWidth: width * 0.45
        readonly property real sliderWidth: width * 0.35
        readonly property real sliderRowHeight: height * 0.1
        readonly property real labelPointSize: colourListView.height * 0.04
        Row {
            id: sliderRowBrightness
            anchors.top: parent.top
            anchors.left: parent.left
            width: defaultColoursPopup.sliderLabelWidth+defaultColoursPopup.sliderWidth
            height: defaultColoursPopup.sliderRowHeight
            Label {
                text: Z.tr("Brightness currents:")
                anchors.verticalCenter: parent.verticalCenter
                width: defaultColoursPopup.sliderLabelWidth
                font.pointSize: defaultColoursPopup.labelPointSize
            }
            Slider {
                anchors.verticalCenter: parent.verticalCenter
                width: defaultColoursPopup.sliderWidth
                from: 0.5
                to: 1.9
                value: GC.currentBrightness
                onValueChanged: {
                    GC.setCurrentBrigtness(value)
                }
            }
        }
        Row {
            id: sliderRowBlack
            anchors.top: sliderRowBrightness.bottom
            anchors.left: parent.left
            width: defaultColoursPopup.sliderLabelWidth+defaultColoursPopup.sliderWidth
            height: defaultColoursPopup.sliderRowHeight
            Label {
                text: Z.tr("Brightness black:")
                anchors.verticalCenter: parent.verticalCenter
                width: defaultColoursPopup.sliderLabelWidth
                font.pointSize: defaultColoursPopup.labelPointSize
            }
            Slider {
                anchors.verticalCenter: parent.verticalCenter
                width: defaultColoursPopup.sliderWidth
                from: 1
                to: 35
                value: GC.blackBrightness
                onValueChanged: {
                    GC.setBlackBrigtness(value)
                }
            }
        }
        Button {
            text: FA.fa_undo
            font.family: FA.old
            font.pointSize: defaultColoursPopup.labelPointSize
            anchors.right: parent.right
            width: defaultColoursPopup.width * 0.125
            anchors.verticalCenter: sliderRowBrightness.bottom
            onClicked: {
                GC.setDefaultBrighnesses()
            }
        }
        ListView {
            id: colourListView
            anchors.top: sliderRowBlack.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 4
            property int countColourThemes: GC.defaultColorTable.length
            model: {
                let defColorTable = GC.defaultColorTable
                let phaseText, lineText
                let retVal = []
                for(let row=0; row<defColorTable.length; ++row) {
                    for(let column=0; column<root.channelCount; column++) {
                        let colorLead = "<font color='" + defColorTable[row][column] + "'>"
                        var colorTrail = "</font>"
                        phaseText = colorLead + ModuleIntrospection.rangeIntrospection.ComponentInfo[`PAR_Channel${column+1}Range`].ChannelName + colorTrail
                        if(column === 0) {
                            lineText =  phaseText
                        }
                        else {
                            lineText = lineText + "\t" + phaseText
                        }
                    }
                    retVal[row] = lineText
                }
                return retVal
            }
            delegate: Rectangle {
                width: colourListView.width
                height: (colourListView.height - (colourListView.countColourThemes-1) * colourListView.spacing)/ colourListView.countColourThemes
                radius: 4
                color: Material.backgroundColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        GC.setSystemDefaultColors(index)
                        defaultColoursPopup.close()
                    }
                }
                Label {
                    text: modelData
                    font.pointSize: colourListView.height * 0.042
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
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
            id: colorRow
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
                    boundsBehavior: Flickable.OvershootBounds
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
