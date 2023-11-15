import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

SettingsView {
    id: root

    readonly property real safeHeight: height > 0.0 ? height : 10
    rowHeight: safeHeight/8.5
    readonly property real pointSize: rowHeight * 0.34

    model: VisualItemModel {
        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Sensor environment (BLE):")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            VFSwitch {
                Layout.fillHeight: true
                entity: VeinEntity.getEntity("BleModule1")
                controlPropertyName: "PAR_BluetoothOn"
            }
        }

        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Temperature (°C):")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
        }
    }
}
