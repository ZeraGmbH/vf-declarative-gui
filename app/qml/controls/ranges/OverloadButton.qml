import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraTranslation 1.0
import VeinEntity 1.0
import ZeraComponents 1.0

ZButton {
    id: overloadButton
    text: Z.tr("Overload")
    property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    enabled: rangeModule.PAR_Overload
    onClicked: {
        rangeModule.PAR_Overload = 0
    }
    Material.background: rangeModule.PAR_Overload ? "darkorange" : Material.buttonDisabledColor
}
