import QtQuick 2.0
import ZeraVeinComponents 1.0
import PowerModuleVeinGetter 1.0
import ZeraTranslation 1.0

VFComboBox {
    id: root
    // override
    function translateText(text){
        return Z.tr(text)
    }
    property int power1ModuleIdx // setter
    entity: PwrModVeinGetter.getEntity(power1ModuleIdx)
    controlPropertyName: "PAR_MeasuringMode"
    model: PwrModVeinGetter.getEntityJsonInfo(power1ModuleIdx).ComponentInfo[controlPropertyName].Validation.Data
    arrayMode: true
    fadeOutOnClose: true
    centerVerticalOffset: -contentRowHeight*(Math.min(modelLength-1, contentMaxRows-1)) +
                          (height-contentRowHeight) -
                          headerItem.height
    contentMaxRows: 6
    contentRowHeight: height*0.85
    headerComponent: Column {
        height: comboHeader.height + comboHeaderPhase.height
        MeasModeComboHeader {
            id: comboHeader
            visibleHeight: contentRowHeight * 1.75
            entity: root.entity
            entityIntrospection: PwrModVeinGetter.getEntityJsonInfo(power1ModuleIdx)
        }
        MeasModeComboHeaderPhase {
            id: comboHeaderPhase
            visibleHeight: contentRowHeight * 0.9
            entity: root.entity
        }
    }
}
