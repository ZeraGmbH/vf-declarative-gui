import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraTranslation 1.0
import VeinEntity 1.0

Button {
    id: overloadButton
    text: Z.tr("Overload")
    property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    enabled: rangeModule.PAR_Overload
    onClicked: {
        rangeModule.PAR_Overload = 0
    }
    background: Rectangle {
        radius: 2
        height: parent.height
        color: rangeModule.PAR_Overload ? "darkorange" : Material.switchDisabledHandleColor
    }
}
