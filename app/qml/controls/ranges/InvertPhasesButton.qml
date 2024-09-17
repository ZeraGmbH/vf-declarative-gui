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
    property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    property var order: MeasChannelInfo.channelCountTotal === 8 ? [1,2,3,7,4,5,6,8] : [1,2,3,4,5,6]
    property var phaseNamesInOrder: []
    onClicked: popup.open()

    function populatePhaseNamesInOrder(count) {
        for(var i = 0; i<count; i++){
            phaseNamesInOrder.push([MeasChannelInfo.channelNames[order[i]-1],order[i]])
        }
    }

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
            spacing: 2

            Repeater {
                model: MeasChannelInfo.channelCountTotal
                delegate: invertPhasesButton.populatePhaseNamesInOrder(MeasChannelInfo.channelCountTotal)
            }

            Repeater {
                model: MeasChannelInfo.channelCountTotal
                delegate: ZCheckBox {
                    required property int index
                    checked: rangeModule["PAR_InvertPhase%1".arg(phaseNamesInOrder[index][1])]
                    text: "<font color=\"" + FT.getColorByIndex(phaseNamesInOrder[index][1]) + "\">" + phaseNamesInOrder[index][0] + "</font>"
                    height: invertPhasesButton.height
                    onCheckedChanged: rangeModule["PAR_InvertPhase%1".arg(phaseNamesInOrder[index][1])] = checked
                }
            }
        }
    }
}
