import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Layouts 1.14
import VeinEntity 1.0
import ZeraTranslation 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import FontAwesomeQml 1.0

Rectangle {
    id: root
    // setters
    property var entity
    property var entityIntrospection
    property real rowHeight
    property real pointSize

    visible: entity.PAR_MeasuringMode === "QREF" && "PAR_FOUT_QREF_FREQ" in entityIntrospection.ComponentInfo
    height: visible ? rowHeight : 0
    width: parent.width
    readonly property var validatorFrequency: visible ? entityIntrospection.ComponentInfo.PAR_FOUT_QREF_FREQ.Validation : { Data: [ 0,0,0 ] }

    color: Qt.darker(Material.frameColor)
    border.color: Material.dropShadowColor

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.rightMargin: GC.standardTextHorizMargin
        Label {
            Layout.fillHeight: true
            Layout.preferredWidth: root.width * 0.5 - GC.standardTextHorizMargin * 1.5
            font.pointSize: pointSize
            verticalAlignment: Label.AlignVCenter
            text: Z.tr("Frequency:")
        }
        VFLineEdit {
            Layout.fillHeight: true
            Layout.fillWidth: true
            textField.topPadding: root.height * 0.225 // underline visibility
            textField.bottomPadding: root.height * 0.225
            entity: root.entity
            controlPropertyName: root.visible ? "PAR_FOUT_QREF_FREQ" : ""
            pointSize: root.pointSize
            validator: ZDoubleValidator {
                bottom: validatorFrequency.Data[0]
                top: validatorFrequency.Data[1]
                decimals: FT.ceilLog10Of1DividedByX(validatorFrequency.Data[2])
            }
        }
        Label {
            Layout.fillHeight: true
            font.pointSize: pointSize
            verticalAlignment: Label.AlignVCenter
            text: "kHz"
        }
    }
}
