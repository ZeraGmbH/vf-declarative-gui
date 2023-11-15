import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0

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
                text: Z.tr("Sensor environent (BLE):")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZCheckBox {
                id: actHarmonicsTableAsRelative
                Layout.fillHeight: true
                Component.onCompleted: checked = true
                //onCheckedChanged: {
                //}
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
