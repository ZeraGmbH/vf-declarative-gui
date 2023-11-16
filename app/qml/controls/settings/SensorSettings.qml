import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

SettingsView {
    id: root

    readonly property QtObject bleSensorEnt: VeinEntity.getEntity("BleModule1");
    readonly property real safeHeight: height > 0.0 ? height : 10
    rowHeight: safeHeight/8.5
    readonly property real pointSize: rowHeight * 0.34

    model: VisualItemModel {
        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Bluetooth:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            VFSwitch {
                Layout.fillHeight: true
                entity: bleSensorEnt
                controlPropertyName: "PAR_BluetoothOn"
            }
        }

        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("MAC address:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            VFLineEdit {
                id: macAddress
                // overrides
                function hasValidInput() {
                    var regex = RegExp(ModuleIntrospection.bleIntrospection.ComponentInfo.PAR_MacAddress.Validation.Data)
                    return regex.test(textField.text)
                }
                entity: bleSensorEnt
                controlPropertyName: "PAR_MacAddress"
                inputMethodHints: Qt.ImhNoAutoUppercase
                Layout.fillHeight: true
                pointSize: root.pointSize
                Layout.preferredWidth: root.rowWidth/3.25
            }
        }

        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Temperature [°C]:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Label {
                font.pointSize: root.pointSize
                text: FT.formatNumber(parseFloat(bleSensorEnt.ACT_TemperatureC))
            }
        }

        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Temperature [°F]:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Label {
                font.pointSize: root.pointSize
                text: FT.formatNumber(parseFloat(bleSensorEnt.ACT_TemperatureF))
            }
        }

        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Humidity [%]:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Label {
                font.pointSize: root.pointSize
                text: FT.formatNumber(parseFloat(bleSensorEnt.ACT_Humidity))
            }
        }

        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Air pressure [hPa]:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Label {
                font.pointSize: root.pointSize
                text: FT.formatNumber(parseFloat(bleSensorEnt.ACT_AirPressure))
            }
        }
    }
}
