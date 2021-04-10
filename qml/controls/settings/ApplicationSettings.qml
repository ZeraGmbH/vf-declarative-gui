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

    Timer {
        id: slowMachineSettingsHelper
        /* Our target machine is terribly slow and some change of settings cause
           a property change storm. To avoid repsponse times of several seconds
           on in GUI, we keep the settings changes, start a timer and apply the
           changes later. Doing so the GUI reponse is immediate.
          */
        interval: 800
        repeat: false
        function startAuxPhaseChange(showAux) {
            nextShowAux = showAux
            auxPhaseSetPending = true
            restart()
        }
        function startShowFftTableAsRelativeChange(fftTableRelative) {
            nextFftTableRelative = fftTableRelative
            fftTableRelativePending = true
            restart()
        }
        function startDigitsTotalChange(digitsTotal) {
            nextDigitsTotal = digitsTotal
            digitsTotalPending = true
            restart()
        }
        function startDecimalPlacesChange(decimalPlaces) {
            nextDecimalPlaces = decimalPlaces
            decimalPlacesPending = true
            restart()
        }
        function startAllColorChange(colorScheme) {
            nextColorScheme = colorScheme
            allColorChangePending = true
            restart()
        }
        function getCurrentColor(index) {
            if(!allColorChangePending) {
                return GC.currentColorTable[index-1]
            }
            else {
                return GC.defaultColorsTableArray[nextColorScheme][index-1]
            }
        }

        property bool auxPhaseSetPending: false
        property bool allColorChangePending: false
        property bool fftTableRelativePending: false
        property bool digitsTotalPending: false
        property bool decimalPlacesPending: false

        property bool nextShowAux: false
        property int  nextColorScheme: 0
        property bool nextFftTableRelative: false
        property int  nextDigitsTotal: 0
        property int  nextDecimalPlaces: 0

        function applyPendingChanges() {
            if(auxPhaseSetPending) {
                GC.setShowAuxPhases(nextShowAux);
                auxPhaseSetPending = false
            }
            if(allColorChangePending) {
                GC.setSystemDefaultColors(nextColorScheme)
                allColorChangePending = false
            }
            if(fftTableRelativePending) {
                GC.setShowFftTableAsRelative(nextFftTableRelative)
                fftTableRelativePending = false
            }
            if(digitsTotalPending) {
                GC.setDigitsTotal(nextDigitsTotal)
                digitsTotalPending = false
            }
            if(decimalPlacesPending) {
                GC.setDecimalPlaces(nextDecimalPlaces)
                decimalPlacesPending = false
            }
        }
        onTriggered: {
            applyPendingChanges()
        }
        Component.onDestruction: {
            applyPendingChanges()
        }
    }

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
                id: sliderCurrent
                anchors.verticalCenter: parent.verticalCenter
                width: defaultColoursPopup.sliderWidth
                from: 0.5
                to: 1.9
                property bool completed: false
                Component.onCompleted: {
                    value = GC.currentBrightness
                    completed = true
                }
                onValueChanged: {
                    if(completed) {
                        GC.setCurrentBrigtness(value)
                    }
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
                id: sliderBlack
                anchors.verticalCenter: parent.verticalCenter
                width: defaultColoursPopup.sliderWidth
                from: 1
                to: 35
                property bool completed: false
                Component.onCompleted: {
                    value = GC.blackBrightness
                    completed = true
                }
                onValueChanged: {
                    if(completed) {
                        GC.setBlackBrigtness(value)
                    }
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
                GC.restoreDefaultBrighnesses()
                sliderCurrent.value = GC.currentBrightness
                sliderBlack.value = GC.blackBrightness
            }
        }
        ListView {
            id: colourListView
            anchors.top: sliderRowBlack.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 4
            readonly property int countColourThemes: GC.defaultColorsTableArray.length
            model: countColourThemes
            interactive: false
            delegate: Rectangle {
                id: lineDelegate
                readonly property int row: index
                width: colourListView.width
                height: (colourListView.height - (colourListView.countColourThemes-1) * colourListView.spacing)/ colourListView.countColourThemes
                radius: 4
                color: Material.backgroundColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        slowMachineSettingsHelper.startAllColorChange(index)
                        defaultColoursPopup.close()
                    }
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    Repeater {
                        model: root.channelCount
                        Label {
                            Layout.fillHeight: true
                            text: ModuleIntrospection.rangeIntrospection.ComponentInfo[`PAR_Channel${index+1}Range`].ChannelName
                            font.pointSize: colourListView.height * 0.040
                            color: GC.defaultColorsTableArray[lineDelegate.row][index]
                            verticalAlignment: Text.AlignVCenter
                            textFormat: Text.PlainText
                        }
                    }
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
                        slowMachineSettingsHelper.startShowFftTableAsRelativeChange(checked)
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
                    Component.onCompleted: text = GC.digitsTotal
                    validator: IntValidator {
                        bottom: 1
                        top: 7
                    }
                    function doApplyInput(newText) {
                        slowMachineSettingsHelper.startDigitsTotalChange(newText)
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
                    Component.onCompleted: text = GC.decimalPlaces
                    validator: IntValidator {
                        bottom: 1
                        top: 7
                    }
                    function doApplyInput(newText) {
                        slowMachineSettingsHelper.startDecimalPlacesChange(newText)
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
                                let workingIndex = root.channelCount-index
                                let colorLead = "<font color='" + slowMachineSettingsHelper.getCurrentColor(workingIndex) + "'>"
                                let colorTrail = "</font>"
                                return colorLead + ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(workingIndex)+"Range"].ChannelName + colorTrail
                            }
                            onClicked: {
                                colorPicker.systemIndex = root.channelCount-index;
                                /// @bug setting the the same value twice doesn't reset the sliders
                                colorPicker.oldColor = "transparent";
                                colorPicker.oldColor = slowMachineSettingsHelper.getCurrentColor(colorPicker.systemIndex);
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
                        slowMachineSettingsHelper.startAuxPhaseChange(checked)
                    }
                }
            }
        }
    }
}
