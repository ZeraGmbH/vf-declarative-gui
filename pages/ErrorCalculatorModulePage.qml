import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import "qrc:/data/staticdata/FontAwesome.js" as FA
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import "qrc:/pages/error_calculator_module" as D

CCMP.ModulePage {
  id: root
  clip: true

  readonly property QtObject errorCalculator: VeinEntity.getEntity("SEC1Module1")
  readonly property QtObject p1m1: VeinEntity.getEntity("POWER1Module1")
  readonly property QtObject p1m2: VeinEntity.getEntity("POWER1Module2")
  readonly property QtObject p1m3: VeinEntity.getEntity("POWER1Module3")
  property int status: errorCalculator.ACT_Status
  readonly property QtObject statusHolder: statuses
  property bool canStartMeasurement: status === statuses.idle || status === statuses.ready || status === statuses.aborted

  QtObject {
    id: statuses
    //none of these state bits can be active in parallel

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

  function getStatusText(value) {
    var statusText
    switch(value)
    {
    case statuses.idle:
      statusText=ZTR["Idle"]
      break;
    case statuses.armed:
      statusText=ZTR["Armed"]
      break;
    case statuses.started:
      statusText=ZTR["Started"]
      break;
    case statuses.ready:
      statusText=ZTR["Ready"]
      break;
    case statuses.aborted:
      statusText=ZTR["Aborted"]
      break;
    }
    return statusText
  }


  Column {
    D.MeasurementView {
      logicalParent: root
      height: root.height*0.2
      width: root.width
    }
    Row {
      height: root.height*0.7
      width: root.width

      D.ParameterView {
        logicalParent: root
        width: parent.width*0.7
        height: parent.height
      }
      D.ErrorMarginView {
        logicalParent: root
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
          if(errorCalculator.PAR_STARTSTOP !== 1)
          {
            errorCalculator.PAR_STARTSTOP=1
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
          if(errorCalculator.PAR_STARTSTOP !== 0)
          {
            errorCalculator.PAR_STARTSTOP=0
          }
        }
      }
    }
  }
}
