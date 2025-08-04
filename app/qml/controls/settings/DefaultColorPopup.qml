import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import ColorSettings 1.0
import ZeraTranslation  1.0
import FontAwesomeQml 1.0
import SlowMachineSettingsHelper 1.0

Loader {
    id: root
    active: false

    function open() {
        active = true
        item.x = x
        item.y = y
        item.height = height
        item.width = width
        item.open()
    }
    sourceComponent: Popup {
        id: popup
        parent: root.parent

        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
        onAboutToShow: {
            sliderCurrent.value = CS.currentBrightness
            sliderBlack.value = CS.blackBrightness
        }

        ListView {
            id: colourListView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: sliderRowBrightness.top
            spacing: 4
            readonly property int countColourThemes: CS.defaultColorsTableArray.length
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
                        SlwMachSettingsHelper.startAllColorChange(index)
                        popup.close()
                    }
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    Repeater {
                        model: popup.channelCount
                        Label {
                            Layout.fillHeight: true
                            text: Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo[`PAR_Channel${index+1}Range`].ChannelName)
                            font.pointSize: colourListView.height * 0.040
                            color: CS.defaultColorsTableArray[lineDelegate.row][index]
                            verticalAlignment: Text.AlignVCenter
                            textFormat: Text.PlainText
                        }
                    }
                }
            }
        }
        readonly property real sliderLabelWidth: width * 0.45
        readonly property real sliderWidth: width * 0.35
        readonly property real sliderRowHeight: height * 0.1
        readonly property real labelPointSize: colourListView.height * 0.04
        Row {
            id: sliderRowBrightness
            anchors.bottom: sliderRowBlack.top
            anchors.left: parent.left
            width: popup.sliderLabelWidth+popup.sliderWidth
            height: popup.sliderRowHeight
            Label {
                text: Z.tr("Brightness currents:")
                anchors.verticalCenter: parent.verticalCenter
                width: popup.sliderLabelWidth
                font.pointSize: popup.labelPointSize
            }
            Slider {
                id: sliderCurrent
                anchors.verticalCenter: parent.verticalCenter
                width: popup.sliderWidth
                from: 0.5
                to: 1.9
                onValueChanged: {
                    if (popup.opened)
                        CS.setCurrentBrightness(value)
                }
            }
        }
        Row {
            id: sliderRowBlack
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: popup.sliderLabelWidth+popup.sliderWidth
            height: popup.sliderRowHeight
            Label {
                text: Z.tr("Brightness black:")
                anchors.verticalCenter: parent.verticalCenter
                width: popup.sliderLabelWidth
                font.pointSize: popup.labelPointSize
            }
            Slider {
                id: sliderBlack
                anchors.verticalCenter: parent.verticalCenter
                width: popup.sliderWidth
                from: 1
                to: 35
                onValueChanged: {
                    if (popup.opened)
                        CS.setBlackBrigtness(value)
                }
            }
        }
        Button {
            text: FAQ.fa_undo
            font.pointSize: popup.labelPointSize
            anchors.right: parent.right
            width: popup.width * 0.125

            anchors.verticalCenter: sliderRowBrightness.bottom
            onClicked: {
                CS.restoreDefaultBrighnesses()
                sliderCurrent.value = CS.currentBrightness
                sliderBlack.value = CS.blackBrightness
            }
        }
    }
}
