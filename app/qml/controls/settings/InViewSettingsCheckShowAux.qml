import QtQuick 2.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import SlowMachineSettingsHelper 1.0
import ZeraComponents 1.0
import GlobalConfig 1.0

Loader {
    // Properies to set
    property real enabledHeight

    readonly property bool hasAux: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount > 6
    active: hasAux
    height: hasAux ? enabledHeight : 0
    sourceComponent: ZCheckBox {
        anchors.fill: parent
        text: "<b>" + Z.tr("Show AUX phase values") + "</b>"
        checked: GC.showAuxPhases
        onCheckedChanged: SlwMachSettingsHelper.startAuxPhaseChange(checked)
    }
}
