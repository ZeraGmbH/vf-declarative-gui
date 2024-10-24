import QtQuick 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import ZeraTranslation 1.0

Item {
    id: root
    readonly property string rotaryField: GC.entityInitializationDone ? VeinEntity.getEntity("DFTModule1").ACT_RFIELD : ""

    Repeater {
        model: rotaryField.length
        Text {
            text: Z.tr("Phase" + rotaryField[index])
            color: GC.currentColorTable[parseInt(rotaryField[index]-1)]
            font.pixelSize: root.height/1.8
            x: 2 + (root.width/3 * index)
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
