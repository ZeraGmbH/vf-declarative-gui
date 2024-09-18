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
    text: Z.tr("Invert")
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property var order: MeasChannelInfo.channelCountTotal === 8 ? [1,2,3,7,4,5,6,8] : [1,2,3,4,5,6]
    readonly property var phaseNamesInOrder: {
        let names = []
        for(var i = 0; i < MeasChannelInfo.channelCountTotal; i++){
            names.push([MeasChannelInfo.channelNames[order[i]-1],order[i]])
        }
        return names
    }
    onClicked: popup.open()

    Popup {
        id: popup
        anchors.centerIn: parent
        topMargin: parent.height * 0.5
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
                    width: invertPhasesButton.width * 0.8
                    controlHeight: height * 0.3
                    onCheckedChanged: rangeModule["PAR_InvertPhase%1".arg(phaseNamesInOrder[index][1])] = checked
                }
            }
        }
    }
}
