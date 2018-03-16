import QtQuick 2.0

ListModel {
  readonly property string firstElement: "qrc:/pages/ActualValuesPage.qml"

  ListElement {
    name: "Actual values"
    icon: "qrc:/data/staticdata/resources/act_values.png"
    elementValue: "qrc:/pages/ActualValuesPage.qml"
  }
  ListElement {
    name: "Oscilloscope plot"
    icon: "qrc:/data/staticdata/resources/osci.png"
    elementValue: "qrc:/pages/OsciModulePage.qml"
  }
  ListElement {
    name: "Harmonics"
    icon: "qrc:/data/staticdata/resources/harmonics.png"
    elementValue: "qrc:/pages/FftModulePage.qml"
  }
  ListElement {
    name: "Power values"
    icon: "qrc:/data/staticdata/resources/power.png"
    elementValue: "qrc:/pages/PowerModulePage.qml"
  }
  ListElement {
    name: "Harmonic power values"
    icon: "qrc:/data/staticdata/resources/hpower.png"
    elementValue: "qrc:/pages/HarmonicPowerModulePage.qml"
  }
  ListElement {
    name: "Burden values"
    icon: "qrc:/data/staticdata/resources/appicon.png"
    elementValue: "qrc:/pages/BurdenModulePage.qml"
  }
  ListElement {
    name: "Transformer values"
    icon: "qrc:/data/staticdata/resources/appicon.png"
    elementValue: "qrc:/pages/TransformerModulePage.qml"
  }
  ListElement {
    name: "Error calculator"
    icon: "qrc:/data/staticdata/resources/error_calc.png"
    elementValue: "qrc:/pages/ErrorCalculatorModulePage.qml"
  }
  ListElement {
    name: "Vector diagram"
    icon: "qrc:/data/staticdata/resources/dft_values.png"
    elementValue: "qrc:/pages/DFTModulePage.qml"
  }
  ListElement {
    name: "4PV"
    icon: "qrc:/data/staticdata/resources/appicon.png"
    elementValue: "qrc:/pages/RMS4PhasePage.qml"
  }
}
