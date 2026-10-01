import QtQuick 2.0
import ZeraVeinComponents 1.0
import PowerModuleVeinGetter 1.0
import ZeraTranslation 1.0

VFComboBox {
    id: root
    // override
    function translateText(text) {
        if(text === "QREF")
            return Z.tr("Fixed Freq.")
        return Z.tr(text)
    }
    property int power1ModuleIdx // setter
    entity: PwrModVeinGetter.getPowerModuleEntity(power1ModuleIdx)
    property var entityIntrospection: PwrModVeinGetter.getEntityJsonInfo(power1ModuleIdx)
    controlPropertyName: "PAR_MeasuringMode"
    model: entityIntrospection.ComponentInfo[controlPropertyName].Validation.Data
    arrayMode: true
    fadeOutOnClose: true
    contentMaxRows: 6
    // comboHeaderQRefFrequency needs horizontal pixels
    displayColumns: entity.PAR_MeasuringMode === "QREF" ? Math.max(2, defaultDisplayColumns) : defaultDisplayColumns
    headerComponent: Column {
        height: comboHeader.height + comboHeaderPhase.height + comboHeaderQRefFrequency.height
        MeasModeComboHeader {
            id: comboHeader
            rowHeight: root.height * 0.55
            entity: root.entity
            entityIntrospection: root.entityIntrospection
        }
        MeasModeComboHeaderPhase {
            id: comboHeaderPhase
            visibleHeight: root.height
            entity: root.entity
        }
        MeasModeComboHeaderQRefFrequency {
            id: comboHeaderQRefFrequency
            rowHeight: root.height
            pointSize: root.pointSize
            entity: root.entity
            entityIntrospection: root.entityIntrospection
        }
    }
}
