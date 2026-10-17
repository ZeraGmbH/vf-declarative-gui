import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Layouts 1.14
import ZeraTranslation 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import ZeraThemeConfig 1.0

Rectangle {
    id: root
    // setters
    property var entity
    property var entityIntrospection
    property real rowHeight
    property real pointSize

    visible: entity.PAR_MeasuringMode === "QREF" && "PAR_FOUT_QREF_FREQ" in entityIntrospection.ComponentInfo
    height: visible ? rowHeight + overFreqIndicatorHeight : 0
    width: parent.width
    readonly property var validatorFrequency: visible ? entityIntrospection.ComponentInfo.PAR_FOUT_QREF_FREQ.Validation : { Data: [ 0,0,0 ] }
    readonly property real overFreqIndicatorHeight: parseFloat(frequencyLine.text) > 200 ? rowHeight*0.7 : 0

    color: ZTC.buttonColor
    border.color: Material.dropShadowColor

    RowLayout {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: rowHeight
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
            id: frequencyLine
            Layout.fillHeight: true
            Layout.fillWidth: true
            textField.topPadding: rowHeight * 0.225 // underline visibility
            textField.bottomPadding: rowHeight * 0.225
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
    Label {
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: overFreqIndicatorHeight
        visible: height > 0
        text: Z.tr("> 200 kHz for internal tests only!")
        color: "red"
        font.pointSize: pointSize
        verticalAlignment: Label.AlignVCenter
        horizontalAlignment: Label.AlignHCenter
    }
}
