import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import ZeraTranslation 1.0

Popup {
  id: root
  property color oldColor;
  readonly property color newColor: Qt.hsla(hueSlider.value, saturationSlider.value, lightnessSlider.value, alphaSlider.value);
  modal: true
  signal colorAccepted(color t_color)

  function rgbToHsl(r, g, b) {
    var max = Math.max(r, g, b)
    var min = Math.min(r, g, b);
    var h, s, l = (max + min) / 2;
    if(max === min)
    {
      h = s = 0; // achromatic
    }
    else
    {
      var d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

      switch(max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break;
      case g: h = (b - r) / d + 2; break;
      case b: h = (r - g) / d + 4; break;
      }

      h /= 6;
    }
    return { h: h, s: s, l: l };
  }

  RowLayout {
    spacing: 16
    ColumnLayout {
      id: inputLayout
      width: root.width/2
      Item {
        //hue bar
        width: inputLayout.width
        height: root.height/12
        LinearGradient {
          anchors.fill: parent
          start: Qt.point(0, 0)
          end: Qt.point(parent.width, 0)
          gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.hsla(0, 1, 0.5, 1); }
            GradientStop { position: 0.1; color: Qt.hsla(0.1, 1, 0.5, 1); }
            GradientStop { position: 0.2; color: Qt.hsla(0.2, 1, 0.5, 1); }
            GradientStop { position: 0.3; color: Qt.hsla(0.3, 1, 0.5, 1); }
            GradientStop { position: 0.4; color: Qt.hsla(0.4, 1, 0.5, 1); }
            GradientStop { position: 0.5; color: Qt.hsla(0.5, 1, 0.5, 1); }
            GradientStop { position: 0.6; color: Qt.hsla(0.6, 1, 0.5, 1); }
            GradientStop { position: 0.7; color: Qt.hsla(0.7, 1, 0.5, 1); }
            GradientStop { position: 0.8; color: Qt.hsla(0.8, 1, 0.5, 1); }
            GradientStop { position: 0.9; color: Qt.hsla(0.9, 1, 0.5, 1); }
            GradientStop { position: 1.0; color: Qt.hsla(1, 1, 0.5, 1); }
          }
        }
      }
      Slider {
        id: hueSlider
        width: inputLayout.width
        height: root.height/12
        from: 0
        to: 1
        stepSize: 0.01
        leftPadding: 0
        value: QT_VERSION >= 0x050900 ? oldColor.hslHue : rgbToHsl(oldColor.r, oldColor.g, oldColor.b).h
      }
      Item {
        //saturation bar
        width: inputLayout.width
        height: root.height/12
        LinearGradient {
          anchors.fill: parent
          start: Qt.point(0, 0)
          end: Qt.point(parent.width, 0)
          gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.hsla(hueSlider.value, 0, 0.5, 1); }
            GradientStop { position: 1.0; color: Qt.hsla(hueSlider.value, 1, 0.5, 1); }
          }
        }
      }
      Slider {
        id: saturationSlider
        width: inputLayout.width
        height: root.height/12
        from: 0
        to: 1
        stepSize: 0.01
        leftPadding: 0
        value: QT_VERSION >= 0x050900 ? oldColor.hslSaturation : rgbToHsl(oldColor.r, oldColor.g, oldColor.b).s
      }
      Item {
        width: inputLayout.width
        height: root.height/12
        LinearGradient {
          anchors.fill: parent
          start: Qt.point(0, 0)
          end: Qt.point(parent.width, 0)
          gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.hsla(hueSlider.value, 1, 0, 1); }
            GradientStop { position: 0.5; color: Qt.hsla(hueSlider.value, 1, 0.5, 1); }
            GradientStop { position: 1.0; color: Qt.hsla(hueSlider.value, 1, 1, 1); }
          }
        }
      }


      Slider {
        id: lightnessSlider
        width: inputLayout.width
        height: root.height/12
        from: 0
        to: 1
        stepSize: 0.01
        leftPadding: 0
        value: QT_VERSION >= 0x050900 ? oldColor.hslLightness : rgbToHsl(oldColor.r, oldColor.g, oldColor.b).l
      }
      Item {
        height: root.height/12
        width: inputLayout.width
        clip: true
        Image {
          //alpha bar
          height: root.height/12
          width: inputLayout.width
          source: "qrc:/data/staticdata/resources/checkers_pattern.png"

          fillMode: Image.Tile
          horizontalAlignment: Image.AlignLeft
          verticalAlignment: Image.AlignTop
          LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, 0)
            gradient: Gradient {
              GradientStop { position: 0.0; color: Qt.hsla(hueSlider.value, 1, 0.5, 0); }
              GradientStop { position: 1.0; color: Qt.hsla(hueSlider.value, 1, 0.5, 1); }
            }
          }
        }
      }


      Slider {
        id: alphaSlider
        width: inputLayout.width
        height: root.height/12
        from: 0
        to: 1
        stepSize: 0.01
        leftPadding: 0
        value: oldColor.a
      }
    }
    Item {
      width: root.width/1.5
      height: root.height
      Button {
        text: ZTR["Accept"]
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        highlighted: true
        onClicked: {
          colorAccepted(newColor);
          close();
        }
      }
      Button {
        text: ZTR["Close"]
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onClicked: close()
      }
      Rectangle {
        id: colorPreview
        height: 100
        width: height
        radius: height
        color: newColor
        //border.width: 2
        //border.color: Material.frameColor
        anchors.centerIn: parent

        layer.enabled: true
        layer.effect: OpacityMask {
          maskSource: Item {
            width: colorPreview.width*1.1
            height: colorPreview.height*1.1
            Rectangle {
              anchors.centerIn: parent
              width: colorPreview.adapt ? colorPreview.width : Math.min(colorPreview.width, colorPreview.height)
              height: colorPreview.adapt ? colorPreview.height : width
              radius: Math.min(width, height)
            }
          }
        }
        Image {
          z: parent.z-1
          anchors.fill: parent

          fillMode: Image.Tile
          source: "qrc:/data/staticdata/resources/checkers_pattern.png"
        }
      }
    }
  }
}
