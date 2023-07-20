import QtQuick 2.5
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0

import "../controls/error_comparison_common"
import "../controls/error_comparison_params"

Item {
    id: root
    clip: true

    property QtObject errCalEntity
    property var moduleIntrospection
    property alias validatorMrate: paramView.validatorMrate
    property alias validatorEnergy: paramView.validatorEnergy
    property alias validatorUpperLimit: paramView.validatorUpperLimit
    property alias validatorLowerLimit: paramView.validatorLowerLimit

    property int status: errCalEntity.ACT_Status
    readonly property alias statusHolder: stateEnum
    readonly property bool canStartMeasurement: errCalEntity.PAR_StartStop !== 1
    readonly property real pointSize: root.height > 0 ? root.height * 0.03 : 10

    QtObject {
        id: stateEnum
        //some of these state bits can be active in parallel

        ///doing nothing waiting to start the measurement
        readonly property int idle: 0
        ///waiting for first pulse
        readonly property int armed: 1
        ///running
        readonly property int started: 2
        ///result is available
        readonly property int ready: 4
        ///measurement was aborted
        readonly property int aborted: 8
        ///measurement waits
        readonly property int wait: (1<<30)
    }

    Column {
        MeasurementView {
            logicalParent: root
            height: root.height*0.2
            width: root.width
            measurementResult: errCalEntity.ACT_Result
            progress: errCalEntity.ACT_Progress
            function updateProgess() {
                var text = parseInt(progress / progressTo * 100) + '%'
                // Not ACT_MeasNum reflects completed we are interested in
                // current -> +1
                var curMeasNum = parseInt(errCalEntity.ACT_MeasNum) + 1
                var measNimReq = errCalEntity.PAR_MeasCount
                if(errCalEntity.PAR_Continuous === 1) {
                    text += ' (' + curMeasNum + ')'
                }
                else if(measNimReq > 1){
                    text += ' (' + curMeasNum + '/' + measNimReq + ')'
                }
                progressText = text
            }
            onProgressChanged: updateProgess()
            progressTo: 100
            readonly property real currEnergy: errCalEntity.PAR_Continuous === 1 ? errCalEntity.ACT_EnergyFinal : errCalEntity.ACT_Energy
            readonly property var scaledEnergyArr: FT.doAutoScale(currEnergy, moduleIntrospection.ComponentInfo.ACT_Energy.Unit)
            readonly property int measNum: errCalEntity.ACT_MeasNum
            onMeasNumChanged: updateProgess() // for fast measurements
            actualValue: FT.formatNumber(scaledEnergyArr[0]) + " " + scaledEnergyArr[1]
        }
        Row {
            height: root.height*0.7
            width: root.width

            SwipeView {
                id: multiSwipe
                width: parent.width*0.8
                height: parent.height
                interactive: false
                orientation: Qt.Vertical
                clip: true
                ParamViewComparison {
                    id: paramView
                    logicalParent: root
                    validatorRefInput: moduleIntrospection.ComponentInfo.PAR_RefInput.Validation
                    validatorDutInput: moduleIntrospection.ComponentInfo.PAR_DutInput.Validation
                    validatorDutConstant: moduleIntrospection.ComponentInfo.PAR_DutConstant.Validation
                    validatorDutConstUnit: moduleIntrospection.ComponentInfo.PAR_DUTConstUnit.Validation
                    validatorUpperLimit: moduleIntrospection.ComponentInfo.PAR_Uplimit.Validation
                    validatorLowerLimit: moduleIntrospection.ComponentInfo.PAR_Lolimit.Validation
                }
                MultipleErrorView {
                    id: multipleErrorView
                    jsonResults: JSON.parse(root.errCalEntity.ACT_MulResult)
                    digitsTotal: GC.digitsTotal
                    decimalPlaces: GC.decimalPlaces
                    resultColumns: 4
                    resultRows: 10
                }
            }
            ErrorMarginView {
                result: root.errCalEntity.ACT_Result

                width: parent.width*0.2
                height: parent.height
                maxValue: errCalEntity.PAR_Uplimit
                minValue: errCalEntity.PAR_Lolimit
                rating: errCalEntity.ACT_Rating
                measNum: errCalEntity.ACT_MeasNum
                finished: errCalEntity.PAR_StartStop !== 1 && (errCalEntity.ACT_Status & stateEnum.aborted) === 0
            }
        }
        Item {
            height: root.height*0.1
            width: root.width
            Button {
                id: buttonStart
                text: Z.tr("Start")
                font.pointSize: pointSize

                width: root.width/5
                height: parent.height
                anchors.left: parent.left

                enabled: root.canStartMeasurement
                highlighted: true

                onClicked: {
                    if(errCalEntity.PAR_StartStop !== 1) {
                        errCalEntity.PAR_StartStop=1;
                    }
                }
            }
            Row {
                anchors.left: buttonStart.right
                anchors.right: buttonStop.left
                anchors.leftMargin: root.width * 0.1
                height: parent.height
                Item { // invisible button has zero width :(
                    height: parent.height
                    width: root.width * 0.09
                    ToolButton {
                        anchors.fill: parent
                        text: FA.fa_info_circle
                        highlighted: multiSwipe.currentIndex !== 0
                        Material.accent: Material.Amber
                        Material.foreground: multipleErrorView.jsonResults.countPass === multipleErrorView.jsonResults.values.length ?
                                                 Material.White : Material.Red
                        font.pointSize: pointSize * 1.5
                        background: Rectangle {
                            color: "transparent"
                        }
                        onClicked: {
                            multiSwipe.currentIndex = !multiSwipe.currentIndex
                        }
                    }
                }
                ZCheckBox {
                    text: Z.tr("continuous")
                    height: parent.height
                    width: root.width * 0.215

                    enabled: errCalEntity.PAR_StartStop !== 1
                    checked: errCalEntity.PAR_Continuous === 1
                    onCheckedChanged: {
                        if(checked !== errCalEntity.PAR_Continuous) {
                            errCalEntity.PAR_Continuous = (checked ? 1 : 0);
                        }
                    }
                }
            }
            Button {
                id: buttonStop
                text: Z.tr("Stop")
                font.pointSize: pointSize

                width: root.width/5
                height: parent.height
                anchors.right: parent.right

                enabled: root.canStartMeasurement === false

                onClicked: {
                    if(errCalEntity.PAR_StartStop !== 0) {
                        errCalEntity.PAR_StartStop=0;
                    }
                }
            }
        }
    }
}
