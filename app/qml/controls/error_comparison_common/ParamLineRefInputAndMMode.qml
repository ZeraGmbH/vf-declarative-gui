import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import ZeraVeinComponents 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import PowerModuleVeinGetter 1.0
import ZeraThemeConfig 1.0
import "../measurement_modes"

Loader {
    sourceComponent: Rectangle {
        color: Material.backgroundColor
        border.color: ZTC.dividerColor
        width: root.width
        height: root.rowHeight
        enabled: logicalParent.canStartMeasurement
        Label {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: GC.standardTextHorizMargin
            width: parent.width*col1Width
            anchors.verticalCenter: parent.verticalCenter
            text: Z.tr("Reference input:")
            font.pointSize: root.pointSize
        }
        VFComboBox {
            id: cbRefInput
            // override
            function translateText(text) {
                return Z.tr(text)
            }
            arrayMode: true
            entity: logicalParent.errCalEntity
            controlPropertyName: "PAR_RefInput"
            model: validatorRefInput.Data
            visible: model.length > 1

            x: parent.width*col1Width
            width: parent.width*col2Width - GC.standardMarginWithMin
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            pointSize: root.pointSize
        }
        Label { // fallback for one reference input
            textFormat: Text.PlainText
            visible: !cbRefInput.visible
            text: cbRefInput.model.length > 0 ? Z.tr(cbRefInput.model[0]) : ""
            x: parent.width*col1Width
            width: parent.width*col2Width - GC.standardMarginWithMin
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: root.pointSize
        }

        MeasModeCombo {
            model: measModeModel
            entity: VeinEntity.getEntityById(logicalParent.errCalEntity["ACT_PowerModuleEntityId"])
            entityIntrospection: JSON.parse(entity.INF_ModuleInterface)

            anchors.right: parent.right
            width: parent.width*col3Width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            pointSize: root.pointSize * 0.95
        }
    }
}
