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
import "qrc:/qml/controls/settings" as SettingsControls
import "qrc:/data/staticdata/FontAwesome.js" as FA

Item {
  id: root
  //holds the state data
  property QtObject logicalParent;
  property real rowHeight: height/7

  readonly property QtObject p1m1: VeinEntity.getEntity("POWER1Module1")
  readonly property QtObject p1m2: VeinEntity.getEntity("POWER1Module2")
  readonly property QtObject p1m3: VeinEntity.getEntity("POWER1Module3")


  SettingsControls.SettingsView {
    anchors.fill: parent
    model: parameterModel
  }
  VisualItemModel {
    id: parameterModel
    /*Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width
      enabled: logicalParent.canStartMeasurement
      Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["Mode:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      VFControls.VFComboBox {
        id: cbMode

        arrayMode: true

        entity: logicalParent.energyComparison
        controlPropertyName: "PAR_Mode"
        model: ModuleIntrospection.sem1Introspection.ComponentInfo.PAR_Mode.Validation.Data

        anchors.right: parent.right
        height: parent.height
        width: parent.width*0.45

        currentIndex: 0
        contentRowWidth: width
        contentRowHeight: height*1.2
        contentFlow: GridView.FlowTopToBottom
        centerVertical: true
        centerVerticalOffset: height/2

        opacity: enabled ? 1.0 : 0.7
      }
    }*/
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width
      enabled: logicalParent.canStartMeasurement
      Label {

        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["Reference input:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      VFControls.VFComboBox {
        id: cbRefInput

        arrayMode: true

        entity: logicalParent.energyComparison
        controlPropertyName: "PAR_RefInput"
        model: ModuleIntrospection.sem1Introspection.ComponentInfo.PAR_RefInput.Validation.Data

        anchors.right: parent.right
        height: parent.height
        width: parent.width*0.45


        currentIndex: 0
        contentRowWidth: width
        contentRowHeight: height*1.2
        contentFlow: GridView.FlowTopToBottom
        centerVertical: true
        centerVerticalOffset: height/2

        opacity: enabled ? 1.0 : 0.7
      }
      VFControls.VFComboBox {
        arrayMode: true
        enabled: logicalParent.canStartMeasurement
        controlPropertyName: "PAR_MeasuringMode"
        fontSize: 16
        model: {
          switch(cbRefInput.currentText) {
          case "P":
            return ModuleIntrospection.p1m1Introspection.ComponentInfo.PAR_MeasuringMode.Validation.Data;
          case "Q":
            return ModuleIntrospection.p1m2Introspection.ComponentInfo.PAR_MeasuringMode.Validation.Data;
          case "S":
            return ModuleIntrospection.p1m3Introspection.ComponentInfo.PAR_MeasuringMode.Validation.Data;
          default:
            console.assert("Unhandled condition")
            return undefined;
          }
        }

        entity: {
          switch(cbRefInput.currentText) {
          case "P":
            return root.p1m1
          case "Q":
            return root.p1m2
          case "S":
            return root.p1m3
          default:
            console.assert("Unhandled condition")
            return undefined;
          }
        }

        contentRowHeight: height*1.2
        contentFlow: GridView.FlowTopToBottom
        centerVertical: true
        centerVerticalOffset: height/2
        anchors.right: cbRefInput.left
        anchors.rightMargin: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width/6
      }
    }
    Rectangle {
      //visible: cbMode.currentText === "energy" // this is localization independent
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight * visible //don't waste space if not visible
      width: root.width

      VFControls.VFLineEdit {
        anchors.fill: parent
        anchors.leftMargin: 4
        inputMethodHints: Qt.ImhPreferNumbers
        description.text: ZTR["Duration:"]
        description.width: width*0.55

        entity: logicalParent.energyComparison
        controlPropertyName: "PAR_MeasTime"
        textField.font.pixelSize: height/2

        enabled: logicalParent.canStartMeasurement
        validator: CCMP.ZDoubleValidator {
          bottom: ModuleIntrospection.sem1Introspection.ComponentInfo.PAR_MeasTime.Validation.Data[0];
          top: ModuleIntrospection.sem1Introspection.ComponentInfo.PAR_MeasTime.Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_MeasTime.Validation.Data[2]);
        }
      }
    }
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width
      enabled: logicalParent.canStartMeasurement

      /*Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["Device input:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      VFControls.VFComboBox {
        arrayMode: true

        entity: logicalParent.energyComparison
        controlPropertyName: "PAR_DutInput"
        model: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DutInput.Validation.Data
        fontSize: 16
        anchors.right: parent.right
        height: parent.height
        width: parent.width*0.45

        currentIndex: 0
        contentRowWidth: width
        contentRowHeight: height*1.2
        contentFlow: GridView.FlowTopToBottom
        centerVertical: true
        centerVerticalOffset: height/2

        opacity: enabled ? 1.0 : 0.7
      }*/
    }
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width

      /*VFControls.VFLineEdit {
        width: parent.width
        anchors.fill: parent
        anchors.leftMargin: 4
        inputMethodHints: Qt.ImhPreferNumbers
        description.text: ZTR["DUT constant:"]
        description.width: width*0.55

        entity: logicalParent.energyComparison
        controlPropertyName: "PAR_DutConstant"
        textField.font.pixelSize: height/2.1

        enabled: logicalParent.canStartMeasurement
        validator: CCMP.ZDoubleValidator {
          bottom: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DutConstant.Validation.Data[0];
          top: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DutConstant.Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DutConstant.Validation.Data[2]);
        }

        VFControls.VFComboBox {
          anchors.right: parent.right
          anchors.rightMargin: parent.width*0.45 + 1
          enabled: logicalParent.canStartMeasurement
          arrayMode: true
          fontSize: 16
          entity: logicalParent.energyComparison
          controlPropertyName: "PAR_DUTConstUnit"
          model: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DUTConstUnit.Validation.Data

          height: parent.height
          width: parent.width/6


          currentIndex: 0
          contentRowWidth: width
          contentRowHeight: height*1.2
          contentFlow: GridView.FlowTopToBottom
          centerVertical: true
          centerVerticalOffset: height/2

          opacity: enabled ? 1.0 : 0.7
        }
      }*/
    }
    Rectangle {
      visible: cbMode.currentText === "mrate" // this is localization independent
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight * visible //don't waste space if not visible
      width: root.width

      /*VFControls.VFLineEdit {
        anchors.fill: parent
        anchors.leftMargin: 4
        inputMethodHints: Qt.ImhPreferNumbers
        description.text: ZTR["MRate:"]
        description.width: width*0.55

        entity: logicalParent.energyComparison
        controlPropertyName: "PAR_MRate"
        textField.font.pixelSize: height/2

        enabled: logicalParent.canStartMeasurement

        validator: CCMP.ZDoubleValidator {
          bottom: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_MRate.Validation.Data[0];
          top: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_MRate.Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_MRate.Validation.Data[2]);
        }
      }*/
    }
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width

      Label {
        id: upperLimitDescription
        textFormat: Text.PlainText
        width: root.width * 0.55
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 4
        text: ZTR["Upper error margin:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      Item {
        id: upperLimitInputBox
        height: root.rowHeight
        anchors.left: upperLimitDescription.right
        anchors.leftMargin: -upperLimitDescription.anchors.leftMargin
        anchors.right: upperLimitAccept.left
        anchors.rightMargin: 16

        TextField {
          id: upperLimitInput
          anchors.fill: parent
          anchors.bottomMargin: -8
          anchors.leftMargin: height/4
          anchors.rightMargin: height/4
          implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, (background ? background.implicitHeight : 0))

          font.pixelSize: root.rowHeight/2.1
          text: GC.errorMarginUpperValue
          inputMethodHints: Qt.ImhPreferNumbers

          mouseSelectionMode: TextInput.SelectWords
          selectByMouse: true

          onAccepted: {
            focus = false
            GC.setErrorMargins(parseFloat(upperLimitInput.text), GC.errorMarginLowerValue);
          }

          color: Material.primaryTextColor
          horizontalAlignment: Text.AlignRight
          validator: CCMP.ZDoubleValidator {bottom: -100; top: 100; decimals: 3;}

          Rectangle {
            color: "red"
            opacity: 0.2
            visible: parent.acceptableInput === false
            anchors.fill: parent
          }
        }
      }
      Button {
        id: upperLimitAccept
        text: "\u2713" //unicode checkmark
        font.pixelSize: height/2

        implicitHeight: 0
        height: root.rowHeight
        implicitWidth: height
        highlighted: true

        anchors.right: upperLimitReset.left
        anchors.rightMargin: 8

        onClicked: {
          GC.setErrorMargins(parseFloat(upperLimitInput.text), GC.errorMarginLowerValue);
        }
        enabled: parseFloat(upperLimitInput.text) !== GC.errorMarginUpperValue && upperLimitInput.acceptableInput
      }
      Button {
        id: upperLimitReset
        text: "\u00D7" //unicode x mark
        font.pixelSize: height/2

        implicitHeight: 0
        height: root.rowHeight
        implicitWidth: height
        anchors.right: parent.right
        anchors.rightMargin: 8

        onClicked: {
          upperLimitInput.text = GC.errorMarginUpperValue
        }
        enabled:parseFloat(upperLimitInput.text) !== GC.errorMarginUpperValue
      }
    }
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width

      Label {
        id: lowerLimitDescription
        textFormat: Text.PlainText
        width: root.width * 0.55
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 4
        text: ZTR["Lower error margin:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      Item {
        id: lowerLimitInputBox
        height: root.rowHeight
        anchors.left: lowerLimitDescription.right
        anchors.leftMargin: -upperLimitDescription.anchors.leftMargin
        anchors.right: lowerLimitAccept.left
        anchors.rightMargin: 16

        TextField {
          id: lowerLimitInput
          anchors.fill: parent
          anchors.bottomMargin: -8
          anchors.leftMargin: height/4
          anchors.rightMargin: height/4
          implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, (background ? background.implicitHeight : 0))

          font.pixelSize: root.rowHeight/2
          text: GC.errorMarginLowerValue
          inputMethodHints: Qt.ImhPreferNumbers

          mouseSelectionMode: TextInput.SelectWords
          selectByMouse: true

          onAccepted: {
            focus = false
            GC.setErrorMargins(GC.errorMarginUpperValue, parseFloat(lowerLimitInput.text));
          }

          color: Material.primaryTextColor
          horizontalAlignment: Text.AlignRight
          validator: CCMP.ZDoubleValidator {bottom: -100; top: 100; decimals: 3;}

          Rectangle {
            color: "red"
            opacity: 0.2
            visible: parent.acceptableInput === false
            anchors.fill: parent
          }
        }
      }
      Button {
        id: lowerLimitAccept
        text: "\u2713" //unicode checkmark
        font.pixelSize: height/2

        implicitHeight: 0
        height: root.rowHeight
        implicitWidth: height
        highlighted: true

        anchors.right: lowerLimitReset.left
        anchors.rightMargin: 8

        onClicked: {
          GC.setErrorMargins(GC.errorMarginUpperValue, parseFloat(lowerLimitInput.text));
        }
        enabled: parseFloat(lowerLimitInput.text) !== GC.errorMarginLowerValue && lowerLimitInput.acceptableInput
      }
      Button {
        id: lowerLimitReset
        text: "\u00D7" //unicode x mark
        font.pixelSize: height/2

        implicitHeight: 0
        height: root.rowHeight
        implicitWidth: height
        anchors.right: parent.right
        anchors.rightMargin: 8

        onClicked: {
          lowerLimitInput.text = GC.errorMarginLowerValue
        }
        enabled: parseFloat(lowerLimitInput.text) !== GC.errorMarginLowerValue
      }
    }
  }
}
