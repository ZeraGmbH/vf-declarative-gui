import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/vf-controls" as VFControls
import ZeraFa 1.0
import "qrc:/qml/controls/error_comparison_common" as ErrorCommon
import "qrc:/qml/controls/error_comparison_params" as ParamViews

CCMP.ModulePage {
  id: root
  clip: true

  property QtObject errCalEntity
  property var moduleIntrospection
  property alias validatorMrate: paramView.validatorMrate
  property alias validatorEnergy: paramView.validatorEnergy
  property int status: errCalEntity.ACT_Status
  readonly property alias statusHolder: stateEnum
  readonly property bool canStartMeasurement: errCalEntity.PAR_StartStop !== 1

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

      ParamViews.ParamViewComparison {
        id: paramView
        logicalParent: root
        validatorRefInput: moduleIntrospection.ComponentInfo.PAR_RefInput.Validation
        validatorMode: moduleIntrospection.ComponentInfo.PAR_Mode.Validation
        validatorDutInput: moduleIntrospection.ComponentInfo.PAR_DutInput.Validation
        validatorDutConstant: moduleIntrospection.ComponentInfo.PAR_DutConstant.Validation
        validatorDutConstUnit: moduleIntrospection.ComponentInfo.PAR_DUTConstUnit.Validation

        width: parent.width*0.7
        height: parent.height
      }
      ErrorCommon.ErrorMarginView {
        result: root.errCalEntity.ACT_Result
        width: parent.width*0.3
        height: parent.height
      }
    }
    Item {
      height: root.height*0.1
      width: root.width
      Button {
        text: ZTR["Start"]
        font.pixelSize: 20
        width: root.width/5

        enabled: root.canStartMeasurement
        highlighted: true

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onClicked: {
          if(errCalEntity.PAR_StartStop !== 1)
          {
            errCalEntity.PAR_StartStop=1;
          }
        }
      }
      CheckBox {
        text: ZTR["Continuous measurement"];
        anchors.centerIn: parent
        font.pixelSize: 20
        enabled: errCalEntity.PAR_StartStop !== 1;
        checked: errCalEntity.PAR_Continuous === 1;
        onCheckedChanged: {
          if(checked !== errCalEntity.PAR_Continuous)
          {
            errCalEntity.PAR_Continuous = (checked ? 1 : 0);
          }
        }
      }

      Button {
        text: ZTR["Stop"]
        font.pixelSize: 20
        width: root.width/5

        enabled: root.canStartMeasurement === false

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        onClicked: {
          if(errCalEntity.PAR_StartStop !== 0)
          {
            errCalEntity.PAR_StartStop=0;
          }
        }
      }
    }
  }
}
