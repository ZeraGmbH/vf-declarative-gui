import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraComponents 1.0

Loader {
    id: root
    // setters
    property QtObject entity
    property real visibleHeight

    height: privProps.canChangePhases ? visibleHeight : 0
    width: parent.width
    active: privProps.canChangePhases
    sourceComponent: viewComponent

    QtObject {
        id: privProps
        readonly property bool canChangePhases: entity.ACT_CanChangePhaseMask
        readonly property string phaseMaskStr: String(entity.PAR_MeasModePhaseSelect)
        readonly property int measSysCount: phaseMaskStr.length
        readonly property int maxMeasSysCount: entity.ACT_MaxMeasSysCount // common 3 / 2wire 1
    }
    QtObject {
        id: phaseLogic
        function phaseChange(phaseNo, phaseSet) {

        }
    }
    Component {
        id: singlePhaseDelegate
        Item {
            height: root.height
            width: root.width / privProps.measSysCount
            ZCheckBox {
                anchors.fill: parent
                checked: modelData === "1"
                onCheckedChanged: phaseLogic.phaseChange(index, checked)
            }
        }
    }
    Component {
        id: viewComponent
        Rectangle {
            anchors.fill: parent
            radius: 4
            color: Qt.darker(Material.frameColor)
            border.color: Material.dropShadowColor
            ListView {
                anchors.fill: parent
                delegate: singlePhaseDelegate
                model: privProps.phaseMaskStr.split('')
                orientation: ListView.Horizontal
            }
        }
    }
}
