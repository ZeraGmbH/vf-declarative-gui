import QtQuick 2.0
import ZeraVeinComponents 1.0
import PowerModuleVeinGetter 1.0

VFComboBox {
    id: root
    property int power1ModuleIdx

    entity: PwrModVeinGetter.getEntity(power1ModuleIdx)
    controlPropertyName: "PAR_MeasuringMode"
    model: PwrModVeinGetter.getEntityJsonInfo(power1ModuleIdx).ComponentInfo[controlPropertyName].Validation.Data
    arrayMode: true
    centerVerticalOffset: -contentRowHeight*(Math.min(modelLength-1, contentMaxRows-1)) +
                          (height-contentRowHeight) -
                          headerItem.height
    contentMaxRows: 7
    contentRowHeight: height*0.85
    fontSize: height*0.3
    headerComponent: Column {
        height: comboHeader.height
        MeasModeComboHeader {
            id: comboHeader
            visibleHeight: root.height * 1.5
            entity: root.entity
            entityIntrospection: PwrModVeinGetter.getEntityJsonInfo(power1ModuleIdx)
        }
    }

}
