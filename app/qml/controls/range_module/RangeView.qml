import QtQuick 2.0
import QtQuick.Controls 2.0
import VeinEntity 1.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import ModuleIntrospection 1.0
//import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraTranslation  1.0
import ZeraVeinComponents 1.0
import ZeraComponents 1.0
import QtQml.Models 2.11

ListView {
    id: ranges

    property real rangeWidth
    property real rangeHeight
    width: rangeWidth
    height: rangeHeight

    boundsBehavior: Flickable.StopAtBounds
    orientation: ListView.Horizontal
    delegate: Item {
        height: ranges.rangeHeight
        width: ranges.rangeWidth/4
        Label {
            id: label
            text: Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData+1)+"Range"].ChannelName)
            color: FT.getColorByIndex(modelData+1, root.groupingActive)
            font.pointSize: smallPointSize
            anchors.bottom: parent.top
            anchors.bottomMargin: -(parent.height/3)
            anchors.horizontalCenter: parent.horizontalCenter
        }
        VFComboBox {
            arrayMode: true
            entity: VeinEntity.getEntity("RangeModule1")
            controlPropertyName: "PAR_Channel"+parseInt(modelData+1)+"Range"
            model: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData+1)+"Range"].Validation.Data
            contentMaxRows: 5
            centerVertical: true
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: label.bottom
            width: parent.width*0.95
            enabled: parent.enabled
        }
    }
}
