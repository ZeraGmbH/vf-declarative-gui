import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import FontAwesomeQml 1.0

Rectangle {
    id: root
    // setters
    property var entity
    property var entityIntrospection
    property real rowHeight

    visible: entity.PAR_MeasuringMode === "QREF" && "PAR_FOUT_QREF_FREQ" in entityIntrospection.ComponentInfo
    height: visible ? 2*rowHeight : 0
    width: parent.width

    color: Qt.darker(Material.frameColor)
    border.color: Material.dropShadowColor

    Column {
        anchors.fill: parent
        //anchors.leftMargin: GC.standardTextHorizMargin
        //anchors.rightMargin: GC.standardTextHorizMargin
        Label {
            height: rowHeight
            width: parent.width
            font.pointSize: pointSize
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter
            text: Z.tr("Frequency:")
        }
        Label {
            height: rowHeight
            width: parent.width
            font.pointSize: pointSize
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter
            text: "foo"
        }
    }
}
