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
    readonly property bool hasSqrtFactor: prescalingGroup === 0
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property string groupComponentName: "PAR_PreScalingGroup" + prescalingGroup
    readonly property var groupValues: rangeModule[groupComponentName].split("*")[0].split("/")
    readonly property real ratioEditWidth: width * 0.15
    readonly property real sqrtComboWidth: width * 0.125
    function setRatioValueComponents(nominator, denominator, sqrtText) {
        rangeModule[groupComponentName] = nominator + "/" + denominator + (hasSqrtFactor ? sqrtText : "")
    }
    VFSwitch{
        id: enableRatio
        anchors.left: parent.left
        width: implicitWidth * 1.03
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        font.pointSize: pointSize
        text: Z.tr("Ratio") + ":"
        entity: rangeModule
        controlPropertyName: "PAR_PreScalingEnabledGroup" + prescalingGroup
    }
    ZLineEdit {
        id: editNominator
        anchors.left: enableRatio.right
        width: ratioEditWidth
        height: rowHeight
        pointSize: root.pointSize

        text: groupValues[0]
        validator: IntValidator{bottom: 1; top: 999999 }
        function doApplyInput(newText) {
            setRatioValueComponents(newText, editDenominator.text, sqrtComb.currentText)
        }
    }
    Label {
        id: labelSeparator
        anchors.left: editNominator.right
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: pointSize
        text: "/"
    }
    ZLineEdit {
        id: editDenominator
        width: ratioEditWidth
        height: rowHeight
        anchors.left: labelSeparator.right
        pointSize: root.pointSize

        text: groupValues[1]
        validator: IntValidator{bottom: 1; top: 999999 }
        function doApplyInput(newText) {
            setRatioValueComponents(editNominator.text, newText, sqrtComb.currentText)
        }
    }
    ZVisualComboBox {
        id: sqrtComb
        height: rowHeight
        width: hasSqrtFactor ? sqrtComboWidth : 0
        visible: hasSqrtFactor
        anchors.left: editDenominator.right
        anchors.leftMargin: frameMargin * 0.5

        model: ["", "*(sqrt(3))", "*(1/sqrt(3))"]
        imageModel: ["qrc:/data/staticdata/resources/x_1.png", "qrc:/data/staticdata/resources/x_sqrt_3.png", "qrc:/data/staticdata/resources/x_1_over_sqrt_3.png"]
        currentIndex: {
            if(rangeModule[groupComponentName].includes("(1/sqrt(3))"))
                return 2
            else if(rangeModule[groupComponentName].includes("(sqrt(3))"))
                return 1
            return 0;
        }
        onSelectedTextChanged: {
            setRatioValueComponents(editNominator.text, editDenominator.text, selectedText)
        }
    }
}
