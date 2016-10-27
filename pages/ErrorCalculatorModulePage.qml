import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/ccmp/common/" as CCMP
import "qrc:/vf-controls/common" as VFControls
import Com5003Translation  1.0

import ModuleIntrospection 1.0

CCMP.ModulePage {
  id: root
  clip: true

  readonly property QtObject errorCalculator: VeinEntity.getEntity("SEC1Module1")
  property int status: errorCalculator.ACT_Status
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
    anchors.fill: parent

    Item {
      height: parent.height*0.18
      width: height*3

      anchors.horizontalCenter: parent.horizontalCenter


      Item {
        visible: root.status === statuses.armed
        anchors.fill: parent
        clip: true
        Image {
          source: "qrc:/data/staticdata/resources/Armed.svg"
          sourceSize.width: parent.width
          fillMode: Image.TileHorizontally
          height: parent.height
          width: parent.width
        }
      }

      Item {
        id: animatedReady
        visible: root.status === statuses.started
        anchors.fill: parent
        clip: true
        Image {
          source: "qrc:/data/staticdata/resources/Ready.svg"
          sourceSize.width: parent.width
          fillMode: Image.TileHorizontally
          height: parent.height
          width: parent.width*2

          SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation {
              from: 0
              to: -animatedReady.width
              duration: 1050
            }
            NumberAnimation {
              to: 0
              duration: 0
            }
          }
        }
      }

      Text {
        visible: root.status === statuses.ready
        text: ZTR["Result:"]
        color: Material.primaryTextColor
        textFormat: Text.PlainText
        font.pixelSize: 20
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        visible: root.status === statuses.ready
        id: actResultLabel
        width: parent.width
        color: Material.primaryTextColor
        textFormat: Text.PlainText
        font.pixelSize: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height/10
        horizontalAlignment: Text.AlignHCenter
        text: errorCalculator.ACT_Result+"%"
      }
    }
    Item { //spacer
      height: 8
      width: parent.width
    }
    ProgressBar {
      id: actProgressBar
      from: 0
      to: 100
      width: parent.width
      height: parent.height/20
      value: errorCalculator.ACT_Progress
      indeterminate: root.status === statuses.armed


      Text {
        id: actProgressText
        color: Material.primaryTextColor
        textFormat: Text.PlainText
        anchors.bottom: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: parseInt(actProgressBar.value)+"%"
      }
    }

    Item { //spacer
      height: parent.height/10
      width: parent.width
    }

    Item {
      anchors.left: parent.left
      anchors.right: parent.right
      height: root.height*0.4

      Column {
        anchors.fill: parent
        anchors.topMargin: 16


        Rectangle {
          color: "transparent"
          border.color: Material.dividerColor
          height: parent.height/5
          width: parent.width
          Text {
            color: Material.primaryTextColor
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: ZTR["Mode:"]
            font.pixelSize: Math.max(height/2, 20)
          }
          VFControls.VFComboBox {
            id: cbMode

            enabled: root.canStartMeasurement
            arrayMode: true

            entity: root.errorCalculator
            controlPropertyName: "PAR_Mode"
            model: ModuleIntrospection.secIntrospection.ComponentInfo.PAR_Mode.Validation.Data

            anchors.right: parent.right
            height: parent.height
            width:parent.width/2

            currentIndex: 0
            contentRowWidth: width
            contentRowHeight: height
            contentFlow: GridView.FlowTopToBottom
            //centerVertical: true

            opacity: enabled ? 1.0 : 0.7
          }
        }
        Rectangle {
          color: "transparent"
          border.color: Material.dividerColor
          height: parent.height/5
          width: parent.width
          Text {
            color: Material.primaryTextColor
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: ZTR["Reference input:"]
            font.pixelSize: Math.max(height/2, 20)
          }
          VFControls.VFComboBox {
            id: cbRefInput

            enabled: root.canStartMeasurement
            arrayMode: true

            entity: root.errorCalculator
            controlPropertyName: "PAR_RefInput"
            model: ModuleIntrospection.secIntrospection.ComponentInfo.PAR_RefInput.Validation.Data

            anchors.right: parent.right
            height: parent.height
            width:parent.width/2


            currentIndex: 0
            contentRowWidth: width
            contentRowHeight: height
            contentFlow: GridView.FlowTopToBottom
            //centerVertical: false

            opacity: enabled ? 1.0 : 0.7
          }
        }
        Rectangle {
          color: "transparent"
          border.color: Material.dividerColor
          height: parent.height/5
          width: parent.width
          Text {
            color: Material.primaryTextColor
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: ZTR["Device input:"]
            font.pixelSize: Math.max(height/2, 20)
          }
          VFControls.VFComboBox {
            id: cbDutInput

            enabled: root.canStartMeasurement
            arrayMode: true

            entity: root.errorCalculator
            controlPropertyName: "PAR_DutInput"
            model: ModuleIntrospection.secIntrospection.ComponentInfo.PAR_DutInput.Validation.Data

            anchors.right: parent.right
            height: parent.height
            width:parent.width/2

            currentIndex: 0
            contentRowWidth: width
            contentRowHeight: height
            contentFlow: GridView.FlowTopToBottom
            //centerVertical: true

            opacity: enabled ? 1.0 : 0.7
          }
        }
        Rectangle {
          color: "transparent"
          border.color: Material.dividerColor
          height: parent.height/5
          width: parent.width
          Text {
            color: Material.primaryTextColor
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: ZTR["DUT constant:"]
            font.pixelSize: Math.max(height/2, 20)
          }
          VFControls.VFLineEdit {
            id: deviceConstantField
            width: parent.width/2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            inputMethodHints: Qt.ImhPreferNumbers

            entity: root.errorCalculator
            controlPropertyName: "PAR_DutConstant"

            enabled: root.canStartMeasurement
            validator: DoubleValidator { bottom: 1.0; top: 1e+20; decimals: 5;}
          }
        }
        Rectangle {
          visible: cbMode.currentText === "energy" // this is localization independent
          color: "transparent"
          border.color: Material.dividerColor
          height: parent.height/5
          width: parent.width
          Text {
            color: Material.primaryTextColor
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: ZTR["Energy:"]
            font.pixelSize: Math.max(height/2, 20)
          }
          VFControls.VFLineEdit {
            id: energyValueField
            width: parent.width/2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            inputMethodHints: Qt.ImhPreferNumbers

            entity: root.errorCalculator
            controlPropertyName: "PAR_Energy"

            enabled: root.canStartMeasurement
            validator: DoubleValidator { bottom: 0; top: 10e+7; decimals: 5; }
          }
        }
        Rectangle {
          visible: cbMode.currentText === "mrate" // this is localization independent
          color: "transparent"
          border.color: Material.dividerColor
          height: parent.height/5
          width: parent.width
          Text {
            color: Material.primaryTextColor
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: ZTR["MRate:"]
            font.pixelSize: Math.max(height/2, 20)
          }
          VFControls.VFLineEdit {
            id: mrateValueField
            width: parent.width/2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            inputMethodHints: Qt.ImhPreferNumbers

            entity: root.errorCalculator
            controlPropertyName: "PAR_MRate"

            enabled: root.canStartMeasurement
            validator: DoubleValidator {bottom: 0; top: Math.floor(Math.pow(2,32)-1); decimals: 0;} //IntValidator is only for signed integers
          }
        }
      }
    }
    Item { //spacer
      height: parent.height*0.1
      width: parent.width
    }
    Item {
      height: parent.height/10
      anchors.left: parent.left
      anchors.right: parent.right
      Button {
        id: startButton
        text: ZTR["Start"]
        font.pixelSize: 20
        width: parent.width/5

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
        id: stopButton
        text: ZTR["Stop"]
        font.pixelSize: 20
        width: parent.width/5

        enabled: root.canStartMeasurement === false

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.leftMargin: width/2

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
