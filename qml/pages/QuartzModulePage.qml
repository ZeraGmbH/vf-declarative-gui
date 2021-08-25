import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraTranslation  1.0
import "../controls"

Item {
    id: root

    readonly property int rowHeight: Math.floor(height/8)
    readonly property int basicRowWidth: width/10
    readonly property int wideRowWidth: width/7

    // We are:
    // not part of swipe/tab combo
    // loaded on demand (see main.qml / pageLoader.source)
    Component.onCompleted: {
        GC.currentGuiContext = GC.guiContextEnum.GUI_QUARTZ_REFERENCE
    }

}
