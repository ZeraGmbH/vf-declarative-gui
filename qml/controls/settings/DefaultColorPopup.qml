import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import ZeraTranslation  1.0
import ZeraFa 1.0 // TODO repace by FontAwesomeQml
import SlowMachineSettingsHelper 1.0

Popup {
    id: root

    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount

    ListView {
        id: colourListView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: sliderRowBrightness.top
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
                    SlwMachSettingsHelper.startAllColorChange(index)
                    root.close()
                }
            }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                Repeater {
                    model: root.channelCount
                    Label {
                        Layout.fillHeight: true
                        text: Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo[`PAR_Channel${index+1}Range`].ChannelName)
                        font.pointSize: colourListView.height * 0.040
                        color: GC.defaultColorsTableArray[lineDelegate.row][index]
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
        width: root.sliderLabelWidth+root.sliderWidth
        height: root.sliderRowHeight
        Label {
            text: Z.tr("Brightness currents:")
            anchors.verticalCenter: parent.verticalCenter
            width: root.sliderLabelWidth
            font.pointSize: root.labelPointSize
        }
        Slider {
            id: sliderCurrent
            anchors.verticalCenter: parent.verticalCenter
            width: root.sliderWidth
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
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: root.sliderLabelWidth+root.sliderWidth
        height: root.sliderRowHeight
        Label {
            text: Z.tr("Brightness black:")
            anchors.verticalCenter: parent.verticalCenter
            width: root.sliderLabelWidth
            font.pointSize: root.labelPointSize
        }
        Slider {
            id: sliderBlack
            anchors.verticalCenter: parent.verticalCenter
            width: root.sliderWidth
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
        font.pointSize: root.labelPointSize
        anchors.right: parent.right
        width: root.width * 0.125

        anchors.verticalCenter: sliderRowBrightness.bottom
        onClicked: {
            GC.restoreDefaultBrighnesses()
            sliderCurrent.value = GC.currentBrightness
            sliderBlack.value = GC.blackBrightness
        }
    }
}
