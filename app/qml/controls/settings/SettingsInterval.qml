import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Layouts 1.14
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

Item {
    id: root
    property real pointSize
    property real rowHeight
    height: hasPeriodIntegration ? 2*rowHeight : rowHeight

    readonly property QtObject integrationGlobalEntity: VeinEntity.getEntity("DspSuperModule1")
    readonly property bool hasTimeIntegration: integrationGlobalEntity.hasComponent('PAR_IntervalGlobalTime')
    readonly property bool hasPeriodIntegration: integrationGlobalEntity.hasComponent('PAR_IntervalGlobalPeriod')
    readonly property var componentInfo: ModuleIntrospection.dspSuperIntrospection.ComponentInfo
    readonly property var validatorTime: hasTimeIntegration ? componentInfo.PAR_IntervalGlobalTime.Validation : ""
    readonly property var validatorPeriod: hasPeriodIntegration ? componentInfo.PAR_IntervalGlobalPeriod.Validation : ""

    Loader {
        id: loaderTime
        anchors.top: parent.top
        width: parent.width
        height: parent.rowHeight
        sourceComponent: timeComponent
        active: hasTimeIntegration
        asynchronous: true
    }

    Loader {
        anchors.top: loaderTime.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.rowHeight
        sourceComponent: periodComponent
        active: hasPeriodIntegration
        asynchronous: true
    }

    Component {
        id: timeComponent
        RowLayout {
            anchors.fill: parent
            Label {
                text: Z.tr("Integration time interval") + " [s]:"
                font.pointSize: root.pointSize
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Item { Layout.fillWidth: true }
            VFSpinBox {
                spinBox.width: root.width / 4
                pointSize: root.pointSize
                Layout.fillHeight: true
                entity: integrationGlobalEntity
                controlPropertyName: "PAR_IntervalGlobalTime"
                stepSize: validatorTime.Data[2] * Math.pow(10, dblValidatorTime.decimals)
                validator: ZDoubleValidator {
                    id: dblValidatorTime
                    bottom: validatorTime.Data[0]
                    top: validatorTime.Data[1]
                    decimals: FT.ceilLog10Of1DividedByX(validatorTime.Data[2])
                }
            }
        }
    }
    Component {
        id: periodComponent
        RowLayout {
            anchors.fill: parent
            Label {
                text: Z.tr("Integration period interval:")
                font.pointSize: root.pointSize
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Item { Layout.fillWidth: true }
            VFSpinBox {
                spinBox.width: root.width / 4
                Layout.fillHeight: true
                pointSize: root.pointSize
                entity: integrationGlobalEntity
                controlPropertyName: "PAR_IntervalGlobalPeriod"
                stepSize: 5
                validator: ZDoubleValidator{
                    bottom: validatorPeriod.Data[0]
                    top: validatorPeriod.Data[1]
                    decimals: FT.ceilLog10Of1DividedByX(validatorPeriod.Data[2])
                }
            }
        }
    }
}
