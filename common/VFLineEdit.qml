import QtQuick 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import GlobalConfig 1.0

Item {
  id: root
  property var validator
  property string text: ""
  property alias textField: tInput
  property alias description: descriptionText
  property alias unit: unitLabel
  property alias inputMethodHints: tInput.inputMethodHints;
  property alias placeholderText: tInput.placeholderText;
  property QtObject entity
  property string controlPropertyName
  readonly property bool acceptableInput: tInput.acceptableInput && (!validator || (validator.top>=parseFloat(tInput.text) && validator.bottom<=parseFloat(tInput.text)))
  readonly property bool m_alteredValue: (Math.abs(parseFloat(tInput.text) - entity[controlPropertyName]) >=  Math.pow(10, -root.validator.decimals))
  onTextChanged: tInput.text = text
  onValidatorChanged: tInput.validator = validator


  function confirmInput() {
    if(tInput.text !== root.text && root.acceptableInput)
    {
      if(root.validator)
      {
        root.entity[root.controlPropertyName] = parseFloat(tInput.text)
      }
      else
      {
        root.entity[root.controlPropertyName] = tInput.text
      }
    }
  }

  Item {
    property var intermediateValue: root.entity[root.controlPropertyName]
    onIntermediateValueChanged: {
      if(intermediateValue !== undefined)
      {
        tInput.text = intermediateValue
        root.text = intermediateValue
      }
    }
  }

  Label {
    id: descriptionText
    height: root.rowHeight
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: Math.max(height/2, 20)
  }
  Item {
    anchors.left: descriptionText.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: unitLabel.left
    anchors.rightMargin: 8

    //radius: height/4
    //border.color: Material.frameColor
    //border.width: 1.5
    //color: root.m_alteredValue ? (root.acceptableInput ? Material.primaryColor : Material.backgroundDimColor) : "transparent"

    TextField {
      id: tInput
      anchors.fill: parent
      anchors.bottomMargin: -8
      anchors.leftMargin: height/4
      anchors.rightMargin: height/4
      horizontalAlignment: Text.AlignRight
      implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                               background ? background.implicitHeight : 0)

      mouseSelectionMode: TextInput.SelectWords
      selectByMouse: true
      onAccepted: {
        focus = false
        confirmInput()
      }

      font.pixelSize: height/2
      color: Material.primaryTextColor

      Rectangle {
        color: "red"
        opacity: 0.2
        visible: root.acceptableInput === false
        anchors.fill: parent
      }
    }
  }
  Label {
    id: unitLabel
    height: parent.height
    font.pixelSize: height/2
    anchors.right: acceptButton.left
    anchors.rightMargin: 8
    verticalAlignment: Text.AlignVCenter
  }

  Button {
    id: acceptButton
    text: "\u2713" //unicode checkmark
    font.pixelSize: height/2

    implicitHeight: 0
    width: height
    //only show the button if the value is different from the remote
    //visible: root.m_alteredValue
    highlighted: true

    anchors.right: resetButton.left
    anchors.rightMargin: 8
    anchors.bottom: parent.bottom
    anchors.top: parent.top

    onClicked: {
      focus = true;
      confirmInput();
    }
    enabled: root.m_alteredValue && root.acceptableInput
  }
  Button {
    id: resetButton
    text: "\u00D7" //unicode x mark
    font.pixelSize: height/2

    implicitHeight: 0
    width: height
    //only show the button if the value is different from the remote
    //visible: root.m_alteredValue

    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.bottom: parent.bottom
    anchors.top: parent.top
    onClicked: {
      focus = true
      tInput.text = root.entity[root.controlPropertyName]
    }
    enabled: root.m_alteredValue
  }
}
