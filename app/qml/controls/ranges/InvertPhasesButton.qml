import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraTranslation 1.0
import VeinEntity 1.0
import ZeraComponents 1.0
import FunctionTools 1.0
import MeasChannelInfo 1.0

Button {
    id: invertPhasesButton
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property var order: MeasChannelInfo.channelCountTotal === 8 ? [1,2,3,7,4,5,6,8] : [1,2,3,4,5,6]
    readonly property var phaseNamesInOrder: {
        let names = []
        for(var i = 0; i < MeasChannelInfo.channelCountTotal; i++){
            names.push([MeasChannelInfo.channelNames[order[i]-1],order[i]])
        }
        return names
    }
    readonly property string text_color: {
        let color = "white"
        for(var i = 1; i <= MeasChannelInfo.channelCountTotal; i++){
            if (rangeModule["PAR_InvertPhase%1".arg(i)] === 1) {
                color = "darkorange"
                break
            }
        }
        return color
    }

    text: "<font color=\"" + text_color + "\">" + Z.tr("Invert") + "</font>"

    onClicked: popup.open()

    Popup {
        id: popup
        anchors.centerIn: Overlay.overlay
        //overlay puts the popup in centre of screen, so we shift it upwards over 'invertPhasesButton'
        bottomMargin: root.height * 0.75
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        Grid {
            id: grid
            columns: MeasChannelInfo.channelCountTotal / 2
            Repeater {
                model: MeasChannelInfo.channelCountTotal
                delegate: ZCheckBox {
                    checked: rangeModule["PAR_InvertPhase%1".arg(phaseNamesInOrder[index][1])]
                    text: "<font color=\"" + FT.getColorByIndex(phaseNamesInOrder[index][1]) + "\">" + phaseNamesInOrder[index][0] + "</font>"
                    height: invertPhasesButton.height
                    width: root.width * 0.15
                    controlHeight: height * 0.3
                    onCheckedChanged: rangeModule["PAR_InvertPhase%1".arg(phaseNamesInOrder[index][1])] = checked
                }
            }
        }
    }
}
