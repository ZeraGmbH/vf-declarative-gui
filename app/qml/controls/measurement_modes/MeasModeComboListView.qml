import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import PowerModuleVeinGetter 1.0
import FontAwesomeQml 1.0

ListView {
    model: PwrModVeinGetter.powerModuleEntitiesAvailable
    delegate: Item {
        id: mmodeEntry
        anchors.left: parent.left
        anchors.right: parent.right
        height: rowHeight * 2
        readonly property real headerHeight: height * 0.2
        readonly property real headerComboMargin: headerHeight * 0.3
        readonly property real comboHeight: height * 0.6
        Label {
            id: mmodeLabel
            height: mmodeEntry.headerHeight
            anchors.left: parent.left
            anchors.top: parent.top
            verticalAlignment: Label.AlignVCenter
            font.pointSize: pointSize
            text: {
                let availTypes = PwrModVeinGetter.getPowerModuleEntity(index).INF_ModeTypes
                let currentType = PwrModVeinGetter.getPowerModuleEntity(index).ACT_PowerDisplayName
                let colorPrefix = "<font color='" + Qt.lighter(Material.color(Material.Amber)) + "'>"
                let colorPostfix = "</font>"
                let labelText = availTypes.join("/")
                labelText = labelText.replace(currentType, colorPrefix + currentType + colorPostfix)
                return labelText
            }
        }
        Label {
            id: labelBnc
            anchors.right: parent.right
            anchors.top: parent.top
            height: headerHeight
            font.pointSize: pointSize
            verticalAlignment: Label.AlignVCenter
            text: FAQ.fa_dot_circle
            visible: measModeCombo.entity.PAR_FOUT0 !== undefined && measModeCombo.entity.PAR_FOUT0 !== ""
        }
        MeasModeCombo {
            id: measModeCombo
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: mmodeLabel.bottom
            anchors.topMargin: mmodeEntry.headerComboMargin
            height: mmodeEntry.comboHeight
            power1ModuleIdx: index
            pointSize: root.pointSize
        }
    }
}
