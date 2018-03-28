import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import "qrc:/components/common"

import ModuleIntrospection 1.0

Item {
  id: root
  property SpinBoxIntrospection introspection;
  property alias text: descriptionLabel.text
  property real intermediateValue;
  onIntermediateValueChanged: {
    valueSpinBox.value = intermediateValue * 100
  }

  property real outValue;


  Rectangle {
    anchors.fill: parent
    color: valueSpinBox.realValue !== intermediateValue ? "#33000044" : "transparent"
    radius: 4

    RowLayout {
      anchors.fill: parent
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
          Component.onCompleted: valueSpinBox.contentItem.selectByMouse=true
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

        validator: ZDoubleValidator {
          bottom: introspection.lowerBound
          top: introspection.upperBound
          decimals: GC.ceilLog10Of1DividedByX(introspection.stepSize);
        }

        textFromValue: function(value, locale) {
          return Number(value / 100).toLocaleString(locale, 'f', valueSpinBox.decimals)
        }

        valueFromText: function(text, locale) {
          return Number.fromLocaleString(locale, text) * 100
        }
      }


      Label {
        id: unitLabel
        Layout.preferredWidth: 40
        Layout.minimumWidth: contentWidth
        height: parent.height
        text: introspection.unit
        font.pixelSize: Math.max(height/3, 20)
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
      }

      Item {
        width: 2
      }

      Button {
        id: acceptButton
        text: "\u2713" //unicode checkmark
        font.pixelSize: Math.max(height/2, 16)
        implicitHeight: root.height*0.8
        implicitWidth: implicitHeight
        highlighted: true
        //only enable the button if the value is different from the remote
        enabled: intermediateValue !== valueSpinBox.realValue

        onClicked: {
          focus=true
          outValue = valueSpinBox.realValue
        }
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
    }
  }
}
