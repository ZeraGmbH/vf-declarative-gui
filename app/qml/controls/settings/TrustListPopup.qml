import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ZeraTranslation  1.0

Popup {
    anchors.centerIn: parent
    width: parent.width * 0.85
    height: parent.height * 0.65
    modal: true

    ColumnLayout {
        id: trustListPopupContent
        width: parent.width
        height: parent.height * 0.75
        Label {
            font.pointSize: pointSize
            text: Z.tr("Trusted API Users")
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            width: parent.width
            wrapMode: Text.Wrap
        }
    }
}
