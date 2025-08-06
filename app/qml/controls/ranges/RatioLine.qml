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
    readonly property real sqrtComboWidth: width * 0.15
    readonly property color enableTextColor: enableRatio.checked ? Qt.lighter(Material.color(Material.Amber)) : Material.foreground
    function setRatioValueComponents(nominator, denominator, sqrtText) {
        rangeModule[groupComponentName] = nominator + "/" + denominator + (hasSqrtFactor ? sqrtText : "")
    }

    VFSwitch{
        id: enableRatio
        anchors.left: parent.left
        leftPadding: 0
        width: implicitWidth * 1.05
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        font.pointSize: pointSize
        text: Z.tr("Ratio")
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
        textField.color: enableTextColor
        validator: IntValidator{bottom: 1; top: 999999 }
        function doApplyInput(newText) {
            setRatioValueComponents(newText, editDenominator.text, sqrtComb.getVeinVal())
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
        textField.color: enableTextColor
        validator: IntValidator{bottom: 1; top: 999999 }
        function doApplyInput(newText) {
            setRatioValueComponents(editNominator.text, newText, sqrtComb.getVeinVal())
        }
    }
    Label {
        id: multLabel
        text: "*"
        visible: hasSqrtFactor
        anchors.left: editDenominator.right
        anchors.leftMargin: frameMargin * 0.5
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: pointSize
    }
    ZComboBox {
        id: sqrtComb
        height: rowHeight
        width: hasSqrtFactor ? sqrtComboWidth : 0
        visible: hasSqrtFactor
        anchors.left: multLabel.right
        anchors.leftMargin: frameMargin

        arrayMode: true
        model: ["1", "√3", "1 / √3"]
        function getVeinVal() {
            let veinValueModel = ["*(1)", "*(sqrt(3))", "*(1/sqrt(3))"]
            return veinValueModel[model.indexOf(selectedText)]
        }
        currentIndex: {
            if(rangeModule[groupComponentName].includes("(1/sqrt(3))"))
                return 2
            else if(rangeModule[groupComponentName].includes("(sqrt(3))"))
                return 1
            return 0;
        }
        onSelectedTextChanged: {
            setRatioValueComponents(editNominator.text, editDenominator.text, getVeinVal())
        }
    }
}
