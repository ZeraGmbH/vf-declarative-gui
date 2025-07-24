import QtQuick 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ColorSettings 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import ZeraTranslation 1.0

Repeater {
    id: root
    readonly property QtObject dftModule: VeinEntity.getEntity("DFTModule1")
    readonly property bool valid: GC.entityInitializationDone && dftModule !== null && dftModule.ACT_RFIELD !== undefined
    readonly property string rotaryField: valid ? dftModule.ACT_RFIELD : ""
    model: rotaryField.length

    Text {
        text: Z.tr("Phase" + rotaryField[index])
        color: CS.currentColorTable[parseInt(rotaryField[index]-1)]
        font.pixelSize: root.height/1.8
        x: 2 + (root.width/3 * index)
        anchors.verticalCenter: parent.verticalCenter
    }
}
