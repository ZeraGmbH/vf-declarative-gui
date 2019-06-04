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

  readonly property real col1Width: 7/20
  readonly property real col2Width: 9/20
  readonly property real col3Width: 4/20

  SettingsControls.SettingsView {
    anchors.fill: parent
    model: parameterModel
  }
  VisualItemModel {
    id: parameterModel
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width
      enabled: logicalParent.canStartMeasurement
      Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: GC.standardTextHorizMargin
        width: parent.width*col1Width
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["Mode:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      VFControls.VFComboBox {
        id: cbMode

        arrayMode: true

        entity: logicalParent.errorCalculator
        controlPropertyName: "PAR_Mode"
        model: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_Mode.Validation.Data

        x: parent.width*col1Width
        width: parent.width*col2Width - GC.standardMarginWithMin

        anchors.top: parent.top
        anchors.topMargin: GC.standardMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: GC.standardMargin

        contentRowHeight: height*GC.standardComboContentScale
        contentFlow: GridView.FlowTopToBottom
      }
    }
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width
      enabled: logicalParent.canStartMeasurement
      Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: GC.standardTextHorizMargin
        width: parent.width*col1Width
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["Reference input:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      VFControls.VFComboBox {
        id: cbRefInput

        arrayMode: true

        entity: logicalParent.errorCalculator
        controlPropertyName: "PAR_RefInput"
        model: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_RefInput.Validation.Data

        x: parent.width*col1Width
        width: parent.width*col2Width - GC.standardMarginWithMin

        anchors.top: parent.top
        anchors.topMargin: GC.standardMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: GC.standardMargin

        contentRowHeight: height*GC.standardComboContentScale
        contentFlow: GridView.FlowTopToBottom
      }
      VFControls.VFComboBox {
        arrayMode: true
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

        anchors.right: parent.right
        width: parent.width*col3Width-GC.standardMargin

        anchors.top: parent.top
        anchors.topMargin: GC.standardMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: GC.standardMargin

        contentRowHeight: height*GC.standardComboContentScale
        contentFlow: GridView.FlowTopToBottom
      }
    }
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width
      enabled: logicalParent.canStartMeasurement

      Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: GC.standardTextHorizMargin
        width: parent.width*col1Width
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["Device input:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      VFControls.VFComboBox {
        arrayMode: true

        entity: logicalParent.errorCalculator
        controlPropertyName: "PAR_DutInput"
        model: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DutInput.Validation.Data

        x: parent.width*col1Width
        width: parent.width*col2Width-GC.standardMarginWithMin

        anchors.top: parent.top
        anchors.topMargin: GC.standardMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: GC.standardMargin

        contentRowHeight: height*GC.standardComboContentScale
        contentFlow: GridView.FlowTopToBottom
      }
    }
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width
      enabled: logicalParent.canStartMeasurement

      Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: GC.standardTextHorizMargin
        width: parent.width*col1Width
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["DUT constant:"]
        font.pixelSize: Math.max(height/2, 20)
      }

      VFControls.VFLineEdit {
        inputMethodHints: Qt.ImhPreferNumbers

        entity: logicalParent.errorCalculator
        controlPropertyName: "PAR_DutConstant"

        x: parent.width*col1Width
        width: parent.width*col2Width-GC.standardMarginWithMin

        anchors.top: parent.top
        anchors.bottom: parent.bottom

        validator: CCMP.ZDoubleValidator {
          bottom: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DutConstant.Validation.Data[0];
          top: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DutConstant.Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DutConstant.Validation.Data[2]);
        }
      }

      VFControls.VFComboBox {
        arrayMode: true

        entity: logicalParent.errorCalculator
        controlPropertyName: "PAR_DUTConstUnit"
        model: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_DUTConstUnit.Validation.Data

        anchors.top: parent.top
        anchors.topMargin: GC.standardMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: GC.standardMargin
        anchors.right: parent.right
        width: parent.width*col3Width-GC.standardMargin

        contentRowHeight: height*GC.standardComboContentScale
        contentFlow: GridView.FlowTopToBottom
      }
    }
    Rectangle {
      enabled: logicalParent.canStartMeasurement
      visible: cbMode.currentText === "energy" // this is localization independent
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight * visible //don't waste space if not visible
      width: root.width

      Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: GC.standardTextHorizMargin
        width: parent.width*col1Width
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["Energy:"]
        font.pixelSize: Math.max(height/2, 20)
      }

      VFControls.VFLineEdit {
        inputMethodHints: Qt.ImhPreferNumbers

        x: parent.width*col1Width
        width: parent.width*col2Width-GC.standardMarginWithMin

        anchors.top: parent.top
        anchors.bottom: parent.bottom

        entity: logicalParent.errorCalculator
        controlPropertyName: "PAR_Energy"

        validator: CCMP.ZDoubleValidator {
          bottom: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_Energy.Validation.Data[0];
          top: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_Energy.Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_Energy.Validation.Data[2]);
        }
      }
      // TODO unit?
    }
    Rectangle {
      visible: cbMode.currentText === "mrate" // this is localization independent
      enabled: logicalParent.canStartMeasurement
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight * visible //don't waste space if not visible
      width: root.width

      Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: GC.standardTextHorizMargin
        width: parent.width*col1Width
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["MRate:"]
        font.pixelSize: Math.max(height/2, 20)
      }

      VFControls.VFLineEdit {
        inputMethodHints: Qt.ImhPreferNumbers

        x: parent.width*col1Width
        width: parent.width*col2Width-GC.standardMarginWithMin

        anchors.top: parent.top
        anchors.bottom: parent.bottom

        entity: logicalParent.errorCalculator
        controlPropertyName: "PAR_MRate"

        validator: CCMP.ZDoubleValidator {
          bottom: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_MRate.Validation.Data[0];
          top: ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_MRate.Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(ModuleIntrospection.sec1Introspection.ComponentInfo.PAR_MRate.Validation.Data[2]);
        }
      }
    }
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width

      Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: GC.standardTextHorizMargin
        width: parent.width*col1Width
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["Upper error margin:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      VFControls.VFLineEdit {
        id: upperLimitInput

        x: parent.width*col1Width
        width: parent.width*col2Width-GC.standardMarginWithMin

        anchors.top: parent.top
        anchors.bottom: parent.bottom

        inputMethodHints: Qt.ImhPreferNumbers
        text: GC.errorMarginUpperValue

        validator: CCMP.ZDoubleValidator {bottom: -100; top: 100; decimals: 3;}
        function confirmInput() {
          upperLimitInput.text = upperLimitInput.textField.text
          GC.setErrorMargins(parseFloat(upperLimitInput.text), GC.errorMarginLowerValue);
        }
      }
      Label {
        textFormat: Text.PlainText
        anchors.right: parent.right
        width: parent.width*col3Width - GC.standardTextHorizMargin
        anchors.verticalCenter: parent.verticalCenter
        text: "%"
        font.pixelSize: Math.max(height/2, 20)
      }
    }
    Rectangle {
      color: "transparent"
      border.color: Material.dividerColor
      height: root.rowHeight
      width: root.width

      Label {
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: GC.standardTextHorizMargin
        width: parent.width*col1Width
        anchors.verticalCenter: parent.verticalCenter
        text: ZTR["Lower error margin:"]
        font.pixelSize: Math.max(height/2, 20)
      }
      VFControls.VFLineEdit {
        id: lowerLimitInput
        x: parent.width*col1Width
        width: parent.width*col2Width-GC.standardMarginWithMin

        anchors.top: parent.top
        anchors.bottom: parent.bottom

        inputMethodHints: Qt.ImhPreferNumbers
        text: GC.errorMarginLowerValue

        validator: CCMP.ZDoubleValidator {bottom: -100; top: 100; decimals: 3;}
        function confirmInput() {
          lowerLimitInput.text = lowerLimitInput.textField.text
          GC.setErrorMargins(GC.errorMarginUpperValue, parseFloat(lowerLimitInput.text));
        }
      }
      Label {
        textFormat: Text.PlainText
        anchors.right: parent.right
        width: parent.width*col3Width - GC.standardTextHorizMargin
        anchors.verticalCenter: parent.verticalCenter
        text: "%"
        font.pixelSize: Math.max(height/2, 20)
      }
    }
  }
}
