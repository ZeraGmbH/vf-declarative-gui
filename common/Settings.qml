import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VF
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0 //as GC
import ModuleIntrospection 1.0
import VeinEntity 1.0
import Com5003Translation  1.0


CCMP.SettingsView {
  id: root

  model: VisualItemModel {

    Item {
      height: root.rowHeight*4;
      width: root.rowWidth;
      Label {
        text: ZTR["Application Settings"]
        font.pixelSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.rowHeight
      }

      Item {
        height: root.rowHeight*2 + 4
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: rowHeight
        Column {
          Item {
            id: harmonicsAsTable
            height: root.rowHeight;
            width: root.rowWidth;

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 16
              anchors.rightMargin: 16

              Label {
                textFormat: Text.PlainText
                text: ZTR["Display Harmonics as table:"]
                font.pixelSize: 20

                Layout.fillWidth: true
              }
              CheckBox {
                id: actHarmonicsAsTable
                height: parent.height
                Component.onCompleted: checked = GC.showFftAsTable
                onCheckedChanged: {
                  GC.setShowFftAsTable(checked);
                }
              }
            }
          }

          Item {
            id: decimalPlaces
            height: root.rowHeight;
            width: root.rowWidth;

            RowLayout {
              anchors.fill: parent
              anchors.rightMargin: 24
              anchors.leftMargin: 16

              Label {
                textFormat: Text.PlainText
                text: ZTR["Decimal places:"]
                font.pixelSize: 20

                Layout.fillWidth: true
              }

              SpinBox {
                id: actDecimalPlaces
                from: 3;
                to: 7;
                stepSize: 1
                value: GC.decimalPlaces
                onValueChanged: {
                  if(value !== GC.decimalPlaces)
                  {
                    GC.setDecimalPlaces(value)
                  }
                }

                contentItem: Label {
                  text: parent.textFromValue(parent.value, parent.locale)
                  textFormat: Text.PlainText

                  horizontalAlignment: Qt.AlignHCenter
                  verticalAlignment: Qt.AlignVCenter
                }
              }
            }
          }
        }
      }
    }

    Item {
      height: root.rowHeight*(4+sInterval.hasPeriodEntries);
      width: root.rowWidth;
      Label {
        text: ZTR["Device settings"]
        font.pixelSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.rowHeight
      }

      Item {
        height: root.rowHeight*(3+sInterval.hasPeriodEntries) + 8
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Component {
          id: swPllAutomatic
          RowLayout {
            Label {
              textFormat: Text.PlainText
              text: ZTR["PLL channel automatic:"]
              font.pixelSize: 20

              Layout.fillWidth: true
            }

            VF.VFSwitch {
              height: parent.height
              entity: VeinEntity.getEntity("SampleModule1")
              controlPropertyName: "PAR_PllAutomaticOnOff"
            }
          }
        }

        Component {
          id: cbPllChannel
          RowLayout {
            enabled: VeinEntity.getEntity("SampleModule1").PAR_PllAutomaticOnOff === 0

            Label {
              textFormat: Text.PlainText
              text: ZTR["PLL channel:"]
              font.pixelSize: 20

              Layout.fillWidth: true
              opacity: enabled ? 1.0 : 0.4
            }

            Item {
              Layout.fillWidth: true
            }


            VF.VFComboBox {
              arrayMode: true
              entity: VeinEntity.getEntity("SampleModule1")
              controlPropertyName: "PAR_PllChannel"
              model: ModuleIntrospection.sampleIntrospection.ComponentInfo.PAR_PllChannel.Validation.Data
              centerVertical: true
              implicitWidth: root.rowWidth/4
              height: root.rowHeight

              opacity: enabled ? 1.0 : 0.4
            }
          }
        }

        Column {
          anchors.fill: parent

          Loader {
            sourceComponent: swPllAutomatic
            active: VeinEntity.hasEntity("SampleModule1")
            asynchronous: true

            height: active ? root.rowHeight : 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 16
          }

          Loader {
            sourceComponent: cbPllChannel
            active: VeinEntity.hasEntity("SampleModule1")
            asynchronous: true

            height: active ? root.rowHeight : 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 16
          }

          SettingsInterval {
            id: sInterval
            rowHeight: root.rowHeight
            rowWidth: root.rowWidth-36
            x: 20
          }
        }
      }
    }
  }
}
