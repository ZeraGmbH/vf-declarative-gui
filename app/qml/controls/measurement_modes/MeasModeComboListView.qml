import QtQuick 2.14
import QtQuick.Controls 2.14
import VeinEntity 1.0
import FontAwesomeQml 1.0

ListView {
    model: VeinEntity.hasEntity("POWER1Module4") ? 4 : 3
    delegate: Item {
        id: mmodeEntry
        anchors.left: parent.left
        anchors.right: parent.right
        height: rowHeight * 2
        readonly property real headerHeight: height * 0.2
        readonly property real comboHeight: height * 0.6
        Label {
            id: mmodeLabel
            height: mmodeEntry.headerHeight
            anchors.left: parent.left
            anchors.top: parent.top
            verticalAlignment: Label.AlignBottom
            font.pointSize: pointSize
            text: {
                let labelText = ""
                switch(index) {
                case 0:
                    labelText = VeinEntity.getEntity("POWER1Module1").ACT_PowerDisplayName
                    break
                case 1:
                    labelText = VeinEntity.getEntity("POWER1Module2").ACT_PowerDisplayName
                    break
                case 2:
                    labelText = VeinEntity.getEntity("POWER1Module3").ACT_PowerDisplayName
                    break
                case 3:
                    let power4Name = VeinEntity.getEntity("POWER1Module4").ACT_PowerDisplayName
                    let power4NameColored = "<font color='" + "lawngreen" + "'>" + power4Name + "</font>"
                    labelText = String("P/Q/S").replace(power4Name, power4NameColored)
                    break
                }
                return labelText + ":"
            }
        }
        Label {
            id: labelBnc
            anchors.right: parent.right
            anchors.top: parent.top
            height: headerHeight
            font.pointSize: pointSize
            verticalAlignment: Label.AlignBottom
            text: FAQ.fa_dot_circle
            visible: measModeCombo.entity.PAR_FOUT0 !== ""
        }
        MeasModeCombo {
            id: measModeCombo
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: mmodeLabel.bottom
            height: mmodeEntry.comboHeight
            power1ModuleIdx: index
            pointSize: root.pointSize
        }
    }
}
