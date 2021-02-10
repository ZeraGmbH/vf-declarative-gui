import QtQuick 2.5
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/controls/error_comparison_common" as ErrorCommon
import "qrc:/qml/controls/error_comparison_params" as ParamViews

CCMP.ModulePage {
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
    readonly property real pointSize: root.height > 0 ? root.height / 31 : 10
    readonly property bool canSwipeMultiple: multiSwipe.currentIndex !== 0 || errCalEntity.ACT_MulCount > 1

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
    }

    Column {
        ErrorCommon.MeasurementView {
            logicalParent: root
            height: root.height*0.2
            width: root.width
            measurementResult: errCalEntity.ACT_Result
            progress: errCalEntity.ACT_Progress
            progressTo: 100
            readonly property real currEnergy: errCalEntity.PAR_Continuous === 1 ? errCalEntity.ACT_EnergyFinal : errCalEntity.ACT_Energy
            readonly property var scaledEnergyArr: GC.doAutoScale(currEnergy, moduleIntrospection.ComponentInfo.ACT_Energy.Unit)
            actualValue: GC.formatNumber(scaledEnergyArr[0]) + " " + scaledEnergyArr[1]
        }
        Row {
            height: root.height*0.7
            width: root.width

            SwipeView {
                id: multiSwipe
                width: parent.width*0.7
                height: parent.height
                interactive: false
                orientation: Qt.Vertical
                clip: true
                ParamViews.ParamViewComparison {
                    id: paramView
                    logicalParent: root
                    validatorRefInput: moduleIntrospection.ComponentInfo.PAR_RefInput.Validation
                    validatorMode: moduleIntrospection.ComponentInfo.PAR_Mode.Validation
                    validatorDutInput: moduleIntrospection.ComponentInfo.PAR_DutInput.Validation
                    validatorDutConstant: moduleIntrospection.ComponentInfo.PAR_DutConstant.Validation
                    validatorDutConstUnit: moduleIntrospection.ComponentInfo.PAR_DUTConstUnit.Validation
                    validatorUpperLimit: moduleIntrospection.ComponentInfo.PAR_Uplimit.Validation
                    validatorLowerLimit: moduleIntrospection.ComponentInfo.PAR_Lolimit.Validation
                }
                ListView {

                }
            }

            ErrorCommon.ErrorMarginView {
                result: root.errCalEntity.ACT_Result
                width: parent.width*0.3
                height: parent.height
                maxValue: errCalEntity.PAR_Uplimit
                minValue: errCalEntity.PAR_Lolimit
                rating: errCalEntity.ACT_Rating
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
                    width: parent.height
                    ToolButton {
                        anchors.fill: parent
                        text: FA.fa_info_circle
                        highlighted: multiSwipe.currentIndex !== 0
                        Material.accent: Material.Amber
                        font.pointSize: pointSize * 1.5
                        visible: canSwipeMultiple
                        enabled: canSwipeMultiple
                        background: Rectangle {
                            color: "transparent"
                        }
                        onClicked: {
                            multiSwipe.currentIndex = !multiSwipe.currentIndex
                        }
                    }
                }
                Item { width: root.width * 0.015; height: parent.height  }
                CheckBox {
                    text: Z.tr("continuous")
                    font.pointSize: pointSize
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
