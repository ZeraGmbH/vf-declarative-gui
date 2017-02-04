import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.0
import "qrc:/components/common"

import ModuleIntrospection 1.0

Item {
  id: root
  property IntervalIntrospection introspection;

  property alias text: descriptionLabel.text
  property real intermediateValue;
  onIntermediateValueChanged: {
    valueSpinBox.value = intermediateValue * 100
  }

  property real outValue;


  Rectangle {
    anchors.fill: parent
    color: valueSpinBox.realValue !== intermediateValue ? "#33000044" : "transparent"
    anchors.leftMargin: 8
    anchors.rightMargin: 16
    radius: 4

    RowLayout {
      anchors.fill: parent

      Item {
        width: 8
      }

      Label {
        id: descriptionLabel
        font.pixelSize: Math.max(height/2, 20)
      }
      Item {
        Layout.fillHeight: true
        Layout.fillWidth: true
      }

      SpinBox {
        id: valueSpinBox
        from: validator.bottom * 100
        //value: root.intermediateValue * 100
        to: validator.top * 100
        stepSize: introspection.stepSize * 100
        width: 200
        editable: true

        //if text is entered via keyboard and the user presses enter with valid input -> accept the input instead of requiring one more click to the accept button
        property bool textAcceptWorkaround: false

        Connections {
          target: valueSpinBox.contentItem //this is the TextInput
          onAccepted: {
            valueSpinBox.textAcceptWorkaround = true
          }
        }

        property int decimals: introspection.stepSize<1 ? 1 : 0
        property real realValue: value / 100

        onRealValueChanged: {
          if(textAcceptWorkaround === true)
          {
            focus=false
            outValue = valueSpinBox.realValue
            textAcceptWorkaround = false;
          }
        }

        Component.onCompleted: {
          value = root.intermediateValue * 100
        }

        validator: DoubleValidator {
          bottom: introspection.lowerBound
          top: introspection.upperBound
          decimals: (String(introspection.stepSize).split('.')[1] || []).length;
        }

        textFromValue: function(value, locale) {
          return Number(value / 100).toLocaleString(locale, 'f', valueSpinBox.decimals)
        }

        valueFromText: function(text, locale) {
          return Number.fromLocaleString(locale, text) * 100
        }
      }

      Item {
        width: 8
      }

      Label {
        text: introspection.unit
        font.pixelSize: Math.max(height/2, 20)
      }
      Item {
        width: 24
      }

      Button {
        id: acceptButton
        text: "\u2713" //unicode checkmark
        font.pixelSize: Math.max(height/2, 16)
        implicitHeight: root.height*0.8
        implicitWidth: implicitHeight

        //only enable the button if the value is different from the remote
        enabled: intermediateValue !== valueSpinBox.realValue

        onClicked: {
          focus=true
          outValue = valueSpinBox.realValue
        }
      }
      Item {
        width: 8
      }
      Button {
        id: resetButton
        text: "\u00D7" //unicode x mark
        font.pixelSize: Math.max(height/2, 16)
        implicitHeight: root.height*0.8
        implicitWidth: implicitHeight

        //only enable the button if the value is different from the remote
        enabled: intermediateValue !== valueSpinBox.realValue

        onClicked: {
          focus = true
          valueSpinBox.value = intermediateValue * 100
        }
      }
      Item {
        width: 8
      }
    }
  }
}
