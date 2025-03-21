import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.14
import QtQuick.Controls.Material 2.0
import FontAwesomeQml 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

SettingsView {
    id: root

    readonly property QtObject bleSensorEnt: VeinEntity.getEntity("BleModule1");
    readonly property real safeHeight: height > 0.0 ? height : 10
    readonly property bool notEmobSession: VeinEntity.getEntity("_System").Session !== "mt310s2-emob-session-ac.json" && VeinEntity.getEntity("_System").Session !== "mt310s2-emob-session-dc.json"
    rowHeight: safeHeight/8.5
    readonly property real pointSize: rowHeight * 0.34
    readonly property int decimalPlaces: 1
    readonly property bool bluetoothOn: bleSensorEnt.PAR_BluetoothOn !== 0

    function valuesFound() {
        let onValueAvail = !isNaN(VeinEntity.getEntity("BleModule1").ACT_TemperatureC) ||
                           !isNaN(VeinEntity.getEntity("BleModule1").ACT_Humidity) ||
                           !isNaN(VeinEntity.getEntity("BleModule1").ACT_AirPressure)
        var retVal = false;
        if(onValueAvail)
            retVal = true;
        return retVal
    }


    model: ObjectModel {
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

        Loader {
            width: parent.width
            active: !notEmobSession && bluetoothOn
            sourceComponent: RowLayout {
                height: root.rowHeight
                width: root.rowWidth
                Label {
                    text: {
                        if(valuesFound())
                            return "Sensor TPH100 found";
                        else
                            return "Sensor TPH100 not found";
                    }
                    color: {
                        if(valuesFound())
                            return "green";
                        else
                            return "red";
                    }
                    textFormat: Text.PlainText
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Label.AlignVCenter
                    font.bold: true
                }
            }
        }

        Loader {
            width: parent.width
            active: notEmobSession
            sourceComponent: Rectangle {
                color: "transparent"
                height: root.rowHeight
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
                        text: FT.formatNumberParam(parseFloat(bleSensorEnt.ACT_TemperatureC), GC.digitsTotal, decimalPlaces)
                    }
                }
            }
        }

        Loader {
            width: parent.width
            active: notEmobSession
            sourceComponent:  Rectangle {
                color: "transparent"
                height: root.rowHeight
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
                        text: FT.formatNumberParam(parseFloat(bleSensorEnt.ACT_TemperatureF), GC.digitsTotal, decimalPlaces)
                    }
                }
            }
        }

        Loader {
            width: parent.width
            active: notEmobSession
            sourceComponent:  Rectangle {
                color: "transparent"
                height: root.rowHeight
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
                        text: FT.formatNumberParam(parseFloat(bleSensorEnt.ACT_Humidity), GC.digitsTotal, decimalPlaces)
                    }
                }
            }
        }

        Loader {
            width: parent.width
            active: notEmobSession
            sourceComponent:  Rectangle {
                color: "transparent"
                height: root.rowHeight
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
                        text: FT.formatNumberParam(parseFloat(bleSensorEnt.ACT_AirPressure), GC.digitsTotal, decimalPlaces)
                    }
                }
            }
        }
    }
}
