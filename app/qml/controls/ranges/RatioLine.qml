import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import FontAwesomeQml 1.0

Item {
    property int prescalingGroup
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

    VFSwitch{
        id: enableRatio
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        text: Z.tr("Ratio") + ":"
        font.pointSize: pointSize
        entity: rangeModule
        controlPropertyName: "PAR_PreScalingEnabledGroup" + prescalingGroup
    }
}
